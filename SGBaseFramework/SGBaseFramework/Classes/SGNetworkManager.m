/*
    File:       NetworkManager.m

    Contains:   A singleton to manage the core network interactions.


*/

#import "SGNetworkManager.h"

#import "QHTTPOperation.h"

#import "Logging.h"

@interface SGNetworkManager ()

// private properties

@property (atomic, retain, readonly ) NSThread *             networkRunLoopThread;

@property (nonatomic, retain, readonly ) NSOperationQueue *     queueForNetworkTransfers;
@property (nonatomic, retain, readonly ) NSOperationQueue *     queueForNetworkManagement;
@property (nonatomic, retain, readonly ) NSOperationQueue *     queueForCPU;

@end

@implementation SGNetworkManager

+ (SGNetworkManager *)sharedManager
    // See comment in header.
{
    static SGNetworkManager * sNetworkManager;

    // This can be called on any thread, so we synchronise.  We only do this in 
    // the sNetworkManager case because, once sNetworkManager goes non-nil, it can 
    // never go nil again.

    if (sNetworkManager == nil) {
        @synchronized (self) {
            sNetworkManager = [[SGNetworkManager alloc] init];
            assert(sNetworkManager != nil);
        }
    }
    return sNetworkManager;
}

- (id)init
{
    // any thread, but serialised by +sharedManager
    self = [super init];
    if (self != nil) {

        // Create the network management queue.  We will run an unbounded number of these operations 
        // in parallel because each one consumes minimal resources.
        
        self->_queueForNetworkManagement = [[NSOperationQueue alloc] init];
        assert(self->_queueForNetworkManagement != nil);

        [self->_queueForNetworkManagement setMaxConcurrentOperationCount:NSIntegerMax];
        assert(self->_queueForNetworkManagement != nil);

        // Create the network transfer queue.  We will run up to 4 simultaneous network requests.
        
        self->_queueForNetworkTransfers = [[NSOperationQueue alloc] init];
        assert(self->_queueForNetworkTransfers != nil);
        
        [self->_queueForNetworkTransfers setMaxConcurrentOperationCount:4];
        assert(self->_queueForNetworkTransfers != nil);

        // Create the CPU queue.  In contrast to the network queues, we leave 
        // maxConcurrentOperationCount set to the default, which means on current iOS devices 
        // the CPU operations are serialised.  There's no point bouncing a single CPU between 
        // threads for this stuff.
        
        self->_queueForCPU = [[NSOperationQueue alloc] init];
        assert(self->_queueForCPU != nil);
        
        // Create two dictionaries to store the target and action for each queued operation. 
        // Note that we retain the operation and the target but there's no need to retain the 
        // action selector.

        self->_runningOperationToTargetMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        assert(self->_runningOperationToTargetMap != NULL);
        self->_runningOperationToActionMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, NULL);
        assert(self->_runningOperationToActionMap != NULL);
        self->_runningOperationToThreadMap = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        assert(self->_runningOperationToThreadMap != NULL);
        
        // We run all of our network callbacks on a secondary thread to ensure that they don't 
        // contribute to main thread latency.  Create and configure that thread.
        
        self->_networkRunLoopThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRunLoopThreadEntry) object:nil];
        assert(self->_networkRunLoopThread != nil);

        [self->_networkRunLoopThread setName:@"networkRunLoopThread"];
        if ( [self->_networkRunLoopThread respondsToSelector:@selector(setThreadPriority)] ) {
            [self->_networkRunLoopThread setThreadPriority:0.3];
        }

        [self->_networkRunLoopThread start];
    }
    return self;
}

- (void)dealloc
{
    // This object lives for the entire life of the application.  Getting it to support being 
    // deallocated would be quite tricky (particularly from a threading perspective), so we 
    // don't even try.
    assert(NO);
    [super dealloc];
}

