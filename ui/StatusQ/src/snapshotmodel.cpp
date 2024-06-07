#include "StatusQ/snapshotmodel.h"

#include "StatusQ/snapshotobject.h"

#include <QDebug>

SnapshotModel::SnapshotModel(QObject* parent)
    : QAbstractListModel(parent)
{ }

SnapshotModel::SnapshotModel(const QAbstractItemModel& model, bool recursive, QObject* parent)
    : QAbstractListModel(parent)
{
    grabSnapshot(model, recursive);
}

SnapshotModel::~SnapshotModel()
{
    clearSnapshot();
}

int SnapshotModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid()) return 0;

    return m_data.size() ? m_data.begin()->size() : 0;
}

QHash<int, QByteArray> SnapshotModel::roleNames() const
{
    return m_roles;
}

QVariant SnapshotModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid() || !m_roles.contains(role) || index.row() >= rowCount())
    {
        return {};
    }

    return m_data[role][index.row()];
}

void SnapshotModel::grabSnapshot(const QAbstractItemModel& model, bool recursive)
{
    beginResetModel();
    clearSnapshot();

    m_roles = model.roleNames();

    auto roles = m_roles.keys();
    auto count = model.rowCount();

    for(auto role : roles)
    {
        for(int i = 0; i < count; i++)
        {
            QVariant data = model.data(model.index(i, 0), role);

            if(recursive && data.canConvert<QAbstractItemModel*>())
            {
                const auto submodel = data.value<QAbstractItemModel*>();

                m_data[role].push_back(QVariant::fromValue(new SnapshotModel(*submodel, true, this)));
            }
            else if(recursive && data.canConvert<QObject*>())
            {
                const auto submodelObject = data.value<QObject*>();
                const auto snapshot = new SnapshotObject(submodelObject, this);
                connect(this, &SnapshotModel::modelAboutToBeReset, snapshot, &SnapshotObject::deleteLater);
                m_data[role].push_back(snapshot->snapshot());
            }
            else
            {
                m_data[role].push_back(data);
            }
        }
    }
    endResetModel();
}

void SnapshotModel::clearSnapshot()
{
    for (auto& data : m_data.values())
    {
        for (auto& item : data)
        {
            if (item.canConvert<SnapshotModel*>())
            {
                item.value<SnapshotModel*>()->deleteLater();
            }
        }
    }
    m_data.clear();
}

QVariant SnapshotModel::data(int row, int role) const
{
    return data(index(row), role);
}
