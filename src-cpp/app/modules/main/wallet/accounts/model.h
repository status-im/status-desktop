#ifndef WALLET_ACCOUNT_MODEL_H
#define WALLET_ACCOUNT_MODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QVector>

#include "item.h"

namespace Modules::Main::Wallet::Accounts
{
class Model : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModelRole
    {
        Name = Qt::UserRole + 1,
        Address,
        Path,
        Color,
        PublicKey,
        WalletType,
        IsWallet,
        IsChat,
        Assets,
        CurrencyBalance
    };

    explicit Model(QObject* parent = nullptr);
    ~Model() = default;

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex&) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    void setItems(QVector<Item> &items);

private:
    QVector<Item> m_items;
};
} // namespace Modules::Main::Wallet::Accounts

#endif // WALLET_ACCOUNT_MODEL_H
