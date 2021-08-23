#include "DOtherSide/StatusNotification/StatusOSNotification.h"

StatusOSNotification::StatusOSNotification(QObject *parent)
    : QObject(parent)
{
#ifdef Q_OS_WIN

#elif defined Q_OS_MACOS
    m_notificationHelper = nullptr;
    initNotificationMacOs();
#endif
}

StatusOSNotification::~StatusOSNotification()
{
#ifdef Q_OS_MACOS
    if(m_notificationHelper)
    {
        delete m_notificationHelper;
    }
#endif
}

void StatusOSNotification::showNotification(const QString& title, 
    const QString& message, const QString& identifier)
{
#ifdef Q_OS_WIN

#elif defined Q_OS_MACOS
    showNotificationMacOs(title, message, identifier);
#endif
}