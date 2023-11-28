#include "StatusQ/writableproxymodel.h"
#include <QSet>
#ifdef QT_DEBUG
#include <QAbstractItemModelTester>
#endif
#include <memory>


template <typename T>
using IndexedValues = QHash<T /*key*/, QMap<int/*role*/, QVariant/*value*/>>;

class WritableProxyModelPrivate
{
public:
    explicit WritableProxyModelPrivate(WritableProxyModel& q)
        : q(q)
    {
    }

    WritableProxyModel& q;
    IndexedValues<QPersistentModelIndex> cache;
    IndexedValues<QModelIndex> insertedRows;
    int rowsAboutToBeInserted = 0;
    QSet<QPersistentModelIndex> removedRows;
    QVector<int> proxyToSourceRowMapping;
    //internal operations can change dirty flag
    bool canUpdateDirtyFlag = true;

    inline void setData(const QModelIndex& index, const QVariant& value, int role);
    template<typename T>
    inline void setData(const QModelIndex& index, const QVariant& value, int role, IndexedValues<T>& indexedMap);

    inline QVariant data(const QModelIndex &index, int role, bool& found) const;
    template<typename T>
    inline QVariant data(const QModelIndex &index, int role, bool& found, const IndexedValues<T>& indexedMap) const;
    
    inline int proxyToSourceRow(int row) const;
    inline int sourceToProxyRow(int row) const;
    QVector<QPair<int, int>> sourceRowRangesBetween(int start, int end) const;

    //Simple mapping. No sorting, no moving
    //TODO: add mapping for temporarely moved rows
    void createProxyToSourceRowMap();

    inline bool contains(const QModelIndex& sourceIndex) const;
    inline void clear();
    inline void clearInvalidatedCache();
    
    void moveFromCacheToInserted(const QModelIndex& sourceIndex);
    void adjustInsertedRowsBy(int start, int offset);


    //Fix for missing role names in source model
    void applyRoleNamesFix();
};

template<typename T>
inline void WritableProxyModelPrivate::setData(const QModelIndex &index, const QVariant &value, int role, IndexedValues<T>& indexedMap)
{
    auto valueMap = indexedMap.take(index);
    valueMap[role] = value;
    indexedMap.insert(index, valueMap);
}

inline void WritableProxyModelPrivate::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if(proxyToSourceRowMapping[index.row()] >= 0)
    {
        setData(q.mapToSource(index), value, role, cache);
        return;
    }

    setData(index, value, role, insertedRows);
}

inline QVariant WritableProxyModelPrivate::data(const QModelIndex &index, int role, bool& found) const
{
    if(index.row() < 0 || index.row() >= proxyToSourceRowMapping.size())
    {
        found = false;
        return {};
    }

    if(proxyToSourceRowMapping[index.row()] >= 0)
    {
        //value in cache (updated role value)
        return data(q.mapToSource(index), role, found, cache);
    }
    //value in inserted rows
    return data(index, role, found, insertedRows);
}

template<typename T>
inline QVariant WritableProxyModelPrivate::data(const QModelIndex &index, int role, bool& found, const IndexedValues<T>& indexedMap) const
{
    QVariant value;
    auto it = indexedMap.find(index);
    if (it != indexedMap.end()) {
        auto valueMap = it.value();
        auto it2 = valueMap.find(role);
        if (it2 != valueMap.end()) {
            value = it2.value();
            found = true;
        }
    }

    return value;
}

int WritableProxyModelPrivate::proxyToSourceRow(int row) const 
{
    if(row < 0 || row >= proxyToSourceRowMapping.size())
    {
        return -1;
    }

    return proxyToSourceRowMapping[row];
}

int WritableProxyModelPrivate::sourceToProxyRow(int row) const
{
    for (int i = 0; i < proxyToSourceRowMapping.size(); ++i) {
        if(proxyToSourceRowMapping[i] == row)
        {
            return i;
        }
    }
    return -1;
}

