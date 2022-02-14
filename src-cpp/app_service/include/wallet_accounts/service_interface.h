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
};

} // namespace Wallets

#endif // WALLETACCOUNTSSERVICEINTERFACE_H
