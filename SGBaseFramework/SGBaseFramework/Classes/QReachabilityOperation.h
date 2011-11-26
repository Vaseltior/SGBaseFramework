/*
    File:       QReachabilityOperation.h

    Contains:   Runs until a host's reachability attains a certain value.

*/

#import "QRunLoopOperation.h"

#include <SystemConfiguration/SystemConfiguration.h>

@interface QReachabilityOperation : QRunLoopOperation
{
    NSString *                      _hostName;
    NSUInteger                      _flagsTargetMask;
    NSUInteger                      _flagsTargetValue;
    NSUInteger                      _flags;
    SCNetworkReachabilityRef        _ref;
}

- (id)initWithHostName:(NSString *)hostName;
    // Initialises the operation to monitor the reachability of the specified 
    // host.  The operation finishes when (flags & flagsTargetMask) == flagsTargetValue.

// Things that are configured by the init method and can't be changed.

@property (nonatomic, copy,   readonly ) NSString *    hostName;

// Things you can configure before queuing the operation.

// runLoopThread and runLoopModes inherited from QRunLoopOperation
@property (nonatomic, assign, readwrite) NSUInteger    flagsTargetMask;
@property (nonatomic, assign, readwrite) NSUInteger    flagsTargetValue;

// Things that change as part of the progress of the operation.

// error property inherited from QRunLoopOperation
@property (nonatomic, assign, readonly ) NSUInteger    flags;              // observable, changes on the actual run loop thread

@end
