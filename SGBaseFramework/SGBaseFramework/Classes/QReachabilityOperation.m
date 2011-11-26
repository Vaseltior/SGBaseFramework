/*
    File:       QReachabilityOperation.h

    Contains:   Runs until a host's reachability attains a certain value.

*/

#import "QReachabilityOperation.h"

@interface QReachabilityOperation ()

// read/write versions of public properties

@property (nonatomic, assign, readwrite) NSUInteger    flags;

// forward declarations

static void ReachabilityCallback(
    SCNetworkReachabilityRef    target,
    SCNetworkReachabilityFlags  flags,
    void *                      info
);

- (void)reachabilitySetFlags:(NSUInteger)newValue;

@end

@implementation QReachabilityOperation

- (id)initWithHostName:(NSString *)hostName
    // See comment in header.
{
    assert(hostName != nil);
    self = [super init];
    if (self != nil) {
        self->_hostName         = [hostName copy];
        self->_flagsTargetMask  = kSCNetworkReachabilityFlagsReachable | kSCNetworkReachabilityFlagsInterventionRequired;
        self->_flagsTargetValue = kSCNetworkReachabilityFlagsReachable;
    }
    return self;
}

- (void)dealloc
{
    [self->_hostName release];
    assert(self->_ref == NULL);
    [super dealloc];
}

@synthesize hostName         = _hostName;
@synthesize flagsTargetMask  = _flagsTargetMask;
@synthesize flagsTargetValue = _flagsTargetValue;
@synthesize flags            = _flags;

- (void)operationDidStart
    // Called by QRunLoopOperation when the operation starts.  This is our opportunity 
    // to install our run loop callbacks, which is exactly what we do.  The only tricky 
    // thing is that we have to schedule the reachability ref to run in all of the 
    // run loop modes specified by our client.
{
    Boolean                         success;
    SCNetworkReachabilityContext    context = { 0, self, NULL, NULL, NULL };
    
    assert(self->_ref == NULL);
    self->_ref = SCNetworkReachabilityCreateWithName(NULL, [self.hostName UTF8String]);
    assert(self->_ref != NULL);

    success = SCNetworkReachabilitySetCallback(self->_ref, ReachabilityCallback, &context);
    assert(success);

    for (NSString * mode in self.actualRunLoopModes) {
        success = SCNetworkReachabilityScheduleWithRunLoop(self->_ref, CFRunLoopGetCurrent(), (CFStringRef) mode);
        assert(success);
    }
}

static void ReachabilityCallback(
    SCNetworkReachabilityRef    target,
    SCNetworkReachabilityFlags  flags,
    void *                      info
)
    // Called by the system when the reachability flags change.  We just forward 
    // the flags to our Objective-C code.
{
    QReachabilityOperation *    obj;
    
    obj = (QReachabilityOperation *) info;
    assert([obj isKindOfClass:[QReachabilityOperation class]]);
    assert(target == obj->_ref);
    #pragma unused(target)
    
    [obj reachabilitySetFlags:flags];
}

- (void)reachabilitySetFlags:(NSUInteger)newValue
    // Called when the reachability flags change.  We just store the flags and then 
    // check to see if the flags meet our target criteria, in which case we stop the 
    // operation.
{
    assert( [NSThread currentThread] == self.actualRunLoopThread );
    
    self.flags = newValue;
    if ( (self.flags & self.flagsTargetMask) == self.flagsTargetValue ) {
        [self finishWithError:nil];
    }
}

- (void)operationWillFinish
    // Called by QRunLoopOperation when the operation finishes.  We just clean up 
    // our reachability ref.
{
    Boolean success;

    if (self->_ref != NULL) {
        for (NSString * mode in self.actualRunLoopModes) {
            success = SCNetworkReachabilityUnscheduleFromRunLoop(self->_ref, CFRunLoopGetCurrent(), (CFStringRef) mode);
            assert(success);
        }

        success = SCNetworkReachabilitySetCallback(self->_ref, NULL, NULL);
        assert(success);
        
        CFRelease(self->_ref);
        self->_ref = NULL;
    }
}

@end
