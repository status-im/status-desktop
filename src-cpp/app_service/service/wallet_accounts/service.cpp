#include <QDebug>

#include "wallet_accounts/service.h"

#include "backend/wallet_accounts.h"

namespace Wallets
{

Service::Service()
{
    // do nothing
}

void Service::init()
{
    fetchAccounts();
}

void Service::fetchAccounts()
{
    try
    {
        auto response = Backend::Wallet::Accounts::getAccounts();

        QVector<WalletAccountDto> result;
        foreach(const QJsonValue& value, response.m_result)
        {
            auto account = toWalletAccountDto(value);
            if(!account.isChat) m_walletAccounts[account.address] = account;
        }
    }
    catch(Backend::RpcException& e)
    {
        qWarning() << e.what();
    }
}

void Service::refreshAccounts()
{
    fetchAccounts();
    // do other thing like get balances and build token here later
}


QList<WalletAccountDto> Service::getWalletAccounts()
{
    return m_walletAccounts.values();
}

QString Service::generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::generateNewAccount(password, accountName, color);
    if(response.m_error.m_message.isEmpty())
    {
        refreshAccounts();
    }
    return response.m_error.m_message;
}

QString Service::addAccountsFromPrivateKey(const QString& privateKey, const QString& password, const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::addAccountsFromPrivateKey(privateKey, password, accountName, color);
    if(response.m_error.m_message.isEmpty())
    {
        refreshAccounts();
    }
    return response.m_error.m_message;
}

QString Service::addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::addAccountsFromSeed(seedPhrase, password, accountName, color);
    if(response.m_error.m_message.isEmpty())
    {
        refreshAccounts();
    }
    return response.m_error.m_message;
}

QString Service::addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{
    auto response = Backend::Wallet::Accounts::addWatchOnlyAccount(address, accountName, color);
    if(response.m_error.m_message.isEmpty())
    {
        refreshAccounts();
    }
    return response.m_error.m_message;
}

void Service::deleteAccount(const QString& address)
{
    auto response = Backend::Wallet::Accounts::deleteAccount(address);
    if(response.m_error.m_message.isEmpty())
    {
        refreshAccounts();
    }
}

} // namespace Wallets