- (NSMutableURLRequest *)requestToGetURL:(NSURL *)url
    // See comment in header.
{
    NSMutableURLRequest *   result;
    static NSString *       sUserAgentString;

    // any thread
    assert(url != nil);

    // Create the request.
    
    result = [NSMutableURLRequest requestWithURL:url];
    assert(result != nil);
    
    // Set up the user agent string.
    
    if (sUserAgentString == nil) {
        @synchronized ([self class]) {
            sUserAgentString = [[NSString alloc] initWithFormat:@"MVCNetworking/%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:(id)kCFBundleVersionKey]];
            assert(sUserAgentString != nil);
        }
    }
    [result setValue:sUserAgentString forHTTPHeaderField:@"User-Agent"];
    
    return result;
}

#pragma mark * Operation dispatch

@synthesize networkRunLoopThread = _networkRunLoopThread;

- (void)networkRunLoopThreadEntry
    // This thread runs all of our network operation run loop callbacks.
{
    assert( ! [NSThread isMainThread] );
    while (YES) {
        NSAutoreleasePool * pool;

        pool = [[NSAutoreleasePool alloc] init];
        assert(pool != nil);

        [[NSRunLoop currentRunLoop] run];

        [pool drain];
    }
    assert(NO);
}

- (BOOL)networkInUse
    // See comment in header.
{
    assert([NSThread isMainThread]);
    
    // I base -networkInUse off the number of running operations, not the number of running 
    // network operations.  This is probably technically incorrect, but the reality is that 
    // changing it would be tricky (but not /that/ tricky) and there's some question as to 
    // whether it's the right thing to do anyway.  In an application that did extensive CPU work 
    // that was unrelated to the network then, sure, you'd only want the network activity 
    // indicator running while you were hitting the network.  But in this application 
    // all CPU activity is the direct result of networking, so leaving the network activity 
    // indicator running while this CPU activity is busy isn't too far from the mark.
    
    return self->_runningNetworkTransferCount != 0;
}

- (void)incrementRunningNetworkTransferCount
{
    BOOL    movingToInUse;
    
    assert([NSThread isMainThread]);

    movingToInUse = (self->_runningNetworkTransferCount == 0);
    if (movingToInUse) {
        [self willChangeValueForKey:@"networkInUse"];
    }
    self->_runningNetworkTransferCount += 1;
    if (movingToInUse) {
        [self  didChangeValueForKey:@"networkInUse"];
    }
}

- (void)decrementRunningNetworkTransferCount
{
    BOOL    movingToNotInUse;
    
    assert([NSThread isMainThread]);

    assert(self->_runningNetworkTransferCount != 0);
    movingToNotInUse = (self->_runningNetworkTransferCount == 1);
    if (movingToNotInUse) {
        [self willChangeValueForKey:@"networkInUse"];
    }
    self->_runningNetworkTransferCount -= 1;
    if (movingToNotInUse) {
        [self  didChangeValueForKey:@"networkInUse"];
    }
}

@synthesize queueForNetworkTransfers  = _queueForNetworkTransfers;
@synthesize queueForNetworkManagement = _queueForNetworkManagement;
@synthesize queueForCPU               = _queueForCPU;

- (void)addOperation:(NSOperation *)operation toQueue:(NSOperationQueue *)queue finishedTarget:(id)target action:(SEL)action
    // Core code to enqueue an operation on a queue.
{
    // any thread
    assert(operation != nil);
    assert(target != nil);
    assert(action != nil);

    // In the debug build, apply our debugging preferences to any operations 
    // we enqueue.
    
    #if ! defined(NDEBUG)

        // While, in theory, networkErrorRate should only apply to network operations, we 
        // apply it to all operations if they support the -setDebugError: method.

        if ( [operation respondsToSelector:@selector(setDebugError:)] ) {
            static NSInteger    sOperationCount;
            NSInteger           networkErrorRate;
            
            networkErrorRate = [[NSUserDefaults standardUserDefaults] integerForKey:@"networkErrorRate"];
            if (networkErrorRate != 0) {
                sOperationCount += 1;
                if ( (sOperationCount % networkErrorRate) == 0) {
                    [(id)operation setDebugError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorCannotConnectToHost userInfo:nil]];
                }
            }
        }
        if ( [operation respondsToSelector:@selector(setDebugDelay:)] ) {
            NSTimeInterval  operationDelay;
            
            operationDelay = [[NSUserDefaults standardUserDefaults] doubleForKey:@"operationDelay"];
            if (operationDelay > 0.0) {
                [(id)operation setDebugDelay:operationDelay];
            }
        }
    #endif

    // Update our networkInUse property; because we can be running on any thread, we 
    // do this update on the main thread.
    
    if (queue == self.queueForNetworkTransfers) {
        [self performSelectorOnMainThread:@selector(incrementRunningNetworkTransferCount) withObject:nil waitUntilDone:NO];
    }
    
    // Atomically enter the operation into our target and action maps.
    
    @synchronized (self) {
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

        assert( CFDictionaryGetValue(self->_runningOperationToTargetMap, operation) == NULL );      // shouldn't already be in our map
        assert( CFDictionaryGetValue(self->_runningOperationToActionMap, operation) == NULL );      // shouldn't already be in our map
        assert( CFDictionaryGetValue(self->_runningOperationToThreadMap, operation) == NULL );      // shouldn't already be in our map
        
        // Add the operations to , triggering a KVO notification 
        // of networkInUse if required.
        
        CFDictionarySetValue(self->_runningOperationToTargetMap, operation, target);
        CFDictionarySetValue(self->_runningOperationToActionMap, operation, action);
        CFDictionarySetValue(self->_runningOperationToThreadMap, operation, [NSThread currentThread]);

        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
    }
    
    // Observe the isFinished property of the operation.  We pass the queue parameter as the 
    // context so that, in the completion routine, we know what queue the operation was sent 
    // to (necessary to decide what thread to run the target/action on).
    
    [operation addObserver:self forKeyPath:@"isFinished" options:0 context:queue];
    
    // Queue the operation.  When the operation completes, -operationDone: is called.
    
    [queue addOperation:operation];
}

