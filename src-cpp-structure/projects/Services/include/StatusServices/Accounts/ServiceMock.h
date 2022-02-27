#pragma once

#include "ServiceInterface.h"

#include <gmock/gmock.h>

namespace Status::Test
{
    class AccountsServiceMock final : public Accounts::ServiceInterface
    {
    public:
        virtual ~AccountsServiceMock() override {};

        MOCK_METHOD(void, init, (const QString&), (override));
        MOCK_METHOD(QVector<Accounts::AccountDto>, openedAccounts, (), (override));
        MOCK_METHOD(const QVector<Accounts::GeneratedAccountDto>&, generatedAccounts, (), (const, override));
        MOCK_METHOD(bool, setupAccount, (const QString&, const QString&), (override));
        MOCK_METHOD(const Accounts::AccountDto&, getLoggedInAccount, (), (const, override));
        MOCK_METHOD(const Accounts::GeneratedAccountDto&, getImportedAccount, (), (const, override));
        MOCK_METHOD(bool, isFirstTimeAccountLogin, (), (const, override));
        MOCK_METHOD(QString, validateMnemonic, (const QString&), (override));
        MOCK_METHOD(bool, importMnemonic, (const QString&), (override));
        MOCK_METHOD(QString, login, (Accounts::AccountDto, const QString&), (override));
        MOCK_METHOD(void, clear, (), (override));
        MOCK_METHOD(QString, generateAlias, (const QString&), (override));
        MOCK_METHOD(QString, generateIdenticon, (const QString&), (override));
        MOCK_METHOD(bool, verifyAccountPassword, (const QString&, const QString&), (override));
    };
}
