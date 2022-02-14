#ifndef WALLET_ACCOUNT_ITEM_H
#define WALLET_ACCOUNT_ITEM_H

#include <QString>

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
class Item
{
private:
    QString m_name;
    QString m_address;
    QString m_path;
    QString m_color;
    QString m_publicKey;
    QString m_walletType;
    bool m_isWallet;
    bool m_isChat;
    float m_currencyBalance;

public:
    Item(QString name, QString address, QString path, QString color, QString publicKey, QString walletType, bool isWallet, bool isChat, float currencyBalance);
    ~Item() = default;

    QString getName();
    QString getAddress();
    QString getPath();
    QString getColor();
    QString getPublicKey();
    QString getWalletType();
    bool getIsWallet();
    bool getIsChat();
    float getCurrencyBalance();
};
} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_ACCOUNT_ITEM_H
