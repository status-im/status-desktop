#include "DOtherSide/Status/AppDelegate.h"

#include <QString>
#include <QUrl>
#include <QDebug>
#include <iostream>

#import <AppKit/NSApplication.h>
#import <AppKit/NSWindow.h>


@interface AppDelegate: NSObject <NSApplicationDelegate>
- (BOOL)application:(NSApplication *)application
continueUserActivity:(NSUserActivity *)userActivity
 restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *restorableObjects))restorationHandler;
@end

@implementation AppDelegate
- (BOOL)application:(NSApplication *)application 
        continueUserActivity:(NSUserActivity *)userActivity 
        restorationHandler:(void (^)(NSArray<id<NSUserActivityRestoring>> *))restorationHandler {
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

- (BOOL)applicationShouldHandleReopen:(NSApplication *)theApplication 
        hasVisibleWindows:(BOOL)visibleWindows
{   
    qWarning() << "<<< applicationShouldHandleReopen" << visibleWindows;
    auto window = theApplication.windows[0];

    if (visibleWindows) {
        [window orderFront:self];
    }
    else {
        [window makeKeyAndOrderFront:self];
    }

    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    NSApplication* app = notification.object;
    app.windows[0].releasedWhenClosed = YES;
    qWarning() << "<<< applicationDidFinishLaunching" << app.windows.count;

    // for (id const window in app.windows)
    // {
    //     // window.ReleasedWhenClosed = TRUE;
    //     [window releasedWhenClosed:TRUE]
    // }

    // [self reclaimResourcesForPort:notification.object];
}

- (BOOL)windowShouldClose:(NSWindow *)sender
{
    qWarning() << "<<< windowShouldClose";
    return YES;
}

@end

namespace app_delegate {

void install()
{
    NSApplication* applicationShared = [NSApplication sharedApplication];
    // applicationShared.windows[0].releasedWhenClosed = TRUE;
    qWarning() << "<<< created applicationShared";
    [applicationShared setDelegate:([[[AppDelegate alloc] init] autorelease])];
}

}
