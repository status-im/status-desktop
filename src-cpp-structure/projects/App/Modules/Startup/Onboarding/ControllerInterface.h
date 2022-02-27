#pragma once

#include <StatusServices/AccountsService>

#include <QtCore>

namespace Status::Modules::Startup::Onboarding
{
    class ControllerInterface
    {
    public:
        virtual ~ControllerInterface() = default;

        virtual void init() = 0;
        virtual const QVector<Accounts::GeneratedAccountDto>& getGeneratedAccounts() const = 0;
        virtual void setSelectedAccountByIndex(const int index) = 0;
        virtual void storeSelectedAccountAndLogin(const QString& password) = 0;
        virtual const Accounts::GeneratedAccountDto& getImportedAccount() const = 0;
        virtual QString validateMnemonic(const QString& mnemonic) = 0;
        virtual void importMnemonic(const QString& mnemonic) = 0;
    };

    class ControllerDelegateInterface
    {
    public:
        virtual void importAccountError() = 0;
        virtual void setupAccountError() = 0;
        virtual void importAccountSuccess() = 0;
    };
}