void WritableProxyModelPrivate::createProxyToSourceRowMap()
{
    if(!q.sourceModel())
    {
        return;
    }

    auto sourceModel = q.sourceModel();

    proxyToSourceRowMapping.clear();
    int sourceIter = 0;
    for (int i = 0; i < q.rowCount(); ++i) {
        if(insertedRows.contains(q.index(i, 0)))
        {
            proxyToSourceRowMapping.append(-1);
            continue;
        }
        
        while(removedRows.contains(q.sourceModel()->index(sourceIter, 0)) && sourceIter < sourceModel->rowCount())
        {
            ++sourceIter;
        }

        proxyToSourceRowMapping.append(sourceIter);
        sourceIter++;
    }
}

bool WritableProxyModelPrivate::contains(const QModelIndex& sourceIndex) const {
    return cache.contains(sourceIndex) || insertedRows.contains(q.mapFromSource(sourceIndex));
}

void WritableProxyModelPrivate::WritableProxyModelPrivate::clear()
{
    cache.clear();
    removedRows.clear();
    insertedRows.clear();
    proxyToSourceRowMapping.clear();
}

void WritableProxyModelPrivate::clearInvalidatedCache()
{
    for(auto iter = removedRows.begin(); iter != removedRows.end();)
    {
        if(iter->isValid())
        {
            ++iter;
            continue;
        }

        iter = removedRows.erase(iter);
    }

    for(auto iter = cache.begin(); iter != cache.end();)
    {
        if(iter.key().isValid())
        {
            ++iter;
            continue;
        }

        iter = cache.erase(iter);
    }
}

void WritableProxyModelPrivate::moveFromCacheToInserted(const QModelIndex& sourceIndex)
{
    //User updated this row. Move it in inserted rows. We shouldn't delete it
    insertedRows.insert(q.mapFromSource(sourceIndex), cache.take(sourceIndex));
    auto itemData = q.sourceModel()->itemData(sourceIndex);
    auto proxyIndex = q.mapFromSource(sourceIndex);
    for(auto it = itemData.begin(); it != itemData.end(); ++it)
    {
        if(insertedRows[proxyIndex].contains(it.key()))
        {
            continue;
        }

        insertedRows[proxyIndex][it.key()] = it.value();
    }
}

void WritableProxyModelPrivate::applyRoleNamesFix()
{
    if(!q.sourceModel())
    {
        return;
    }

    if(q.sourceModel()->rowCount() != 0)
    {
        return;
    }

    auto connectionPtr = new QMetaObject::Connection();
    *connectionPtr =
        QObject::connect(q.sourceModel(), &QAbstractItemModel::rowsInserted, &q, [this, connectionPtr]() {
            QObject::disconnect(*connectionPtr);
            q.resetInternalData();
            delete connectionPtr;
        });
}

QVector<QPair<int, int>> WritableProxyModelPrivate::sourceRowRangesBetween(int start, int end) const
{
    QVector<QPair<int, int>> result;
    int currentStart = -1;
    int currentEnd = -1;
    for(int i = start; i <= end; ++i)
    {
        auto proxyRow = sourceToProxyRow(i);
        if(proxyRow >= 0)
        {
            if(currentStart == -1)
            {
                currentStart = proxyRow;
                currentEnd = currentStart;
            }
            else
            {
                currentEnd = proxyRow;
            }
        }
        else
        {
            if(currentStart != -1)
            {
                result.append({ currentStart, currentEnd });
                currentStart = -1;
                currentEnd = -1;
            }
        }
    }

    if(currentStart != -1)
    {
        result.append({ currentStart, currentEnd });
    }

    return result;
}

void WritableProxyModelPrivate::adjustInsertedRowsBy(int start, int offset)
{
    IndexedValues<QModelIndex> newInsertedRows;
    for(auto iter = insertedRows.begin(); iter != insertedRows.end(); ++iter)
    {
        auto key = iter.key();
        auto value = iter.value();
        if(key.row() >= start)
        {
            newInsertedRows.insert(key.siblingAtRow(key.row() + offset), value);
        }
        else
        {
            newInsertedRows.insert(key, value);
        }
    }
    insertedRows.swap(newInsertedRows);
}

WritableProxyModel::WritableProxyModel(QObject* parent)
    : QAbstractProxyModel(parent)
    , d(new WritableProxyModelPrivate(*this))
{
#ifdef QT_DEBUG
    // Enable the model tester on debug builds to catch any model errors
    new QAbstractItemModelTester(this, QAbstractItemModelTester::FailureReportingMode::Warning, this);
#endif
}

