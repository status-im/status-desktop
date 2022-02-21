#include "item.h"

namespace Modules::Main::Wallet::Accounts
{
Item::Item(QObject* parent,
           const QString& name,
           const QString& address,
           const QString& path,
           const QString& color,
           const QString& publicKey,
           const QString& walletType,
           bool isWallet,
           bool isChat,
           float currencyBalance)
    : QObject(parent)
    , m_name(name)
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

void Item::setData(Item* item)
{
    if(item)
    {
        m_name = item->getName();
        emit nameChanged();
        m_address = item->getAddress();
        emit addressChanged();
        m_path = item->getPath();
        emit pathChanged();
        m_color = item->getColor();
        emit colorChanged();
        m_publicKey = item->getPublicKey();
        emit publicKeyChanged();
        m_walletType = item->getWalletType();
        emit walletTypeChanged();
        m_isWallet = item->getIsWallet();
        emit isWalletChanged();
        m_isChat = item->getIsChat();
        emit isChatChanged();
        m_currencyBalance = item->getCurrencyBalance();
        emit currencyBalanceChanged();
    }
}


} // namespace Modules::Main::Wallet::Accounts
