#include "snapshotmodel.h"

#include <QDebug>

SnapshotModel::SnapshotModel(QObject* parent)
    : QAbstractListModel(parent)
{
}

SnapshotModel::SnapshotModel(const QAbstractItemModel& model, bool recursive,
                             QObject* parent)
    : QAbstractListModel(parent)
{
    grabSnapshot(model, recursive);
}

int SnapshotModel::rowCount(const QModelIndex& parent) const
{
    if(parent.isValid())
        return 0;

    return m_data.size() ? m_data.begin()->size() : 0;
}

QHash<int, QByteArray> SnapshotModel::roleNames() const
{
    return m_roles;
}

QVariant SnapshotModel::data(const QModelIndex& index, int role) const
{
    if (!index.isValid() || !m_roles.contains(role)
            || index.row() >= rowCount()) {
        return {};
    }

    return m_data[role][index.row()];
}

void SnapshotModel::grabSnapshot(const QAbstractItemModel& model, bool recursive)
{
    m_roles = model.roleNames();
    m_data.clear();

    auto roles = m_roles.keys();
    auto count = model.rowCount();

    for (auto role : roles) {
        for (int i = 0; i < count; i++) {
            QVariant data = model.data(model.index(i, 0), role);

            if (recursive && data.canConvert<QAbstractItemModel*>()) {
                const auto submodel = data.value<QAbstractItemModel*>();

                m_data[role].push_back(
                            QVariant::fromValue(
                                new SnapshotModel(*submodel, true, this)));
            } else {
                m_data[role].push_back(data);
            }
        }
    }
}

QVariant SnapshotModel::data(int row, int role) const
{
    return data(index(row), role);
}