WritableProxyModel::~WritableProxyModel() = default;

QVariantMap WritableProxyModel::toVariantMap() const
{
    QVariantMap result;
    int rowCount = this->rowCount();
    for(int row = 0; row < rowCount; ++row)
    {
        auto index = this->index(row, 0);
        auto data = itemData(index);
        QVariantMap rowMap;
        for(auto it = data.begin(); it != data.end(); ++it)
        {
            rowMap[QString::number(it.key())] = it.value();
        }
        result[QString::number(row)] = rowMap;
    }

    return result;
}

bool WritableProxyModel::insert(int at)
{
    if(at < 0 || at > rowCount())
    {
        return false;
    }

    return insertRows(at, 1);
}

bool WritableProxyModel::remove(int at)
{
    if(at < 0 || at >= rowCount())
    {
        return false;
    }

    return removeRows(at, 1);
}

QVariantMap WritableProxyModel::get(int at) const
{
    if(at < 0 || at >= rowCount())
    {
        return {};
    }

    auto index = this->index(at, 0);
    auto data = this->itemData(index);
    auto roleNames = this->roleNames();
    QVariantMap rowMap;
    for(auto it = data.begin(); it != data.end(); ++it)
    {
        auto roleName = roleNames[it.key()];
        rowMap[roleName] = it.value();
    }
    return rowMap;
}

bool WritableProxyModel::set(int at, const QVariantMap& data)
{
    if(at < 0 || at >= rowCount())
    {
        return false;
    }

    auto index = this->index(at, 0);
    auto itemData = this->itemData(index);
    auto roleNames = this->roleNames();

    for(auto it = data.begin(); it != data.end(); ++it)
    {
        auto role = roleNames.key(it.key().toUtf8(), -1);
        itemData[role] = it.value();
    }

    return setItemData(index, itemData);
}

bool WritableProxyModel::dirty() const
{
    return m_dirty;
}

void WritableProxyModel::setDirty(bool flag)
{
    if(m_dirty == flag || !d->canUpdateDirtyFlag)
    {
        return;
    }

    m_dirty = flag;
    emit dirtyChanged();
}

void WritableProxyModel::setSourceModel(QAbstractItemModel* sourceModel)
{
    if(sourceModel == QAbstractProxyModel::sourceModel())
    {
        return;
    }

    beginResetModel();

    d->clear();

    if(QAbstractProxyModel::sourceModel())
    {
        disconnect(QAbstractProxyModel::sourceModel(), nullptr, this, nullptr);
    }

    setDirty(false);
    QAbstractProxyModel::setSourceModel(sourceModel);

    if(!sourceModel)
    {
        endResetModel();
        return;
    }

    d->applyRoleNamesFix();

    d->createProxyToSourceRowMap();
    connect(sourceModel, &QAbstractItemModel::dataChanged, this, &WritableProxyModel::handleSourceDataChanged);
    connect(sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this, &WritableProxyModel::handleRowsAboutToBeInserted);
    connect(sourceModel, &QAbstractItemModel::rowsInserted, this, &WritableProxyModel::handleRowsInserted);
    connect(sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this, &WritableProxyModel::handleRowsAboutToBeRemoved);
    connect(sourceModel, &QAbstractItemModel::rowsRemoved, this, &WritableProxyModel::handleRowsRemoved);
    connect(sourceModel, &QAbstractItemModel::modelAboutToBeReset, this, &WritableProxyModel::handleModelAboutToBeReset);
    connect(sourceModel, &QAbstractItemModel::modelReset, this, &WritableProxyModel::handleModelReset);
    connect(sourceModel, &QAbstractItemModel::rowsMoved, this, &WritableProxyModel::handleRowsMoved);
    connect(sourceModel, &QAbstractItemModel::layoutAboutToBeChanged, this, &WritableProxyModel::handleLayoutAboutToBeChanged);
    connect(sourceModel, &QAbstractItemModel::layoutChanged, this, &WritableProxyModel::handleModelReset);
    
    endResetModel();
}

int	WritableProxyModel::columnCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0; //no children
    }

    return 1;
}

int	WritableProxyModel::rowCount(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return 0; //no children
    }

    if(!sourceModel())
    {
        return 0;
    }

    return sourceModel()->rowCount(parent) + d->insertedRows.count() + d->rowsAboutToBeInserted - d->removedRows.count();
}

