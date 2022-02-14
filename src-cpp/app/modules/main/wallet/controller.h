#ifndef WALLET_CONTROLLER_H
#define WALLET_CONTROLLER_H

#include <QObject>

#include "wallet_accounts/service_interface.h"
#include "interfaces/controller_interface.h"
#include "signals.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
class Controller : public QObject, IWalletController
{
    Q_OBJECT

public:
    explicit Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);
    ~Controller() = default;
    void init() override;

private:
    std::shared_ptr<Wallets::ServiceInterface> m_walletService;
};
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_CONTROLLER_H
