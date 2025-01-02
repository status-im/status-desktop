#pragma once

#include <QNetworkReply>
#include <QObject>
#include <QQmlParserStatus>
#include <QTimer>

class QNetworkAccessManager;

/// Checks if the internet connection is available, when active.
/// It checks the connection every 30 seconds as long as the \c active property is \c true (by default it is)
class NetworkChecker : public QObject, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(bool isOnline READ isOnline NOTIFY isOnlineChanged FINAL)
    Q_PROPERTY(bool active READ isActive WRITE setActive NOTIFY activeChanged FINAL)
    Q_PROPERTY(bool checking READ checking NOTIFY checkingChanged FINAL)

public:
    explicit NetworkChecker(QObject *parent = nullptr);
    bool isOnline() const;

    bool isActive() const;
    void setActive(bool active);

    Q_INVOKABLE void checkNetwork();

protected:
    void classBegin() override;
    void componentComplete() override;

signals:
    void isOnlineChanged(bool online);
    void activeChanged(bool active);
    void checkingChanged();

private:
    QNetworkAccessManager manager;
    QTimer timer;
    bool online = false;
    bool active = true;

    void onFinished(QNetworkReply *reply);
    void updateRegularCheck(bool active);

    bool m_checking{false};
    bool checking() const;
    void setChecking(bool checking);
};
