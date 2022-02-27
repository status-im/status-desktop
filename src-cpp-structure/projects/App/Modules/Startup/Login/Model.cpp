#include "Model.h"

using namespace Status::Modules::Startup::Login;

Model::Model(QObject* parent)
    : QAbstractListModel(parent)
{
}

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
    case Name:
        return item.getName();
    case Identicon:
        return item.getIdenticon();
    case ThumbnailImage:
        return item.getThumbnailImage();
    case LargeImage:
        return item.getLargeImage();
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

Item Model::getItemAtIndex(const int index) const
{
    if(index < 0 || index >= m_items.size())
    {
        return Item();
    }

    return m_items[index];
}
