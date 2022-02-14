#include "item.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
Item::Item(QString name, QString address, QString path, QString color, QString publicKey, QString walletType, bool isWallet, bool isChat, float currencyBalance)
    : m_name(name),
      m_address(address),
      m_path(path),
      m_color(color),
      m_publicKey(publicKey),
      m_walletType(walletType),
      m_isWallet(isWallet),
      m_isChat(isChat),
      m_currencyBalance(currencyBalance)
{ }

QString Item::getName()
{
    return m_name;
}

QString Item::getAddress()
{
    return m_address;
}

QString Item::getPath()
{
    return m_path;
}

QString Item::getColor()
{
    return m_color;
}

QString Item::getPublicKey()
{
    return m_publicKey;
}

QString Item::getWalletType()
{
    return m_walletType;
}

bool Item::getIsWallet()
{
    return m_isWallet;
}

bool Item::getIsChat()
{
    return m_isChat;
}

float  Item::getCurrencyBalance()
{
    return m_currencyBalance;
}

} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules
