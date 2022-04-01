#include "DOtherSide/Status/OSNotification.h"

#include <QString>

#ifdef Q_OS_MACOS

#import <AppKit/AppKit.h>

using namespace Status;

@interface NotificationDelegate : NSObject <NSUserNotificationCenterDelegate>
- (instancetype)initOSNotification:(OSNotification*) instance;
@end

class NotificationHelper
{
public:
    NotificationHelper(OSNotification* instance) {
        delegate = [[NotificationDelegate alloc] initOSNotification:instance];
        NSUserNotificationCenter.defaultUserNotificationCenter.delegate = delegate;
    }

    ~NotificationHelper() {
        NSUserNotificationCenter *center = NSUserNotificationCenter.defaultUserNotificationCenter;
        if (center.delegate == delegate)
            center.delegate = nil;
        [delegate release];
    }

    NotificationDelegate* delegate;
};

void OSNotification::initNotificationMacOs()
{
    if (!m_notificationHelper)
    {
        m_notificationHelper = new NotificationHelper(this);
    }
}

void OSNotification::showNotificationMacOs(QString title, QString message, 
    QString identifier)
{
    if (!m_notificationHelper)
        return;

    NSUserNotification* notification = [[NSUserNotification alloc] init];
    notification.title = title.toNSString();
    notification.informativeText = message.toNSString();
    notification.soundName = NSUserNotificationDefaultSoundName;
    notification.hasActionButton = false;
    notification.identifier = identifier.toNSString();
    
    NSUserNotificationCenter* center = NSUserNotificationCenter.defaultUserNotificationCenter;
    center.delegate = m_notificationHelper->delegate;
    [center deliverNotification:notification];
    [notification release];
}

void OSNotification::showIconBadgeNotificationMacOs(int notificationsCount)
{
    QString notificationsString; // empty string will clear the badge
    if (notificationsCount > 0 && notificationsCount < 10) {
        notificationsString = QString::number(notificationsCount);
    } else if (notificationsCount >= 10) {
        notificationsString = "9+";
    }
    [[NSApp dockTile] setBadgeLabel:notificationsString.toNSString()];
}

@implementation NotificationDelegate {
    OSNotification* instance;
}

- (instancetype)initOSNotification:(OSNotification*)ins
{
    self = [super init];
    if (self) {
        instance = ins;
    }
    return self;
}

- (void) userNotificationCenter:(NSUserNotificationCenter*)center didActivateNotification:(NSUserNotification*)notification 
{
    const char* identifier = [notification.identifier UTF8String];
    [center removeDeliveredNotification:notification];
    
    instance->notificationClicked(identifier);
}
@end

#endif