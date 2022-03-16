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

    return QString();
}

QString Service::addAccountsFromPrivateKey(const QString& privateKey, const QString& password,
                                           const QString& accountName, const QString& color)
{

    return QString();
}

QString Service::addAccountsFromSeed(const QString& seedPhrase, const QString& password, const QString& accountName, const QString& color)
{

    return QString();
}

QString Service::addWatchOnlyAccount(const QString& address, const QString& accountName , const QString& color)
{

    return QString();
}

void Service::deleteAccount(const QString& address)
{

}
