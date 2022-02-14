#ifndef WALLETACCOUNTSSERVICE_H
#define WALLETACCOUNTSSERVICE_H

#include <QString>
#include <QMap>

#include "wallet_account.h"
#include "service_interface.h"

namespace Wallets
{

class Service : public ServiceInterface
{
private:
    void fetchAccounts();

    QMap<QString, WalletAccountDto> m_walletAccounts;

public:
    Service();
    ~Service() = default;

    void init() override;
    QList<WalletAccountDto> getWalletAccounts() override;
};
} // namespace Wallets

#endif // WALLETACCOUNTSERVICE_H
