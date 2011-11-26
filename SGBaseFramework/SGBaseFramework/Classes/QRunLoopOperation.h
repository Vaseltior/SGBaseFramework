/*
    File:       QRunLoopOperation.h

    Contains:   An abstract subclass of NSOperation for async run loop based operations.
*/

#import <Foundation/Foundation.h>

enum QRunLoopOperationState {
    kQRunLoopOperationStateInited, 
    kQRunLoopOperationStateExecuting, 
    kQRunLoopOperationStateFinished
};
typedef enum QRunLoopOperationState QRunLoopOperationState;

@interface QRunLoopOperation : NSOperation
{
    QRunLoopOperationState  _state;
    NSThread *              _runLoopThread;
    NSSet *                 _runLoopModes;
    NSError *               _error;
}

// Things you can configure before queuing the operation.

// IMPORTANT: Do not change these after queuing the operation; it's very likely that 
// bad things will happen if you do.

@property (nonatomic, retain, readwrite) NSThread *                runLoopThread;          // default is nil, implying main thread
@property (nonatomic, copy,   readwrite) NSSet *                   runLoopModes;           // default is nil, implying set containing NSDefaultRunLoopMode

// Things that are only meaningful after the operation is finished.

@property (nonatomic, copy,   readonly ) NSError *                 error;

// Things you can only alter implicitly.

@property (nonatomic, assign, readonly ) QRunLoopOperationState    state;
@property (nonatomic, retain, readonly ) NSThread *                actualRunLoopThread;    // main thread if runLoopThread is nil, runLoopThread otherwise
@property (nonatomic, assign, readonly ) BOOL                      isActualRunLoopThread;  // YES if the current thread is the actual run loop thread
@property (nonatomic, copy,   readonly ) NSSet *                   actualRunLoopModes;     // set containing NSDefaultRunLoopMode if runLoopModes is nil or empty, runLoopModes otherwise

@end

@interface QRunLoopOperation (SubClassSupport)

// Override points

// A subclass will probably need to override -operationDidStart and -operationWillFinish 
// to set up and tear down its run loop sources, respectively.  These are always called 
// on the actual run loop thread.
//
// Note that -operationWillFinish will be called even if the operation is cancelled. 
//
// -operationWillFinish can check the error property to see whether the operation was 
// successful.  error will be NSCocoaErrorDomain/NSUserCancelledError on cancellation. 
//
// -operationDidStart is allowed to call -finishWithError:.

- (void)operationDidStart;
- (void)operationWillFinish;

// Support methods

// A subclass should call finishWithError: when the operation is complete, passing nil 
// for no error and an error otherwise.  It must call this on the actual run loop thread. 
// 
// Note that this will call -operationWillFinish before returning.

- (void)finishWithError:(NSError *)error;

@end
