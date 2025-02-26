#include "StatusQ/keychain.h"

#include <QDebug>

Keychain::Keychain(QObject *parent) : QObject(parent) {}

Keychain::~Keychain() = default;

bool Keychain::available() const
{
    return false;
}

Keychain::Status Keychain::saveCredential(const QString &account, const QString &password)
{
    Q_UNUSED(account);
    Q_UNUSED(password);

    qWarning() << "Keychain::saveCredential is intended to be called only on MacOS.";

    return Keychain::StatusNotSupported;
}

Keychain::Status Keychain::deleteCredential(const QString &account)
{
    Q_UNUSED(account);

    qWarning() << "Keychain::deleteCredential is intended to be called only on MacOS.";

    return Keychain::StatusNotSupported;
}

void Keychain::requestGetCredential(const QString &reason, const QString &account)
{
    Q_UNUSED(account);

    qWarning() << "Keychain::requestGetCredential is intended to be called only on MacOS.";

    emit getCredentialRequestCompleted(Keychain::StatusNotSupported, {});
}

Keychain::Status Keychain::hasCredential(const QString &account) const
{
    Q_UNUSED(account);

    return Keychain::StatusNotSupported;
}

Keychain::Status Keychain::updateCredential(const QString &account, const QString &password)
{
    Q_UNUSED(account);
    Q_UNUSED(password);

    return Keychain::StatusNotSupported;
}

void Keychain::cancelActiveRequest()
{
    qWarning() << "Keychain::cancelActiveRequest is intended to be called only on MacOS.";
}