QModelIndex WritableProxyModel::index(int row, int column, const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return {}; //no children
    }

    if(row < 0 || column < 0 || row >= rowCount(parent) || column >= columnCount(parent))
    {
        return {};
    }

    return createIndex(row, column);
}

QModelIndex WritableProxyModel::sibling(int row, int column, const QModelIndex &idx) const
{
    if(!idx.isValid())
    {
        return {};
    }

    if(row < 0 || column < 0 || row >= rowCount(idx.parent()) || column >= columnCount(idx.parent()))
    {
        return {};
    }

    return createIndex(row, column);
}

QModelIndex WritableProxyModel::parent(const QModelIndex &child) const
{
    //no children. List models only
    return {};
}

QModelIndex WritableProxyModel::mapToSource(const QModelIndex &proxyIndex) const
{
    if(!proxyIndex.isValid())
    {
        return {};
    }

    if(auto row = d->proxyToSourceRow(proxyIndex.row()); row >= 0) {
        return sourceModel()->index(row, proxyIndex.column());
    }

    return {};
}

QModelIndex WritableProxyModel::mapFromSource(const QModelIndex &sourceIndex) const
{
    if(!sourceIndex.isValid())
    {
        return {};
    }

    if(auto row = d->sourceToProxyRow(sourceIndex.row()); row >= 0) {
        return index(row, sourceIndex.column());
    }

    return {};
}

bool WritableProxyModel::hasChildren(const QModelIndex &parent) const
{
    if(parent.isValid())
    {
        return false; //no children
    }

    if(!sourceModel())
    {
        return false;
    }

    return rowCount(parent) > 0;
}

void WritableProxyModel::revert()
{
    beginResetModel();
    d->clear();
    d->createProxyToSourceRowMap();
    setDirty(false);
    endResetModel();
}


QVariant WritableProxyModel::data(const QModelIndex& index, int role) const
{
    if(!index.isValid())
    {
        return {};
    }

    if(!sourceModel())
    {
        return {};
    }

    if(role == -1)
    {
        return {};
    }

    bool found = false;
    auto data = d->data(index, role, found);

    if(found)
    {
        return data;
    }

    return QAbstractProxyModel::data(index, role);
}

bool WritableProxyModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if(!index.isValid())
    {
        return false;
    }

    d->setData(index, value, role);
        
    setDirty(true);

    emit dataChanged(index, index, { role });
    return true;
}

QMap<int, QVariant> WritableProxyModel::itemData(const QModelIndex &index) const
{
    if(!index.isValid())
    {
        return {};
    }

    return QAbstractProxyModel::itemData(index);
}

bool WritableProxyModel::setItemData(const QModelIndex& index, const QMap<int, QVariant>& roles)
{
    if(!index.isValid())
    {
        return false;
    }

    if(QAbstractProxyModel::itemData(index) == roles)
    {
        return false;
    }

    setDirty(true);
    return QAbstractProxyModel::setItemData(index, roles);
}

bool WritableProxyModel::removeRows(int row, int count, const QModelIndex &parent)
{
    if(row < 0 || count < 1 || row + count > rowCount(parent))
    {
        return false;
    }

    beginRemoveRows(parent, row, row + count - 1);
    for (int i = row; i < row + count; ++i) {
        auto sourceIndex = mapToSource(index(i, 0, parent));
        if(sourceIndex.isValid())
        {
            d->removedRows.insert(sourceIndex);
        }
        else
        {
            d->insertedRows.remove(index(i, 0, parent));
        }

        d->adjustInsertedRowsBy(i, -1);
    }
    
    d->createProxyToSourceRowMap();
    endRemoveRows();
    setDirty(true);
    return true;
}

bool WritableProxyModel::insertRows(int row, int count, const QModelIndex& parent)
{
    if(row < 0 || count < 1 || row > rowCount(parent))
    {
        return false;
    }

    beginInsertRows(parent, row, row + count - 1);
    d->rowsAboutToBeInserted += count;
    d->adjustInsertedRowsBy(row, count);
    for (int i = row; i < row + count; ++i) {
        d->insertedRows.insert(index(i, 0, parent), {});
    }
    d->rowsAboutToBeInserted -= count;
    d->createProxyToSourceRowMap();
    endInsertRows();
    setDirty(true);
    return true;
}

