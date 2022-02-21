#include "item.h"

namespace Modules::Main::Wallet::Accounts
{
Item::Item(QString name,
           QString address,
           QString path,
           QString color,
           QString publicKey,
           QString walletType,
           bool isWallet,
           bool isChat,
           float currencyBalance)
    : m_name(name)
    , m_address(address)
    , m_path(path)
    , m_color(color)
    , m_publicKey(publicKey)
    , m_walletType(walletType)
    , m_isWallet(isWallet)
    , m_isChat(isChat)
    , m_currencyBalance(currencyBalance)
{ }

const QString& Item::getName() const
{
    return m_name;
}

const QString& Item::getAddress() const
{
    return m_address;
}

const QString& Item::getPath() const
{
    return m_path;
}

const QString& Item::getColor() const
{
    return m_color;
}

const QString& Item::getPublicKey() const
{
    return m_publicKey;
}

const QString& Item::getWalletType() const
{
    return m_walletType;
}

bool Item::getIsWallet() const
{
    return m_isWallet;
}

bool Item::getIsChat() const
{
    return m_isChat;
}

float Item::getCurrencyBalance() const
{
    return m_currencyBalance;
}

} // namespace Modules::Main::Wallet::Accounts
