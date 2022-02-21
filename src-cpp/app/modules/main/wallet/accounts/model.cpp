#include "model.h"

namespace Modules::Main::Wallet::Accounts
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

    if(index.row() < 0 || index.row() >= m_items.size())
    {
        return QVariant();
    }

    const Item* item = m_items.at(index.row());

    switch(role)
    {
    case Name: return item->getName();
    case Address: return item->getAddress();
    case Path: return item->getPath();
    case Color: return item->getColor();
    case PublicKey: return item->getPublicKey();
    case WalletType: return item->getWalletType();
    case IsWallet: return item->getIsWallet();
    case IsChat: return item->getIsChat();
        //    case Assets: return QVariant(item.ge());
    case CurrencyBalance: return item->getCurrencyBalance();
    }

    return QVariant();
}

void Model::setItems(const QVector<Item*>& items)
{
    beginResetModel();
    m_items = items;
    endResetModel();
}

Item* Model::getItemByIndex(int index) const
{
    Item* returnItemPtr = nullptr;
    if((index > 0) && (index < m_items.size()))
    {
        returnItemPtr = m_items.at(index);
    }
    return returnItemPtr;
}

} // namespace Modules::Main::Wallet::Accounts
