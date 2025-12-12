#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

/**
 * Category on Qt's QIOSApplicationDelegate to add push notification support
 * 
 * Qt already creates its own UIApplication and app delegate (QIOSApplicationDelegate).
 * Instead of replacing it (which causes "There can only be one UIApplication instance"),
 * we extend it using an Objective-C category to add push notification methods.
 * 
 * This approach is based on: https://gist.github.com/shigmas/62e9cf023303c03be49c4f1646e37051
 */

// Forward declare Qt's hidden app delegate
@interface QIOSApplicationDelegate : NSObject
@end

/**
 * Category that adds push notification support to Qt's app delegate
 */
@interface QIOSApplicationDelegate (StatusPushNotifications) <UNUserNotificationCenterDelegate>
@end

