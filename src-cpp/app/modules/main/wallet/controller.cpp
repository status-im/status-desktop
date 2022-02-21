#include <QDebug>

#include "controller.h"

namespace Modules::Main::Wallet
{
Controller::Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent)
    : QObject(parent),
      m_walletService(walletService)
{ }

void Controller::init() { }
} // namespace Modules::Main::Wallet
