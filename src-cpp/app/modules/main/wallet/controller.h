#pragma once

#include <QObject>

#include "interfaces/controller_interface.h"
#include "signals.h"
#include "wallet_accounts/service_interface.h"

namespace Modules::Main::Wallet
{
class Controller : public QObject, public IController
{
    Q_OBJECT

public:
    explicit Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent = nullptr);
    void init() override;

private:
    std::shared_ptr<Wallets::ServiceInterface> m_walletService;
};
} // namespace Modules::Main::Wallet
