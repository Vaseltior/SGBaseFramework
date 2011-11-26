/*
    File:       RetryingHTTPOperation.h

    Contains:   Runs an HTTP request, with support for retries.

*/

#import "QRunLoopOperation.h"

/*
    RetryingHTTPOperation is a run loop based concurrent operation that initiates 
    an HTTP request and handles retrying the request if it fails.  There are a bunch 
    of important points to note:
      
    o You should only use this class for idempotent requests, that is, requests that 
      won't cause problems if they are retried.  See RFC 2616 for more info on this topic.
      
      <http://www.ietf.org/rfc/rfc2616.txt>
    
    o It only retries requests where the result is likely to change.  For example, 
      there's no point retrying after an HTTP 404 status code.  The (private) method 
      -shouldRetryAfterError: controls what will and won't be retried.

    o The fundamental retry mechanism is a random expotential back-off algorithm. 
      After a failure it choose a random delay between the 0 and the max delay. 
      Each failure increases the maximum delay up to some overall limit.  The current 
      max delay sequence is one second, one minute, one hour, and six hours. 
      You can tweak this by changing kRetryDelays.

    o In addition to this it does a fast retry if one of the following things happens:

      - The reachability status of the host associated with the request changes from 
        unreachable to reachable.  The change from unreachable to reachable indicates 
        that the local network environment has changed sufficiently to justify a 
        fresh retry.
    
      - Some other request to that host succeeds, which is a good indication that 
        other requests will succeed as well.

    o The operation runs out of the run loop associated with the actualRunLoopThread 
      inherited from QRunLoopOperation.  If you observe any properties, expect them 
      to be changed by that thread.

    o The exception is the hasHadRetryableFailure property.  This property is always 
      changed by the main thread.  This makes it easy for main thread code to 
      display a 'retrying' user interface.
*/

@class QHTTPOperation;
@class QReachabilityOperation;

enum RetryingHTTPOperationState {
    kRetryingHTTPOperationStateNotStarted, 
    kRetryingHTTPOperationStateGetting, 
    kRetryingHTTPOperationStateWaitingToRetry, 
    kRetryingHTTPOperationStateRetrying,
    kRetryingHTTPOperationStateFinished
};
typedef enum RetryingHTTPOperationState RetryingHTTPOperationState;

@interface RetryingHTTPOperation : QRunLoopOperation
{
    NSUInteger                  _sequenceNumber;
    NSURLRequest *              _request;
    NSSet *                     _acceptableContentTypes;
    NSString *                  _responseFilePath;
    NSHTTPURLResponse *         _response;
    NSData *                    _responseContent;
    RetryingHTTPOperationState  _retryState;
    RetryingHTTPOperationState  _retryStateClient;
    QHTTPOperation *            _networkOperation;
    BOOL                        _hasHadRetryableFailure;
    NSUInteger                  _retryCount;
    NSTimer *                   _retryTimer;
    QReachabilityOperation *    _reachabilityOperation;
    BOOL                        _notificationInstalled;
}

- (id)initWithRequest:(NSURLRequest *)request;
    // Initialise the operation to run the specified HTTP request.

// Things that are configured by the init method and can't be changed.

@property (nonatomic, copy,   readonly)  NSURLRequest *                request;

// Things you can configure before queuing the operation.

// runLoopThread and runLoopModes inherited from QRunLoopOperation
@property (nonatomic, copy,   readwrite) NSSet *                       acceptableContentTypes; // default is nil, implying anything is acceptable
@property (nonatomic, retain, readwrite) NSString *                    responseFilePath;       // defaults to nil, which puts response into responseContent

// Things that change as part of the progress of the operation.

@property (nonatomic, assign, readonly ) RetryingHTTPOperationState    retryState;             // observable, always changes on actualRunLoopthread
@property (nonatomic, assign, readonly ) RetryingHTTPOperationState    retryStateClient;       // observable, always changes on /main/ thread
@property (nonatomic, assign, readonly ) BOOL                          hasHadRetryableFailure; // observable, always changes on /main/ thread
@property (nonatomic, assign, readonly ) NSUInteger                    retryCount;             // observable, always changes on actualRunLoopthread

// Things that are only meaningful after the operation is finished.

// error property inherited from QRunLoopOperation
@property (nonatomic, copy,   readonly ) NSString *                    responseMIMEType;       // MIME type of responseContent
@property (nonatomic, copy,   readonly ) NSData *                      responseContent;        // responseContent (nil if response content went to responseFilePath)

@end
