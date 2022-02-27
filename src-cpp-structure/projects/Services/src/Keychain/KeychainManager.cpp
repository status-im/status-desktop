#include "KeychainManager.h"

using namespace Status::Keychain;

KeychainManager::KeychainManager(const QString& service, 
    const QString& authenticationReason, QObject* parent)
    : QObject(parent)
{
#ifdef Q_OS_MACOS
    m_authenticationReason = authenticationReason;
    m_localAuth = std::unique_ptr<LocalAuthentication>(new LocalAuthentication());
    m_keychain = std::unique_ptr<Keychain>(new Keychain(service));

    connect(m_localAuth.get(), &LocalAuthentication::error, [this](int code, const QString& errorString){
        emit error("authentication", code, errorString);
    });

    connect(m_keychain.get(), &Keychain::success, this, &KeychainManager::success);
    connect(m_keychain.get(), &Keychain::error, [this](int code, const QString& errorString){
        emit error("keychain", code, errorString);
    });
#else
    // Marked params unused until we need them for Win/Linux.
    Q_UNUSED(authenticationReason);
    Q_UNUSED(service);
#endif
}

QString KeychainManager::readDataSync(const QString& key) const
{
#ifdef Q_OS_MACOS
    return readDataSyncMacOs(key);
#endif
    
    return QString();
}

void KeychainManager::readDataAsync(const QString& key)
{
#ifdef Q_OS_MACOS
    readDataAsyncMacOs(key);
#endif
}

void KeychainManager::storeDataAsync(const QString& key, const QString& data)
{
#ifdef Q_OS_MACOS
    storeDataAsyncMacOs(key, data);
#endif
}

void KeychainManager::deleteDataAsync(const QString& key)
{
#ifdef Q_OS_MACOS
    deleteDataAsyncMacOs(key);
#endif
}
