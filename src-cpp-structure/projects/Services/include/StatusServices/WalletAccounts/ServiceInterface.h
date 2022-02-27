#pragma once

#include "WalletAccountDto.h"

namespace Status::WalletAccount
{
    class ServiceInterface
    {
    public:

        virtual ~ServiceInterface() = default;

        virtual void init() = 0;

        [[nodiscard]] virtual QList<WalletAccountDto> getWalletAccounts() = 0;

        virtual QString generateNewAccount(const QString& password, const QString& accountName,
                                           const QString& color) = 0;

        virtual QString addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                                  const QString& accountName, const QString& color) = 0;

        virtual QString addAccountsFromSeed(const QString& seedPhrase, const QString& password,
                                            const QString& accountName, const QString& color) = 0;

        virtual QString addWatchOnlyAccount(const QString& address, const QString& accountName ,
                                            const QString& color) = 0;

        virtual void deleteAccount(const QString& address) = 0;
    };
}
