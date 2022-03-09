#include "model_login.h"
#include <QAbstractListModel>
#include <QDebug>

namespace Modules
{
namespace Startup
{
namespace Login
{
Model::Model(QObject* parent)
    : QAbstractListModel(parent)
{ }

QHash<int, QByteArray> Model::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[Name] = "username";
    roles[Identicon] = "identicon";
    roles[ThumbnailImage] = "thumbnailImage";
    roles[LargeImage] = "largeImage";
    roles[KeyUid] = "keyUid";
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
    case Identicon: return QVariant(item.getIdenticon());
    case ThumbnailImage: return QVariant(item.getThumbnailImage());
    case LargeImage: return QVariant(item.getLargeImage());
    case KeyUid: return QVariant(item.getKeyUid());
    }

    return QVariant();
}

void Model::setItems(QVector<Item> items)
{
    beginResetModel();
    m_items = items;
    endResetModel();
}

Item Model::getItemAtIndex(int index)
{
    if(index < 0 || index >= m_items.size())
    {
        return Item();
    }

    return m_items[index];
}
} // namespace Login
} // namespace Startup
} // namespace Modules
