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

QList<WalletAccountDto> Service::getWalletAccounts()
{
    return m_walletAccounts.values();
}

} // namespace Wallets
