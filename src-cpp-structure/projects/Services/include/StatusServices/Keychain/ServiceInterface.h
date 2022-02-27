#pragma once

#include <QtCore>

namespace Status::Keychain
{
    const QString ErrorTypeAuthentication = "authentication";
    const QString ErrorTypeKeychain = "keychain";

    class Listener
    {
    public:

        virtual ~Listener() = default;

        virtual void onKeychainManagerError(const QString& errorType, const int errorCode, const QString& errorDescription) = 0;
        virtual void onKeychainManagerSuccess(const QString& data) = 0;
    };

    class ServiceInterface
    {
    public:

        virtual ~ServiceInterface() = default;

        virtual void storePassword(const QString& username, const QString& password) = 0;

        virtual void tryToObtainPassword(const QString& username) = 0;

        virtual void subscribe(std::shared_ptr<Listener> listener) = 0;
    };
}
