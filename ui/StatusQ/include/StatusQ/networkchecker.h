#pragma once

#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QObject>
#include <QTimer>

#include <chrono>

using namespace std::chrono_literals;

/// Checks if the internet connection is available, when active.
/// It checks the connection every 30 seconds as long as the \c active property is \c true.
class NetworkChecker : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool isOnline READ isOnline NOTIFY isOnlineChanged)
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged)

public:
    explicit NetworkChecker(QObject* parent = nullptr);
    bool isOnline() const;

    bool isActive() const;
    void setActive(bool active);

signals:
    void isOnlineChanged(bool online);
    void activeChanged(bool active);

private:
    QNetworkAccessManager manager;
    QTimer timer;
    bool online = false;
    bool active = true;
    constexpr static std::chrono::milliseconds checkInterval = 30s;

    void checkNetwork();
    void onFinished(QNetworkReply* reply);
    void updateRegularCheck(bool active);
};