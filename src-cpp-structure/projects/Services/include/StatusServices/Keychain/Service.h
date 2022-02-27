#pragma once

#include "ServiceInterface.h"
#include "../src/Keychain/KeychainManager.h"

namespace Status::Keychain
{
    class Service : public QObject,
            public ServiceInterface
    {
        Q_OBJECT

    public:
        explicit Service();

        void storePassword(const QString& username, const QString& password) override;

        void tryToObtainPassword(const QString& username) override;

        void subscribe(std::shared_ptr<Listener> listener) override;

    private slots:
        void onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription);
        void onKeychainManagerSuccess(const QString& data);

    private:
        QVector<std::shared_ptr<Listener>> m_listeners;
        std::unique_ptr<KeychainManager> m_keychainManager;
    };
}
