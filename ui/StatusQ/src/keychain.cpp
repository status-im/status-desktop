#include "StatusQ/keychain.h"

Keychain::Keychain(QObject *parent) : QObject(parent) {

}

Keychain::~Keychain() {

}

QString Keychain::service() const
{
    return m_service;
}

void Keychain::setService(const QString &service)
{
    if (m_service == service) {
        return;
    }

    m_service = service;
    emit serviceChanged();
}

QString Keychain::reason() const
{
    return m_reason;
}

void Keychain::setReason(const QString &reason)
{
    if (m_reason == reason) {
        return;
    }

    m_reason = reason;
    emit reasonChanged();
}

bool Keychain::loading() const
{
    return m_loading;
}

void Keychain::setLoading(bool loading)
{
    if (m_loading == loading) {
        return;
    }

    m_loading = loading;
    emit loadingChanged();
}

#ifndef Q_OS_MACOS
bool Keychain::saveCredential(const QString &account, const QString &password) {
    Q_UNUSED(account);
    Q_UNUSED(password);
    return false;
}

bool Keychain::deleteCredential(const QString &account) {
    Q_UNUSED(account);
    return false;
}

QString Keychain::getCredential(const QString &account) {
    Q_UNUSED(account);
    return {};
}
#endif
