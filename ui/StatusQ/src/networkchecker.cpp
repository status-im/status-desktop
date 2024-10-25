#include "StatusQ/networkchecker.h"

NetworkChecker::NetworkChecker(QObject* parent)
    : QObject(parent)
{
    connect(&manager, &QNetworkAccessManager::finished, this, &NetworkChecker::onFinished);
    connect(&timer, &QTimer::timeout, this, &NetworkChecker::checkNetwork);

    updateRegularCheck(active);
}

bool NetworkChecker::isOnline() const
{
    return online;
}

void NetworkChecker::checkNetwork()
{
    QNetworkRequest request(QUrl(QStringLiteral("http://fedoraproject.org/static/hotspot.txt")));
    manager.get(request);
}

void NetworkChecker::onFinished(QNetworkReply* reply)
{
    bool wasOnline = online;
    online = (reply->error() == QNetworkReply::NoError);
    reply->deleteLater();

    if(wasOnline != online)
    {
        emit isOnlineChanged(online);
    }
}

bool NetworkChecker::isActive() const
{
    return active;
}

void NetworkChecker::setActive(bool active)
{
    if(active == this->active) return;

    this->active = active;
    emit activeChanged(active);

    updateRegularCheck(active);
}

void NetworkChecker::updateRegularCheck(bool active)
{
    if(active)
    {
        checkNetwork();
        timer.start(checkInterval);
    }
    else
    {
        timer.stop();
    }
}