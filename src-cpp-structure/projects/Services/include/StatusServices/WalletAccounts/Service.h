#pragma once

#include "ServiceInterface.h"

namespace Status::WalletAccount
{
    class Service : public ServiceInterface
    {
    public:
        Service();

        void init() override;

        [[nodiscard]] QList<WalletAccountDto> getWalletAccounts() override;

        QString generateNewAccount(const QString& password, const QString& accountName, const QString& color) override;

        QString addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                          const QString& accountName, const QString& color) override;

        QString addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName,
                                    const QString& color) override;

        QString addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color) override;

        void deleteAccount(const QString& address) override;

    private:
        void fetchAccounts();
        void refreshAccounts();

    private:
        QMap<QString, WalletAccountDto> m_walletAccounts;
    };
}
