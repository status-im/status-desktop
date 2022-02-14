#include "model.h"

namespace Modules
{
namespace Main
{
namespace Wallet
{
namespace Accounts
{
Model::Model(QObject* parent)
    : QAbstractListModel(parent)
{ }

QHash<int, QByteArray> Model::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Name] = "name";
    roles[Address] = "address";
    roles[Path] = "path";
    roles[Color] = "color";
    roles[PublicKey] = "publicKey";
    roles[WalletType] = "walletType";
    roles[IsWallet] = "isWallet";
    roles[IsChat] = "isChat";
    roles[Assets] = "assets";
    roles[CurrencyBalance] = "currencyBalance";
    return roles;
}

int Model::rowCount(const QModelIndex& parent = QModelIndex()) const
{
    return m_items.size();
}

QVariant Model::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
    {
        return QVariant();
    }

    if(index.row() < 0 || index.row() > m_items.size())
    {
        return QVariant();
    }

    Item item = m_items[index.row()];

    switch(role)
    {
    case Name: return QVariant(item.getName());
    case Address: return QVariant(item.getAddress());
    case Path: return QVariant(item.getPath());
    case Color: return QVariant(item.getColor());
    case PublicKey: return QVariant(item.getPublicKey());
    case WalletType: return QVariant(item.getWalletType());
    case IsWallet: return QVariant(item.getIsWallet());
    case IsChat: return QVariant(item.getIsChat());
        //    case Assets: return QVariant(item.ge());
    case CurrencyBalance: return QVariant(item.getCurrencyBalance());
    }

    return QVariant();
}

void Model::setItems(QVector<Item> &items)
{
    beginResetModel();
    m_items = items;
    endResetModel();
}

} // namespace Accounts
} // namespace Wallet
} // namespace Main
} // namespace Modules
