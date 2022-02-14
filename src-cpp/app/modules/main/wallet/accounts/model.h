#ifndef WALLET_ACCOUNT_MODEL_H
#define WALLET_ACCOUNT_MODEL_H

#include <QAbstractListModel>
#include <QHash>
#include <QVector>

#include "item.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
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

    QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex& index, int role) const;
    void setItems(QVector<Item> &items);

private:
    QVector<Item> m_items;
};

} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules

#endif // WALLET_ACCOUNT_MODEL_H
