#include "DOtherSide/StatusNotification/StatusOSNotification.h"

#ifdef Q_OS_MACOS

#import <AppKit/AppKit.h>

@interface NotificationDelegate : NSObject <NSUserNotificationCenterDelegate>
- (instancetype)initStatusOSNotification:(StatusOSNotification*) instance;
@end

class NotificationHelper
{
public:
    NotificationHelper(StatusOSNotification* instance) {
        delegate = [[NotificationDelegate alloc] initStatusOSNotification:instance];
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

void StatusOSNotification::initNotificationMacOs()
{
    if (!m_notificationHelper)
    {
        m_notificationHelper = new NotificationHelper(this);
    }
}

void StatusOSNotification::showNotificationMacOs(QString title, QString message, 
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

@implementation NotificationDelegate {
    StatusOSNotification* instance;
}

- (instancetype)initStatusOSNotification:(StatusOSNotification*)ins
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