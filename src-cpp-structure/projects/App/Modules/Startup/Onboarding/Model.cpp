#include "Model.h"

using namespace Status::Modules::Startup::Onboarding;

Model::Model(QObject* parent)
    : QAbstractListModel(parent)
{
}

QHash<int, QByteArray> Model::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Id] = "accountId";
    roles[Alias] = "username";
    roles[Identicon] = "identicon";
    roles[Address] = "address";
    roles[KeyUid] = "keyUid";
    return roles;
}

int Model::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent)
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
    case Id:
        return item.getId();
    case Alias:
        return item.getAlias();
    case Identicon:
        return item.getIdenticon();
    case Address:
        return item.getAddress();
    case KeyUid:
        return item.getKeyUid();
    }

    return QVariant();
}

void Model::setItems(QVector<Item> items)
{
    beginResetModel();
    m_items = std::move(items);
    endResetModel();
}
