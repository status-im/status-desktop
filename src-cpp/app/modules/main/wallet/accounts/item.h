#ifndef WALLET_ACCOUNT_ITEM_H
#define WALLET_ACCOUNT_ITEM_H

#include <QObject>
#include <QString>

namespace Modules::Main::Wallet::Accounts
{
class Item: public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString name READ getName NOTIFY nameChanged);
    Q_PROPERTY(QString address READ getAddress NOTIFY addressChanged);
    Q_PROPERTY(QString path READ getPath NOTIFY pathChanged);
    Q_PROPERTY(QString color READ getColor NOTIFY colorChanged);
    Q_PROPERTY(QString publicKey READ getPublicKey NOTIFY publicKeyChanged);
    Q_PROPERTY(QString walletType READ getWalletType NOTIFY walletTypeChanged);
    Q_PROPERTY(bool isWallet READ getIsWallet NOTIFY isWalletChanged);
    Q_PROPERTY(bool isChat READ getIsChat NOTIFY isChatChanged);
    Q_PROPERTY(float currencyBalance READ getCurrencyBalance NOTIFY currencyBalanceChanged);

public:
    Item(QObject* parent = nullptr,
         const QString& name = "",
         const QString& address = "",
         const QString& path = "",
         const QString& color = "",
         const QString& publicKey = "",
         const QString& walletType = "",
         bool isWallet = false,
         bool isChat = false,
         float currencyBalance = 0);
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
    void setData(Item *item);

signals:
    void nameChanged();
    void addressChanged();
    void pathChanged();
    void colorChanged();
    void publicKeyChanged();
    void walletTypeChanged();
    void isWalletChanged();
    void isChatChanged();
    void currencyBalanceChanged();

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

};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_ITEM_H
