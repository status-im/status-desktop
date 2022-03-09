#ifndef WALLETACCOUNTSSERVICE_H
#define WALLETACCOUNTSSERVICE_H

#include <QMap>
#include <QString>

#include "service_interface.h"
#include "wallet_account.h"

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
