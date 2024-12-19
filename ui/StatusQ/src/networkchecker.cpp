#include "StatusQ/networkchecker.h"

namespace {
using namespace std::chrono_literals;

constexpr static auto checkInterval = 30s;
}

NetworkChecker::NetworkChecker(QObject *parent)
    : QObject(parent)
{
    manager.setTransferTimeout();
    connect(&manager, &QNetworkAccessManager::finished, this, &NetworkChecker::onFinished);
    connect(&timer, &QTimer::timeout, this, &NetworkChecker::checkNetwork);
}

bool NetworkChecker::isOnline() const
{
    return online;
}

void NetworkChecker::checkNetwork()
{
    QNetworkRequest request(QUrl(QStringLiteral("http://fedoraproject.org/static/hotspot.txt")));
    manager.get(request);
    setChecking(true);
}

void NetworkChecker::classBegin()
{
    // empty on purpose
}

void NetworkChecker::componentComplete() {
    updateRegularCheck(active);
}

void NetworkChecker::onFinished(QNetworkReply *reply)
{
    setChecking(false);
    const auto wasOnline = online;
    online = (reply->error() == QNetworkReply::NoError);
    reply->deleteLater();

    if (wasOnline != online) {
        emit isOnlineChanged(online);
    }
}

bool NetworkChecker::isActive() const
{
    return active;
}

void NetworkChecker::setActive(bool active)
{
    if (active == this->active)
        return;

    this->active = active;
    emit activeChanged(active);

    updateRegularCheck(active);
}

void NetworkChecker::updateRegularCheck(bool active)
{
    if (active) {
        checkNetwork();
        timer.start(checkInterval);
    } else {
        timer.stop();
    }
}

bool NetworkChecker::checking() const
{
    return m_checking;
}

void NetworkChecker::setChecking(bool checking)
{
    if (m_checking == checking)
        return;

    m_checking = checking;
    emit checkingChanged();
}
