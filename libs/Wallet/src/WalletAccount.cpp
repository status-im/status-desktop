#include "Status/Wallet/WalletAccount.h"

namespace Status::Wallet
{

WalletAccount::WalletAccount(const GoAccounts::ChatOrWalletAccount rawAccount, QObject* parent)
    : QObject(parent)
    , m_data(std::move(rawAccount))
{ }

const QString& WalletAccount::name() const
{
    return m_data.name;
}

const QString& WalletAccount::strAddress() const
{
    return m_data.address.get();
}

QColor WalletAccount::color() const
{
    return m_data.color;
}

} // namespace Status::Wallet
