#include "DOtherSide/Status/AppDelegate.h"

#include <QString>
#include <QUrl>

#import <AppKit/NSApplication.h>


@interface AppDelegate: NSObject <NSApplicationDelegate>
- (BOOL)application:(NSApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *restorableObjects))restorationHandler;
@end

@implementation AppDelegate
- (BOOL)application:(NSApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *))restorationHandler {
    if (userActivity.activityType == NSUserActivityTypeBrowsingWeb) {
        NSURL *url = userActivity.webpageURL;
        if (!url) {
           return FALSE;
        }
        QUrl deeplink = QUrl::fromNSURL(url);
        // set it to nim
        return TRUE;
    }
    return FALSE;
}

@end

namespace app_delegate {

void install()
{
    NSApplication* applicationShared = [NSApplication sharedApplication];
    [applicationShared setDelegate:([[[AppDelegate alloc] init] autorelease])];
}

}