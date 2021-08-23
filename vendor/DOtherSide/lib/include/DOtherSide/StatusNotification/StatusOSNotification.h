#ifndef STATUS_OS_NOTIFICATION_H
#define STATUS_OS_NOTIFICATION_H

#include <QObject>
#include <QHash>

#ifdef Q_OS_WIN

#elif defined Q_OS_MACOS
class NotificationHelper;
#endif

class StatusOSNotification : public QObject
{
    Q_OBJECT

public:
    StatusOSNotification(QObject *parent = nullptr);
    ~StatusOSNotification();

    void showNotification(const QString& title, const QString& message, 
    const QString& identifier);

signals:
    void notificationClicked(QString identifier);

#ifdef Q_OS_WIN

#elif defined Q_OS_MACOS
private:
    void initNotificationMacOs();
    void showNotificationMacOs(QString title, QString message, QString identifier);

private:
    NotificationHelper *m_notificationHelper;
#endif
};

#endif
