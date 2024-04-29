#include "StatusQ/movablemodel.h"

#include <algorithm>

#include <QDebug>

MovableModel::MovableModel(QObject* parent)
    : QAbstractListModel{parent}
{
}

void MovableModel::setSourceModel(QAbstractItemModel* sourceModel)
{
    if (m_sourceModel == sourceModel)
        return;

    beginResetModel();

    if (m_sourceModel != nullptr)
        disconnect(m_sourceModel, nullptr, this, nullptr);

    m_sourceModel = sourceModel;
    syncOrderInternal();
    emit sourceModelChanged();

    endResetModel();
}

QAbstractItemModel* MovableModel::sourceModel() const
{
    return m_sourceModel;
}

int MovableModel::rowCount(const QModelIndex &parent) const
{
    if (!m_synced)
        return m_indexes.size();

    if (m_sourceModel == nullptr)
        return 0;

    return m_sourceModel->rowCount();
}

QVariant MovableModel::data(const QModelIndex &index, int role) const
{
    if (!checkIndex(index, CheckIndexOption::IndexIsValid))
        return {};

    if (!m_synced)
        return m_indexes.at(index.row()).data(role);

    if (m_sourceModel == nullptr)
        return {};

    return m_sourceModel->index(index.row(), index.column()).data(role);
}

QHash<int, QByteArray> MovableModel::roleNames() const
{
    if (m_sourceModel == nullptr)
        return {};

    return m_sourceModel->roleNames();
}

void MovableModel::desyncOrder()
{
    if (m_synced)
    {
        m_indexes.clear();
        m_synced = false;
        emit syncedChanged();
    }

    if (m_sourceModel != nullptr)
    {
        disconnect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this,
                   &MovableModel::beginInsertRows);

        disconnect(m_sourceModel, &QAbstractItemModel::rowsInserted, this,
                   &MovableModel::endInsertRows);

        disconnect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this,
                   &MovableModel::beginRemoveRows);

        disconnect(m_sourceModel, &QAbstractItemModel::rowsRemoved, this,
                   &MovableModel::endRemoveRows);

        disconnect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeMoved, this,
                   &MovableModel::beginMoveRows);

        disconnect(m_sourceModel, &QAbstractItemModel::rowsMoved, this,
                   &MovableModel::endMoveRows);

        disconnect(m_sourceModel, &QAbstractItemModel::dataChanged, this,
                   &MovableModel::syncedSourceDataChanged);

        disconnect(m_sourceModel, &QAbstractItemModel::layoutAboutToBeChanged, this,
                   &MovableModel::sourceLayoutAboutToBeChanged);

        disconnect(m_sourceModel, &QAbstractItemModel::layoutChanged, this,
                   &MovableModel::sourceLayoutChanged);

        connect(m_sourceModel, &QAbstractItemModel::dataChanged, this,
                &MovableModel::desyncedSourceDataChanged);

        connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this,
                &MovableModel::sourceRowsInserted);

        connect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this,
                &MovableModel::sourceRowsAboutToBeRemoved);

        auto count = m_sourceModel->rowCount();
        m_indexes.reserve(count);

        for (auto i = 0; i < count; i++)
            m_indexes.emplace_back(m_sourceModel->index(i, 0));
    }
}

void MovableModel::syncOrder()
{
    if (m_synced || m_sourceModel == nullptr)
        return;

    emit layoutAboutToBeChanged();
    syncOrderInternal();
    emit layoutChanged();
}

void MovableModel::syncOrderInternal()
{
    if (m_sourceModel) {
        auto sourceModel = m_sourceModel;

        disconnect(m_sourceModel, nullptr, this, nullptr);
        connectSignalsForSyncedState();

        for (int i = 0; i < m_indexes.size(); ++i) {
            const QModelIndex idx = m_indexes[i];

            if (i == idx.row())
                continue;

            changePersistentIndex(index(i, 0), index(idx.row(), 0));
        }
    }

    m_indexes.clear();

    if (!m_synced) {
        m_synced = true;
        emit syncedChanged();
    }
}

void MovableModel::move(int from, int to, int count)
{
    const int rows = rowCount();
    if (from < 0 || to < 0 || count <= 0
            || from + count > rows || to + count > rows) {
        qWarning() << "MovableModel: move: out of range";
        return;
    }

    if (from == to)
        return;

    const int sourceFirst = from;
    const int sourceLast = from + count - 1;
    const int destinationRow = to < from ? to : to + count;

    if (m_synced)
        desyncOrder();

    beginMoveRows({}, sourceFirst, sourceLast, {}, destinationRow);

    std::vector<QPersistentModelIndex> movedIndexes;
    movedIndexes.reserve(count);

    std::move(m_indexes.begin() + sourceFirst,
              m_indexes.begin() + sourceLast + 1,
              std::back_insert_iterator(movedIndexes));
    m_indexes.erase(m_indexes.begin() + sourceFirst,
                    m_indexes.begin() + sourceLast + 1);
    m_indexes.insert(m_indexes.begin() + to,
                     std::move_iterator(movedIndexes.begin()),
                     std::move_iterator(movedIndexes.end()));

    endMoveRows();
}

QVector<int> MovableModel::order() const
{
    QVector<int> order(rowCount());

    if (!m_synced)
        std::transform(m_indexes.begin(), m_indexes.end(), order.begin(),
                       [](auto& idx) { return idx.row(); });
    else
        std::iota(order.begin(), order.end(), 0);

    return order;
}

bool MovableModel::synced() const
{
    return m_synced;
}

void MovableModel::resetInternalData()
{
    QAbstractListModel::resetInternalData();

    if (!m_synced)
        syncOrder(); 
}

