#pragma once

#include "AccountDto.h"
#include "GeneratedAccountDto.h"

namespace Status::Accounts
{
    class ServiceInterface
    {
    public:

        virtual ~ServiceInterface() = default;

        virtual void init(const QString& statusgoDataDir) = 0;

        [[nodiscard]] virtual QVector<AccountDto> openedAccounts() = 0;

        [[nodiscard]] virtual const QVector<GeneratedAccountDto>& generatedAccounts() const = 0;

        virtual bool setupAccount(const QString& accountId, const QString& password) = 0;

        [[nodiscard]] virtual const AccountDto& getLoggedInAccount() const = 0;

        [[nodiscard]] virtual const GeneratedAccountDto& getImportedAccount() const = 0;

        [[nodiscard]] virtual bool isFirstTimeAccountLogin() const = 0;

        virtual QString validateMnemonic(const QString& mnemonic) = 0;

        virtual bool importMnemonic(const QString& mnemonic) = 0;

        virtual QString login(AccountDto account, const QString& password) = 0;

        virtual void clear() = 0;

        virtual QString generateAlias(const QString& publicKey) = 0;

        virtual QString generateIdenticon(const QString& publicKey) = 0;

        virtual bool verifyAccountPassword(const QString& account, const QString& password) = 0;
    };
}
