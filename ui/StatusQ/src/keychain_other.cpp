#include "StatusQ/keychain.h"

Keychain::~Keychain() = default;

void Keychain::requestSaveCredential(const QString &reason, const QString &account, const QString &password)
{
    Q_UNUSED(account);
    Q_UNUSED(password);

    qWarning() << "Keychain::requestSaveCredential is intended to be called only on MacOS.";

    emit this->saveCredentialRequestCompleted(Keychain::StatusNotSupported);
}

void Keychain::requestDeleteCredential(const QString &reason, const QString &account)
{
    Q_UNUSED(account);

    qWarning() << "Keychain::requestDeleteCredential is intended to be called only on MacOS.";

    emit deleteCredentialRequestCompleted(Keychain::StatusNotSupported);
}

void Keychain::requestGetCredential(const QString &reason, const QString &account)
{
    Q_UNUSED(account);

    qWarning() << "Keychain::requestGetCredential is intended to be called only on MacOS.";

    emit getCredentialRequestCompleted(Keychain::StatusNotSupported, "");
}

void Keychain::cancelActiveRequest()
{
    qWarning() << "Keychain::cancelActiveRequest is intended to be called only on MacOS.";
}
