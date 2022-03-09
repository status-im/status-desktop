#ifndef WALLET_ACCOUNT_ITEM_H
#define WALLET_ACCOUNT_ITEM_H

#include <QString>

namespace Modules::Main::Wallet::Accounts
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
    Item(QString name,
         QString address,
         QString path,
         QString color,
         QString publicKey,
         QString walletType,
         bool isWallet,
         bool isChat,
         float currencyBalance);
    ~Item() = default;

    const QString& getName() const;
    const QString& getAddress() const;
    const QString& getPath() const;
    const QString& getColor() const;
    const QString& getPublicKey() const;
    const QString& getWalletType() const;
    bool getIsWallet() const;
    bool getIsChat() const;
    float getCurrencyBalance() const;
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_ITEM_H
