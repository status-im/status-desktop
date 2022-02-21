#pragma once

#include "item.h"
#include <QAbstractListModel>
#include <QHash>
#include <QVector>

namespace Modules
{
namespace Startup
{
namespace Onboarding
{
class Model : public QAbstractListModel
{
    Q_OBJECT

public:
    enum ModelRole
    {
        Id = Qt::UserRole + 1,
        Alias = Qt::UserRole + 2,
        Identicon = Qt::UserRole + 3,
        Address = Qt::UserRole + 4,
        KeyUid = Qt::UserRole + 5
    };

    explicit Model(QObject* parent = nullptr);

    QHash<int, QByteArray> roleNames() const;
    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex& index, int role) const;
    void setItems(QVector<Item> items);

private:
    QVector<Item> m_items;
};
} // namespace Onboarding
} // namespace Startup
} // namespace Modules
