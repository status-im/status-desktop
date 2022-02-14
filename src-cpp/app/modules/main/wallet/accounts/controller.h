#ifndef WALLET_ACCOUNT_CONTROLLER_H
#define WALLET_ACCOUNT_CONTROLLER_H

#include <QObject>

#include "wallet_accounts/wallet_account.h"
#include "wallet_accounts/service_interface.h"
#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
class Controller : public QObject, IAccountsController
{
    Q_OBJECT

public:
    explicit Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);
    ~Controller() = default;

    void init() override;

    QList<Wallets::WalletAccountDto> getWalletAccounts();

private:
    std::shared_ptr<Wallets::ServiceInterface> m_walletServicePtr;
};
} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_ACCOUNT_CONTROLLER_H
