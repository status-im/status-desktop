#include <QDebug>

#include "controller_accounts.h"

namespace Modules::Main::Wallet::Accounts
{
Controller::Controller(std::shared_ptr<Wallets::ServiceInterface> walletService, QObject* parent)
    : m_walletServicePtr(walletService)
    , QObject(parent)
{ }

void Controller::init() { }

QList<Wallets::WalletAccountDto> Controller::getWalletAccounts()
{
    QList<Wallets::WalletAccountDto> wallet_accounts;
    if(nullptr != m_walletServicePtr) wallet_accounts = m_walletServicePtr->getWalletAccounts();

    return wallet_accounts;
}
} // namespace Modules::Main::Wallet::Accounts
