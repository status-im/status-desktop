#include "StatusServices/WalletAccounts/Service.h"

#include "StatusBackend/WalletAccounts.h"

using namespace Status::WalletAccount;

Service::Service()
{
}

void Service::init()
{
    fetchAccounts();
}

void Service::fetchAccounts()
{
    auto response = Backend::Wallet::Accounts::getAccounts();
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return;
    }

    foreach(const auto& value, response.result)
    {
        auto account = WalletAccountDto::toWalletAccountDto(value.toObject());
        if(!account.isChat)
        {
            m_walletAccounts[account.address] = std::move(account);
        }
    }
}

void Service::refreshAccounts()
{
    fetchAccounts();
}

QList<WalletAccountDto> Service::getWalletAccounts()
{
    return m_walletAccounts.values();
}

QString Service::generateNewAccount(const QString& password, const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::generateNewAccount(password, accountName, color);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return response.error.message;
    }

    refreshAccounts();
    return QString();
}

QString Service::addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                           const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::addAccountsFromPrivateKey(privateKey, password, accountName, color);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return response.error.message;
    }

    refreshAccounts();
    return QString();
}

QString Service::addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{
    auto response = Backend::Wallet::Accounts::addAccountsFromSeed(seedPhrase, password, accountName, color);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return response.error.message;
    }

    refreshAccounts();
    return QString();
}

QString Service::addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{
    auto response = Backend::Wallet::Accounts::addWatchOnlyAccount(address, accountName, color);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return response.error.message;
    }

    refreshAccounts();
    return QString();
}

void Service::deleteAccount(const QString& address)
{
    auto response = Backend::Wallet::Accounts::deleteAccount(address);
    if(response.containsError())
    {
        qWarning() << response.error.message;
        return;
    }

    refreshAccounts();
}
