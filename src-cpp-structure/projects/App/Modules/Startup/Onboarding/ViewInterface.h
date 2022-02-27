#pragma once

#include "Model.h"

#include <StatusServices/AccountsService>

#include <QtCore>

namespace Status::Modules::Startup::Onboarding
{
    class ViewInterface
    {
    public:
        virtual ~ViewInterface() = default;

        virtual QObject* getQObject() = 0;
        virtual void load() = 0;
        virtual Model* getModel() = 0;
        virtual void setAccountList(QVector<Item> accounts) = 0;
        virtual void importAccountError() = 0;
        virtual void setupAccountError() = 0;
        virtual void importAccountSuccess() = 0;
    };

    class ViewDelegateInterface
    {
    public:
        virtual void viewDidLoad() = 0;
        virtual void setSelectedAccountByIndex(const int index) = 0;
        virtual void storeSelectedAccountAndLogin(const QString& password) = 0;
        virtual const Accounts::GeneratedAccountDto& getImportedAccount() const = 0;
        virtual QString validateMnemonic(const QString& mnemonic) = 0;
        virtual void importMnemonic(const QString& mnemonic) = 0;
    };
}
