#ifndef STATUS_OS_NOTIFICATION_H
#define STATUS_OS_NOTIFICATION_H

#include <QObject>
#include <QHash>

#ifdef Q_OS_WIN
#include "windows.h"
#elif defined Q_OS_MACOS
class NotificationHelper;
#endif

namespace Status
{
    class OSNotification : public QObject
    {
        Q_OBJECT

    public:
        OSNotification(QObject *parent = nullptr);
        ~OSNotification();

        void showNotification(const QString& title, const QString& message, 
        const QString& identifier);

        void showIconBadgeNotification(int notificationsCount);

    signals:
        void notificationClicked(QString identifier);

    #ifdef Q_OS_WIN
    public:
        QHash<uint, QString> m_identifiers;

    private:
        bool initNotificationWin();
        void stringToLimitedWCharArray(QString in, wchar_t* target, int maxLength);

    private:
        HWND m_hwnd;

    #elif defined Q_OS_MACOS
    private:
        void initNotificationMacOs();
        void showNotificationMacOs(QString title, QString message, QString identifier);
        void showIconBadgeNotificationMacOs(int notificationsCount);

    private:
        NotificationHelper *m_notificationHelper;
    #endif
    };
}

#endif
