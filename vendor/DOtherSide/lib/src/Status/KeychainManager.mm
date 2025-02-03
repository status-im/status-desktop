#include "DOtherSide/Status/KeychainManager.h"

#include <QEventLoop>
using namespace Status;

QString KeychainManager::readDataSyncMacOs(const QString& key) const
{
    QString storedData;
    QEventLoop loop;

    auto onAuthenticationSuccess = [this, &key](){
        m_keychain->readItem(key);
    };

    auto onReadItemSuccess = [&loop, &storedData](QString data){
        storedData = data;
        loop.quit();
    };

    connect(m_localAuth.get(), &LocalAuthentication::success, onAuthenticationSuccess);
    
    connect(m_keychain.get(), &Keychain::success, onReadItemSuccess);

    connect(m_localAuth.get(), &LocalAuthentication::error, [this, &loop](int code, const QString& errorString){
        Q_UNUSED(code)
        Q_UNUSED(errorString)
        loop.quit();
    });

    connect(m_keychain.get(), &Keychain::error, [this, &loop](int code, const QString& errorString){
        Q_UNUSED(code)
        Q_UNUSED(errorString)
        loop.quit();
    });

    m_localAuth->runAuthentication(m_authenticationReason);
    loop.exec();
    
    return storedData;
}

void KeychainManager::readDataAsyncMacOs(const QString& key)
{
    auto readAction = [this, key](){
        m_keychain->readItem(key);
    };

    process(readAction);
}

void KeychainManager::storeDataAsyncMacOs(const QString& key, const QString& data)
{
    auto writeAction = [this, key, data](){
        m_keychain->writeItem(key, data);
    };

    process(writeAction);
}

void KeychainManager::deleteDataAsyncMacOs(const QString& key)
{
    auto deleteAction = [this, key](){
        m_keychain->deleteItem(key);
    };

    process(deleteAction);
}

void KeychainManager::process(const std::function<void()> action)
{
    disconnect(m_actionConnection);
    m_actionConnection = connect(m_localAuth.get(), &LocalAuthentication::success, action);

    m_localAuth->runAuthentication(m_authenticationReason);
}