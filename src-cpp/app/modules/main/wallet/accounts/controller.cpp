#include <QDebug>

#include "controller.h"

const QString WALLETSERVICE_NULL_ERROR = "wallet service pointer is null";

namespace Modules::Main::Wallet::Accounts
{
Controller::Controller(std::shared_ptr<Wallets::ServiceInterface> walletService,
                       QObject* parent)
    : QObject(parent),
      m_walletServicePtr(walletService)
{ }

void Controller::init() { }

QList<Wallets::WalletAccountDto> Controller::getWalletAccounts()
{
    QList<Wallets::WalletAccountDto> wallet_accounts;
    if(m_walletServicePtr)
    {
        wallet_accounts = m_walletServicePtr->getWalletAccounts();
    }

    return wallet_accounts;
}

QString Controller::generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    QString error = WALLETSERVICE_NULL_ERROR;
    if(m_walletServicePtr)
    {
        error = m_walletServicePtr->generateNewAccount(password, accountName, color);
    }
    return error;
}

QString Controller::addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color)
{
    QString error = WALLETSERVICE_NULL_ERROR;
    if(m_walletServicePtr)
    {
        error = m_walletServicePtr->addAccountsFromPrivateKey(privateKey, password, accountName, color);
    }
    return error;
}

QString Controller::addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    QString error = WALLETSERVICE_NULL_ERROR;
    if(m_walletServicePtr)
    {
        error = m_walletServicePtr->addAccountsFromSeed(seedPhrase, password, accountName, color);
    }
    return error;
}

QString Controller::addWatchOnlyAccount(const QString& address, const QString& accountName, const QString& color)
{
    QString error = WALLETSERVICE_NULL_ERROR;
    if(m_walletServicePtr)
    {
        error = m_walletServicePtr->addWatchOnlyAccount(address, accountName, color);
    }
    return error;
}

void Controller::deleteAccount(const QString& address)
{
    if(m_walletServicePtr)
    {
        m_walletServicePtr->deleteAccount(address);
    }
}

} // namespace Modules::Main::Wallet::Accounts
