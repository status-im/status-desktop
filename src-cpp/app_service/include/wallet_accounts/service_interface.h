#ifndef WALLETACCOUNTSSERVICEINTERFACE_H
#define WALLETACCOUNTSSERVICEINTERFACE_H

#include <QJsonValue>
#include <QList>
#include <memory>

#include "../app_service.h"
#include "wallet_account.h"

namespace Wallets
{

class ServiceInterface : public AppService
{
public:
    virtual QList<WalletAccountDto> getWalletAccounts() = 0;
    virtual QString generateNewAccount(const QString& password, const QString& accountName, const QString& color) = 0;
    virtual QString addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color) = 0;
    virtual QString addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color) = 0;
    virtual QString addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color) = 0;
    virtual void deleteAccount(const QString& address) = 0;
};

} // namespace Wallets

#endif // WALLETACCOUNTSSERVICEINTERFACE_H