void MovableModel::syncedSourceDataChanged(const QModelIndex& topLeft,
                                           const QModelIndex& bottomRight,
                                           const QVector<int>& roles)
{
    emit dataChanged(index(topLeft.row(), topLeft.column()),
                     index(bottomRight.row(), bottomRight.column()), roles);
}

void MovableModel::sourceLayoutAboutToBeChanged(
        const QList<QPersistentModelIndex>& parents,
        QAbstractItemModel::LayoutChangeHint hint)
{
    emit layoutAboutToBeChanged();

    const auto persistentIndexes = persistentIndexList();

    for (const QModelIndex& persistentIndex: persistentIndexes) {
        m_proxyIndexes << persistentIndex;
        Q_ASSERT(persistentIndex.isValid());
        const auto srcIndex = m_sourceModel->index(
                    persistentIndex.row(),
                    persistentIndex.column());

        Q_ASSERT(srcIndex.isValid());
        m_layoutChangePersistentIndexes << srcIndex;
    }
}

void MovableModel::sourceLayoutChanged(
        const QList<QPersistentModelIndex>& parents,
        QAbstractItemModel::LayoutChangeHint hint)
{
    for (int i = 0; i < m_proxyIndexes.size(); ++i) {
        auto p = m_layoutChangePersistentIndexes.at(i);
        changePersistentIndex(m_proxyIndexes.at(i), index(
                                  p.row(), p.column(), p.parent()));
    }

    m_layoutChangePersistentIndexes.clear();
    m_proxyIndexes.clear();

    emit layoutChanged();
}

void MovableModel::desyncedSourceDataChanged(const QModelIndex& topLeft,
                                     const QModelIndex& bottomRight,
                                     const QVector<int>& roles)
{
    Q_UNUSED(topLeft)
    Q_UNUSED(bottomRight)

    emit dataChanged(index(0), index(rowCount() - 1), roles);
}

void MovableModel::sourceRowsInserted(const QModelIndex& parent, int first,
                                      int last)
{
    Q_ASSERT(!parent.isValid());

    beginInsertRows({}, first, last);

    int oldCount = m_indexes.size();
    int insertCount = last - first + 1;

    m_indexes.reserve(m_indexes.size() + insertCount);

    for (auto i = first; i <= last; i++)
        m_indexes.emplace_back(m_sourceModel->index(i, 0));

    std::rotate(m_indexes.begin() + first, m_indexes.begin() + oldCount,
                m_indexes.end());

    endInsertRows();
}

void MovableModel::sourceRowsAboutToBeRemoved(const QModelIndex& parent,
                                              int first, int last)
{
    Q_ASSERT(!parent.isValid());
    Q_ASSERT(!m_synced);

    std::vector<int> indicesToRemove;
    indicesToRemove.reserve(last - first + 1);

    for (auto i = 0; i < m_indexes.size(); i++) {
        const QPersistentModelIndex& idx = m_indexes.at(i);

        if (idx.row() >= first && idx.row() <= last)
            indicesToRemove.push_back(i);
    }

    if (indicesToRemove.empty())
        return;

    std::vector<std::pair<int, int>> sequences;
    auto sequenceBegin = indicesToRemove.front();
    auto sequenceEnd = sequenceBegin;

    for (auto i = 1; i < indicesToRemove.size(); i++) {
        auto idxToRemove = indicesToRemove[i];

        auto idxDiff = idxToRemove - sequenceEnd;
        if (idxDiff == 1)
            sequenceEnd = idxToRemove;

        if (idxDiff != 1 || i == indicesToRemove.size() - 1) {
            sequences.emplace_back(sequenceBegin, sequenceEnd);
            sequenceBegin = idxToRemove;
            sequenceEnd = idxToRemove;
        }
    }

    if (sequences.empty())
        sequences.emplace_back(sequenceBegin, sequenceEnd);

    auto end = sequences.crend();

    for (auto it = sequences.crbegin(); it != end; it++) {
        beginRemoveRows({}, it->first, it->second);

        m_indexes.erase(m_indexes.begin() + it->first,
                        m_indexes.begin() + it->second + 1);

        endRemoveRows();
    }
}

void MovableModel::connectSignalsForSyncedState()
{
    if (m_sourceModel == nullptr)
        return;

    connect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this,
            &MovableModel::beginInsertRows);

    connect(m_sourceModel, &QAbstractItemModel::rowsInserted, this,
            &MovableModel::endInsertRows);

    connect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this,
            &MovableModel::beginRemoveRows);

    connect(m_sourceModel, &QAbstractItemModel::rowsRemoved, this,
            &MovableModel::endRemoveRows);

    connect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeMoved, this,
            &MovableModel::beginMoveRows);

    connect(m_sourceModel, &QAbstractItemModel::rowsMoved, this,
            &MovableModel::endMoveRows);

    connect(m_sourceModel, &QAbstractItemModel::dataChanged, this,
            &MovableModel::syncedSourceDataChanged);

    connect(m_sourceModel, &QAbstractItemModel::layoutAboutToBeChanged, this,
            &MovableModel::sourceLayoutAboutToBeChanged);

    connect(m_sourceModel, &QAbstractItemModel::layoutChanged, this,
            &MovableModel::sourceLayoutChanged);

    connect(m_sourceModel, &QAbstractItemModel::modelAboutToBeReset, this,
            &MovableModel::beginResetModel);

    connect(m_sourceModel, &QAbstractItemModel::modelReset, this,
            &MovableModel::endResetModel);

    disconnect(m_sourceModel, &QAbstractItemModel::dataChanged, this,
            &MovableModel::desyncedSourceDataChanged);

    disconnect(m_sourceModel, &QAbstractItemModel::rowsInserted, this,
            &MovableModel::sourceRowsInserted);

    disconnect(m_sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this,
            &MovableModel::sourceRowsAboutToBeRemoved);
}
