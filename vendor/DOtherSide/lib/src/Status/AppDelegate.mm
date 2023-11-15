#include "DOtherSide/Status/AppDelegate.h"

#include <QString>
#include <QUrl>
#include <QDebug>

#import <AppKit/NSApplication.h>
#import <objc/runtime.h>

@interface StatusApplicationDelegate: NSObject <NSApplicationDelegate>
- (BOOL)application:(NSApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *restorableObjects))restorationHandler;
@end

@implementation StatusApplicationDelegate
- (BOOL)application:(NSApplication *)application 
        continueUserActivity:(NSUserActivity *)userActivity 
        restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *))restorationHandler {
    if (userActivity.activityType == NSUserActivityTypeBrowsingWeb) {
        NSURL *url = userActivity.webpageURL;
        if (!url)
           return FALSE;
        QUrl deeplink = QUrl::fromNSURL(url);

        // TODO #12434: Check if WalletConnect link and redirect the workflow to Pair or Authenticate

        // TODO #12245: set it to nim
        return TRUE;
    }
    return FALSE;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    qDebug() << "StatusApplicationDelegate::applicationDidFinishLaunching";
}

@end

namespace app_delegate {

void swizzle_appdelegate_method(SEL selector) {
    Class originalClass = [NSApplication sharedApplication].delegate.class;
    Class swizzledClass = [StatusApplicationDelegate class];

    Method originalMethod = class_getInstanceMethod(originalClass, selector);
    Method swizzledMethod = class_getInstanceMethod(swizzledClass, selector);

    method_exchangeImplementations(originalMethod, swizzledMethod);
}

void install()
{
    /*
        A simple solution to implement custom ApplicationDelegate would be to call `NSApplication::setDelegate`
        with an instantse of StatusApplicationDelegate. But this will override Qt's ApplicationDelegate implementation
        `QCocoaApplicationDelegate` (qtbase/src/plugins/platforms/cocoa/qcocoaapplicationdelegate.mm).

        Overriding breaks some Qt events like `QApplicationStateChangeEvent`. And I suppose (and pretty sure) 
        that this might also break other things.

        Would be cool to simply inherit `QCocoaApplicationDelegate`, but it's only available in Qt's sources.

        The solution here is to use "method swizzling" technique.
        We replace the method of a class with own implementation.

        In future we could contribute to Qt to add "continueUserActivity" event.
    */
    swizzle_appdelegate_method(@selector(applicationDidFinishLaunching:)); // for testing purposes (ApplicationDelegate works, method swizzled)
    swizzle_appdelegate_method(@selector(application:continueUserActivity:restorationHandler:)); // for Univeral Links support
}

}