- (void)addNetworkManagementOperation:(NSOperation *)operation finishedTarget:(id)target action:(SEL)action
    // See comment in header.
{
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ( [(id)operation runLoopThread] == nil ) {
            [ (id)operation setRunLoopThread:self.networkRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.queueForNetworkManagement finishedTarget:target action:action];
}

- (void)addNetworkTransferOperation:(NSOperation *)operation finishedTarget:(id)target action:(SEL)action
    // See comment in header.
{
    if ([operation respondsToSelector:@selector(setRunLoopThread:)]) {
        if ( [(id)operation runLoopThread] == nil ) {
            [ (id)operation setRunLoopThread:self.networkRunLoopThread];
        }
    }
    [self addOperation:operation toQueue:self.queueForNetworkTransfers finishedTarget:target action:action];
}

- (void)addCPUOperation:(NSOperation *)operation finishedTarget:(id)target action:(SEL)action
    // See comment in header.
{
    [self addOperation:operation toQueue:self.queueForCPU finishedTarget:target action:action];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    // any thread
    if ( [keyPath isEqual:@"isFinished"] ) {
        NSOperation *       operation;
        NSOperationQueue *  queue;
        NSThread *          thread;
        
        operation = (NSOperation *) object;
        assert([operation isKindOfClass:[NSOperation class]]);
        assert([operation isFinished]);

        queue = (NSOperationQueue *) context;
        assert([queue isKindOfClass:[NSOperationQueue class]]);

        [operation removeObserver:self forKeyPath:@"isFinished"];
        
        @synchronized (self) {
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

            thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
            if (thread != nil) {
                [thread retain];
            }
        }

        if (thread != nil) {
            [self performSelector:@selector(operationDone:) onThread:thread withObject:operation waitUntilDone:NO];
            
            [thread release];

            if (queue == self.queueForNetworkTransfers) {
                [self performSelectorOnMainThread:@selector(decrementRunningNetworkTransferCount) withObject:nil waitUntilDone:NO];
            }
        }
    } else if (NO) {   // Disabled because the super class does nothing useful with it.
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)operationDone:(NSOperation *)operation
    // Called by the operation queue when the operation is done.  We find the corresponding 
    // target/action and call it on this thread.
{
    id          target;
    SEL         action;
    NSThread *  thread;

    // any thread
    assert(operation != nil);

    // Find the target/action, if any, in the map and then remove it.
    
    @synchronized (self) {
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

        target =         (id) CFDictionaryGetValue(self->_runningOperationToTargetMap, operation);
        action =        (SEL) CFDictionaryGetValue(self->_runningOperationToActionMap, operation);
        thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
        assert( (target != nil) == (action != nil) );
        assert( (target != nil) == (thread != nil) );

        // We need target to persist across the remove /and/ after we leave the @synchronized 
        // block, so we retain it here.  We need to test target for nil because -cancelOperation: 
        // might have pulled it out from underneath us.

        if (target != nil) {
            [target retain];

            assert( thread == [NSThread currentThread] );

            CFDictionaryRemoveValue(self->_runningOperationToTargetMap, operation);
            CFDictionaryRemoveValue(self->_runningOperationToActionMap, operation);
            CFDictionaryRemoveValue(self->_runningOperationToThreadMap, operation);
        }
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
        assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
    }
    
    // If we removed the operation, call the target/action.  However, we still have to 
    // test isCancelled here because -cancelOperation: might have cancelled it but 
    // not yet pulled it out of the map.
    // 
    // Note that there's no race condition testing isCancelled here.  We know that the 
    // operation is out of the map at this point (specifically, at the point we leave 
    // the @synchronized block), so no one can call -cancelOperation: on the operation. 
    // So, the final fate of the operation, cancelled or not, is determined before 
    // we enter the @synchronized block.
    
    if (target != nil) {
        if ( ! [operation isCancelled] ) {
            [target performSelector:action withObject:operation];
        }
        
        [target release];
    }
}

- (void)cancelOperation:(NSOperation *)operation
    // See comment in header.
{
    id          target;
    SEL         action;
    NSThread *  thread;

    // any thread
 
    // To simplify the client's clean up code, we specifically allow the operation to be nil 
    // and the operation to not be queued.
    
    if (operation != nil) {

        // We do the cancellation outside of the @synchronized block because it might take 
        // some time.

        [operation cancel];

        // Now we pull the target/action out of the map.
        
        @synchronized (self) {
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );

            target =         (id) CFDictionaryGetValue(self->_runningOperationToTargetMap, operation);
            action =        (SEL) CFDictionaryGetValue(self->_runningOperationToActionMap, operation);
            thread = (NSThread *) CFDictionaryGetValue(self->_runningOperationToThreadMap, operation);
            assert( (target != nil) == (action != nil) );
            assert( (target != nil) == (thread != nil) );

            // We don't need to retain target here because we never actually call it, we just 
            // test it for nil.  We need to test for target for nil because -operationDone: 
            // might have won the race to pull it out.

            if (target != nil) {
                CFDictionaryRemoveValue(self->_runningOperationToTargetMap, operation);
                CFDictionaryRemoveValue(self->_runningOperationToActionMap, operation);
                CFDictionaryRemoveValue(self->_runningOperationToThreadMap, operation);
            }
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToActionMap) );
            assert( CFDictionaryGetCount(self->_runningOperationToTargetMap) == CFDictionaryGetCount(self->_runningOperationToThreadMap) );
        }
    }
}

@end