void WritableProxyModel::handleSourceDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles)
{
    if(!topLeft.isValid() || !bottomRight.isValid())
    {
        return;
    }

    if(!dirty())
    {
        auto begin = mapFromSource(topLeft);
        auto end = mapFromSource(bottomRight);
        emit dataChanged(begin, end, roles);
        return;
    }

    auto begin = qMin(topLeft.row(), rowCount() - 1);
    auto end = qMin(bottomRight.row(), rowCount() - 1);
    for(int row = topLeft.row(); row <= end; ++row)
    {
        auto sourceIndex = sourceModel()->index(row, 0);

        if(d->contains(sourceIndex) || d->removedRows.contains(sourceIndex))
        {
            if(begin < row - 1)
            {
                emit dataChanged(mapFromSource(sourceModel()->index(begin, 0)), mapFromSource(sourceModel()->index(row - 1, 0)), roles);
            }

            begin = row + 1;
        }
    }

    if(begin <= end)
    {
        emit dataChanged(mapFromSource(sourceModel()->index(begin, 0)), mapFromSource(sourceModel()->index(end, 0)), roles);
    }
}

void WritableProxyModel::handleRowsAboutToBeInserted(const QModelIndex &parent, int start, int end)
{
    if(parent.isValid())
    {
        return;
    }

    if(!dirty())
    {
        beginInsertRows({}, start, start + end - start);
        return;
    }

    auto sourceRowRanges = d->sourceRowRangesBetween(start, qMax(end, sourceModel()->rowCount()));
    if(sourceRowRanges.isEmpty())
    {
        //append
        beginInsertRows({}, rowCount(), rowCount() + end - start);
        return;
    }

    beginInsertRows({}, sourceRowRanges.first().first, sourceRowRanges.first().first + end - start);
    d->rowsAboutToBeInserted += end - start;
    d->adjustInsertedRowsBy(sourceRowRanges.first().second, end - start);
    d->rowsAboutToBeInserted -= end - start;
}

void WritableProxyModel::handleRowsInserted(const QModelIndex &parent, int first, int last)
{
    if(parent.isValid())
    {
        return;
    }

    d->createProxyToSourceRowMap();
    endInsertRows();
}

void WritableProxyModel::handleRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end)
{
    if(parent.isValid())
    {
        return;
    }

    for(int row = start; row <= end; ++row)
    {
        auto sourceIndex = sourceModel()->index(row, 0);

        if(d->cache.contains(sourceIndex))
        {
            d->moveFromCacheToInserted(sourceIndex);
            continue;
        }

        auto sourceRemoveRanges = d->sourceRowRangesBetween(start, end);
        for(auto& sourceRemoveRange : sourceRemoveRanges)
        {
            auto proxyStart = sourceRemoveRange.first;
            auto proxyEnd = sourceRemoveRange.second;
            if(proxyStart == -1 || proxyEnd == -1)
            {
                continue;
            }

            d->canUpdateDirtyFlag = false;
            removeRows(proxyStart, proxyEnd - proxyStart + 1);
            d->canUpdateDirtyFlag = true;
        }
    }
}

void WritableProxyModel::handleRowsRemoved(const QModelIndex &parent, int first, int last)
{
    if(parent.isValid())
    {
        return;
    }

    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
}

void WritableProxyModel::handleModelAboutToBeReset()
{
    beginResetModel();
    for(auto iter = d->cache.begin(); iter != d->cache.end();)
    {
        auto key = iter.key();
        iter++;
        d->moveFromCacheToInserted(key);
    }
}

void WritableProxyModel::handleModelReset()
{
    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
    resetInternalData();
    endResetModel();
}

void WritableProxyModel::handleRowsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destinationParent, int destinationRow)
{
    if(sourceParent.isValid() || destinationParent.isValid())
    {
        return;
    }

    beginResetModel();
    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
    endResetModel();
}

void WritableProxyModel::handleLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    if(!sourceParents.isEmpty())
    {
        return;
    }
    beginResetModel();
}

void WritableProxyModel::handleLayoutChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
    endResetModel();
}
