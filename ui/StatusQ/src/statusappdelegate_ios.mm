#import <StatusQ/statusappdelegate_ios.h>
#import <UserNotifications/UserNotifications.h>

#include <QDebug>
#include <QString>
#include <StatusQ/pushnotification_ios.h>

/**
 * Category implementation that extends Qt's QIOSApplicationDelegate
 * 
 * These methods will be automatically called by iOS when the app delegate
 * receives push notification events. No need to replace Qt's delegate!
 */
 
@implementation QIOSApplicationDelegate (StatusPushNotifications)

/**
 * Called when the category is loaded - verifies category is being compiled/linked
 */
+ (void)load
{
    NSLog(@"========================================");
    NSLog(@"[StatusPushNotifications] +load method called!");
    NSLog(@"[StatusPushNotifications] Category IS being loaded!");
    NSLog(@"========================================");
}

/**
 * Override didFinishLaunchingWithOptions to register for push notifications
 * This is called by iOS when the app finishes launching
 * Based on: https://gist.github.com/shigmas/62e9cf023303c03be49c4f1646e37051
 */
- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSLog(@"========================================");
    NSLog(@"[StatusPushNotifications] didFinishLaunchingWithOptions CALLED!");
    NSLog(@"========================================");
    NSLog(@"[StatusPushNotifications] didFinishLaunchingWithOptions called!");
    
    // Set ourselves as the UNUserNotificationCenter delegate
    [UNUserNotificationCenter currentNotificationCenter].delegate = self;
    NSLog(@"[StatusPushNotifications] Set as UNUserNotificationCenter delegate");
    
    // Request notification authorization
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge;
    
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError *error) {
        if (error) {
            NSLog(@"[StatusPushNotifications] Permission error: %@", error.localizedDescription);
            return;
        }
        
        if (granted) {
            NSLog(@"[StatusPushNotifications] Permission granted, registering for remote notifications...");
            dispatch_async(dispatch_get_main_queue(), ^{
                [application registerForRemoteNotifications];
                NSLog(@"[StatusPushNotifications] registerForRemoteNotifications called from category");
            });
        } else {
            NSLog(@"[StatusPushNotifications] Permission denied by user");
        }
    }];
    
    return YES;
}

#pragma mark - Push Notification Delegate Methods

/**
 * Called when APNS token is successfully generated
 * This method is automatically invoked by iOS on the app delegate
 */
- (void)application:(UIApplication *)application 
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"[StatusPushNotifications] *** didRegisterForRemoteNotificationsWithDeviceToken CALLED ***");
    NSLog(@"[StatusPushNotifications] Token data length: %lu bytes", (unsigned long)deviceToken.length);
    
    // Convert NSData token to hex string
    const unsigned char *bytes = (const unsigned char *)[deviceToken bytes];
    NSMutableString *hexToken = [NSMutableString stringWithCapacity:(deviceToken.length * 2)];
    
    for (NSUInteger i = 0; i < deviceToken.length; i++) {
        [hexToken appendFormat:@"%02x", bytes[i]];
    }
    
    NSLog(@"[StatusPushNotifications] APNS token received: %@", hexToken);
    
    // Forward to C++ layer
    PushNotificationIOS::instance()->onAPNSTokenReceived(
        QString::fromNSString(hexToken)
    );
}

/**
 * Called if APNS token registration fails
 */
- (void)application:(UIApplication *)application 
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"[StatusPushNotifications] Failed to register for remote notifications: %@", error.localizedDescription);
}

/**
 * Called when a remote notification is received
 * Works both when app is in foreground and background
 */
- (void)application:(UIApplication *)application 
    didReceiveRemoteNotification:(NSDictionary *)userInfo
    fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"[StatusPushNotifications] Remote notification received");
    NSLog(@"[StatusPushNotifications] Payload: %@", userInfo);
    
    // Extract encrypted data from push notification
    NSDictionary *data = userInfo[@"data"];
    
    if (data) {
        NSString *encryptedMessage = data[@"encryptedMessage"];
        NSString *chatId = data[@"chatId"];
        NSString *publicKey = data[@"publicKey"];
        
        if (encryptedMessage && chatId && publicKey) {
            NSLog(@"[StatusPushNotifications] Forwarding to C++ layer");
            
            // Forward to C++ layer
            PushNotificationIOS::instance()->onPushNotificationReceived(
                QString::fromNSString(encryptedMessage),
                QString::fromNSString(chatId),
                QString::fromNSString(publicKey)
            );
            
            completionHandler(UIBackgroundFetchResultNewData);
            return;
        }
    }
    
    NSLog(@"[StatusPushNotifications] No valid data in notification");
    completionHandler(UIBackgroundFetchResultNoData);
}

#pragma mark - UNUserNotificationCenterDelegate

/**
 * Called when a notification is received while app is in foreground
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler
{
    NSLog(@"[StatusPushNotifications] Notification received in foreground");
    
    // Show notification even when app is in foreground
    if (@available(iOS 14.0, *)) {
        completionHandler(UNNotificationPresentationOptionBanner | 
                         UNNotificationPresentationOptionSound |
                         UNNotificationPresentationOptionBadge);
    } else {
        completionHandler(UNNotificationPresentationOptionAlert | 
                         UNNotificationPresentationOptionSound |
                         UNNotificationPresentationOptionBadge);
    }
}

/**
 * Called when user taps a notification
 */
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
         withCompletionHandler:(void (^)(void))completionHandler
{
    NSLog(@"[StatusPushNotifications] User tapped notification");
    
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    NSString *identifier = userInfo[@"identifier"];
    
    if (identifier) {
        NSLog(@"[StatusPushNotifications] Notification identifier: %@", identifier);
        // TODO: Handle notification tap (deep link to chat, etc.)
        // emit PushNotificationIOS::instance()->notificationTapped(QString::fromNSString(identifier));
    }
    
    completionHandler();
}

@end

