#include <QDebug>

#include "controller.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
Controller::Controller(std::shared_ptr<Wallets::ServiceInterface> walletService,
                       QObject* parent)
    : m_walletService(walletService),
      QObject(parent)
{ }

void Controller::init()
{
}

} // namespace Onboarding
} // namespace Startup
} // namespace Modules
