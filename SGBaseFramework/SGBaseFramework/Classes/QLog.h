/*
    File:       QLog.h

    Contains:   A simplistic logging package.

*/

#import <Foundation/Foundation.h>

@interface QLog : NSObject
{
    BOOL                _enabled;                                               // main thread write, any thread read
    int                 _logFile;                                               // main thread write, any thread read
    off_t               _logFileLength;                                         // main thread only, only valid if _logFile != -1
    BOOL                _loggingToStdErr;                                       // main thread write, any thread read
    NSUInteger          _optionsMask;                                           // main thread write, any thread read
    BOOL                _showViewer;                                            // main thread only
    NSMutableArray *    _logEntries;                                            // main thread only
    NSMutableArray *    _pendingEntries;                                        // any thread, protected by @synchronize (self)
}

+ (QLog *)log;                                                                  // any thread
    // Returns the singleton logging object.
    
- (void)flush;                                                                  // main thread only
    // Flushes any pending log entries to the logEntries array and also, if 
    // appropriate, to the log file or stderr.
    
- (void)clear;                                                                  // main thread only
    // Empties the logEntries array and, if appropriate, the log file.  Not 
    // much we can do about stderr (-:

// Preferences

@property (nonatomic, assign, readonly, getter=isEnabled) BOOL         enabled;            // any thread, observable, always changed by main thread
@property (nonatomic, assign, readonly, getter=isLoggingToFile) BOOL   loggingToFile;      // any thread, observable, always changed by main thread
@property (nonatomic, assign, readonly, getter=isLoggingToStdErr) BOOL loggingToStdErr;    // any thread, observable, always changed by main thread
@property (nonatomic, assign, readonly) NSUInteger                     optionsMask;        // any thread, observable, always changed by main thread

@property (nonatomic, assign, readonly) BOOL                           showViewer;         // main thread, observable, always changed by main thread

// User Default         Property
// ------------         --------
// qlogEnabled          enabled
// qlogLoggingToFile    loggingToFile
// qlogLoggingToStdErr  loggingToStdErr
// qlogOption0..31      optionsMask

// Log entry generation

// Some things to note:
// 
// o The -logOptions:xxx methods only log if the specified bit is set in 
//   optionsMask (that is, (optionsMask & (1 << option)) is not zero).
//
// o The format string is as implemented by +[NSString stringWithFormat:].

- (void)logWithFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(1, 2);                             // any thread
- (void)logWithFormat:(NSString *)format arguments:(va_list)argList;                                // any thread
- (void)logOption:(NSUInteger)option withFormat:(NSString *)format, ... NS_FORMAT_FUNCTION(2, 3);   // any thread
- (void)logOption:(NSUInteger)option withFormat:(NSString *)format arguments:(va_list)argList;      // any thread

// In memory log entries

// New entries are added to the end of this array and, as there's an upper limit 
// number of entries that will be held in memory, ald entries are removed from 
// the beginning.

@property (nonatomic, retain, readonly) NSMutableArray *               logEntries;         // observable, always changed by main thread

// In file log entries

- (NSInputStream *)streamForLogValidToLength:(off_t *)lengthPtr;                // main thread only
    // Returns an un-opened stream.  If lengthPtr is not NULL then, on return 
    // *lengthPtr contains the number of bytes in that stream that are 
    // guaranteed to be valid.
    //
    // This can only be called on the main thread but the resulting stream 
    // can be passed to any thread for processing.
    
@end
