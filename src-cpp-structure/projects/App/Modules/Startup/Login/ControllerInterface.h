#pragma once

#include <StatusServices/AccountsService>
#include <StatusServices/KeychainService>

#include <QtCore>

namespace Status::Modules::Startup::Login
{
    class ControllerInterface
    {
    public:
        virtual ~ControllerInterface() = default;

        virtual void init() = 0;
        virtual QVector<Accounts::AccountDto> getOpenedAccounts() const = 0;
        virtual void setSelectedAccountKeyUid(const QString& keyUid) = 0;
        virtual void login(const QString& password) = 0;
    };

    class ControllerDelegateInterface
    {
    public:
        virtual void emitAccountLoginError(const QString& error) = 0;
        virtual void emitObtainingPasswordError(const QString& errorDescription) = 0;
        virtual void emitObtainingPasswordSuccess(const QString& password) = 0;
    };
}
