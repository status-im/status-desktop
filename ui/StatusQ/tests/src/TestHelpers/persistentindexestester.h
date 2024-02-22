#pragma once

#include <QAbstractItemModel>
#include <QPointer>

#include <memory>

class SnapshotModel;

/**
 * @brief The PersistentIndexesTester class is a simple utility for persistent
 * indexes validation.
 *
 * It stores persistent indexes for all items and snapshot of the model's data.
 * Using compare() method it can be checked if data indicated by persistent
 * indexes match the snapshot.
 */
class PersistentIndexesTester
{
public:
    explicit PersistentIndexesTester(QAbstractItemModel* model);
    ~PersistentIndexesTester();

    void storeIndexesAndData();
    bool compare();

private:
    QPointer<QAbstractItemModel> m_model;
    QList<QPersistentModelIndex> m_persistentIndexes;
    std::unique_ptr<SnapshotModel> m_snapshot;
};
