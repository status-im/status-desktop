#include "StatusQ/keychain.h"

#include <QDebug>

Keychain::Keychain(QObject *parent) : QObject(parent)
{}

#ifndef Q_OS_MACOS
Keychain::~Keychain() = default;
#endif

QString Keychain::service() const
{
    return m_service;
}

void Keychain::setService(const QString &service)
{
    if (m_service == service)
        return;

    m_service = service;
    emit serviceChanged();
}

QString Keychain::reason() const
{
    return m_reason;
}

void Keychain::setReason(const QString &reason)
{
    if (m_reason == reason)
        return;

    m_reason = reason;
    emit reasonChanged();
}

bool Keychain::loading() const
{
    return m_loading;
}

void Keychain::setLoading(bool loading)
{
    if (m_loading == loading)
        return;

    m_loading = loading;
    emit loadingChanged();
}

#ifndef Q_OS_MACOS
void Keychain::requestSaveCredential(const QString& account, const QString& password)
{
    Q_UNUSED(account);
    Q_UNUSED(password);
    qWarning() << "Keychain::requestSaveCredential is intended to be called only on MacOS.";
    emit saveCredentialRequestCompleted(Keychain::StatusNotSupported);
}

void Keychain::requestDeleteCredential(const QString& account)
{
    Q_UNUSED(account);
    qWarning() << "Keychain::requestDeleteCredential is intended to be called only on MacOS.";
    emit deleteCredentialRequestCompleted(Keychain::StatusNotSupported);
}

void Keychain::requestGetCredential(const QString& account)
{
    Q_UNUSED(account);
    qWarning() << "Keychain::requestGetCredential is intended to be called only on MacOS.";
    emit getCredentialRequestCompleted(Keychain::StatusNotSupported, "");
}

void Keychain::cancelActiveRequest()
{
    qWarning() << "Keychain::cancelActiveRequest is intended to be called only on MacOS.";
}
#endif
