#pragma once

#include <QString>
#include <QMap>
#include <QObject>

#include "service_interface.h"
#include "wallet_account.h"

namespace Wallets
{

class Service : public QObject, public ServiceInterface 
{
private:
    void fetchAccounts();
    void refreshAccounts();

    QMap<QString, WalletAccountDto> m_walletAccounts;

public:
    void init() override;

    QList<WalletAccountDto> getWalletAccounts() override;
    QString generateNewAccount(const QString& password, const QString& accountName, const QString& color) override;
    QString addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color) override;
    QString addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color) override;
    QString addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color) override;
    void deleteAccount(const QString& address) override;

};
} // namespace Wallets
