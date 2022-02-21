#ifndef WALLETACCOUNTSSERVICE_H
#define WALLETACCOUNTSSERVICE_H

#include <QString>
#include <QMap>
#include <QObject>

#include "wallet_account.h"
#include "service_interface.h"

namespace Wallets
{

class Service : public ServiceInterface, public QObject
{
private:
    void fetchAccounts();
    void refreshAccounts();

    QMap<QString, WalletAccountDto> m_walletAccounts;

public:
    Service();
    ~Service() = default;

    void init() override;

    QList<WalletAccountDto> getWalletAccounts() override;
    QString generateNewAccount(const QString& password, const QString& accountName, const QString& color) override;
    QString addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color) override;
    QString addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color) override;
    QString addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color) override;
    void deleteAccount(const QString& address) override;

};
} // namespace Wallets

#endif // WALLETACCOUNTSERVICE_H
