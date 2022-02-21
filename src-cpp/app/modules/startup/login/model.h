#pragma once

#include "item.h"
#include <QAbstractListModel>
#include <QHash>
#include <QVector>

namespace Modules
{
namespace Startup
{
namespace Login
{
class Model : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModelRole
    {
        Name = Qt::UserRole + 1,
        Identicon = Qt::UserRole + 2,
        ThumbnailImage = Qt::UserRole + 3,
        LargeImage = Qt::UserRole + 4,
        KeyUid = Qt::UserRole + 5
    };

    explicit Model(QObject* parent = nullptr);

    QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex& index, int role) const;
    void setItems(QVector<Item> items);
    Item getItemAtIndex(int index);

private:
    QVector<Item> m_items;
};
} // namespace Login
} // namespace Startup
} // namespace Modules
