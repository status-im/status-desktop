#include <QDebug>

#include "controller_wallet.h"

namespace Modules::Main::Wallet
{
Controller::Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent)
    : m_walletService(walletService)
    , QObject(parent)
{ }

void Controller::init() { }
} // namespace Modules::Main::Wallet
