#include "StatusServices/Keychain/Service.h"

#include "KeychainManager.h"

using namespace Status::Keychain;

Service::Service() : QObject(nullptr)
  , m_keychainManager(std::make_unique<KeychainManager>("StatusDesktop", "authenticate you"))
{
    connect(m_keychainManager.get(), &KeychainManager::success, this, &Service::onKeychainManagerSuccess, Qt::QueuedConnection);
    connect(m_keychainManager.get(), &KeychainManager::error, this, &Service::onKeychainManagerError, Qt::QueuedConnection);
}

void Service::storePassword(const QString& username, const QString& password)
{
    m_keychainManager->storeDataAsync(username, password);
}

void Service::tryToObtainPassword(const QString& username)
{
    m_keychainManager->readDataAsync(username);
}

void Service::subscribe(std::shared_ptr<Listener> listener)
{
    m_listeners.append(std::move(listener));
}

void Service::onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription)
{
    // This slot is called in case an error occured while we're dealing with
    // KeychainManager. So far we're just logging the error.
    qWarning() << "KeychainManager stopped, code: " << errorCode << "  desc: " << errorDescription;

    for(const auto& it : m_listeners)
    {
        it->onKeychainManagerError(errorType, errorCode, errorDescription);
    }
}

void Service::onKeychainManagerSuccess(const QString& data)
{
    for(const auto& it : m_listeners)
    {
        it->onKeychainManagerSuccess(data);
    }
}
