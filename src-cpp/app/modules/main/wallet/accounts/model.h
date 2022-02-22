#pragma once

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

    QHash<int, QByteArray> roleNames() const override;
    int rowCount(const QModelIndex&) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    void setItems(const QVector<Item*>& items);
    Item* getItemByIndex(int index) const;

private:
    QVector<Item*> m_items;
};
} // namespace Modules::Main::Wallet::Accounts
