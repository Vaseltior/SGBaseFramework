/*
    File:       QLogViewer.h

    Contains:   Displays in-memory QLog entries, with options to copy and mail the log.

*/

#import <UIKit/UIKit.h>

@interface SGQLogViewer : UITableViewController
{
    int                 _logEntriesDummy;
    UIActionSheet *     _actionSheet;
    UIAlertView *       _alertView;
}

- (void)presentModallyOn:(UIViewController *)controller animated:(BOOL)animated;
    // Present the view controller modally on the specified view controller.

@end
