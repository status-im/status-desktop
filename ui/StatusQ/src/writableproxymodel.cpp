#include "StatusQ/writableproxymodel.h"
#include <QSet>
#ifdef QT_DEBUG
#include <QAbstractItemModelTester>
#endif
#include <memory>
#include <QDebug>


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
    QSet<QPersistentModelIndex> removedRows;
    QVector<int> proxyToSourceRowMapping;
    bool dirty{false};
    bool syncedRemovals{false};
    bool syncedRemovalsInitialized{false};

    void setData(const QModelIndex& index, const QVariant& value, int role);
    template<typename T>
    void setData(const QModelIndex& index, const QVariant& value, int role, IndexedValues<T>& indexedMap);

    QVariant data(const QModelIndex& index, int role, bool& found) const;
    template<typename T>
    QVariant data(const QModelIndex& index, int role, bool& found, const IndexedValues<T>& indexedMap) const;

    int proxyToSourceRow(int row) const;
    int sourceToProxyRow(int row) const;
    QVector<QPair<int, int>> sourceRowRangesBetween(int start, int end) const;

    // helpers for handling layoutChanged from source
    QList<QPersistentModelIndex> layoutChangePersistentIndexes;
    QModelIndexList proxyIndexes;

    void storePersitentIndexes();
    void updatePersistentIndexes();

    //Simple mapping. No sorting, no moving
    //TODO: add mapping for temporarily moved rows
    void createProxyToSourceRowMap();

    void clear();
    void clearInvalidatedCache();
    bool contains(const QModelIndex& sourceIndex, const QVector<int>& roles = {}) const;
    int countOffset() const;

    void moveFromCacheToInserted(const QModelIndex& sourceIndex);
    bool removeRows(int row, int count, const QModelIndex& parent = {});

    void adjustInsertedRowsBy(int start, int offset);
    void alignInsertedRowsAtBeginning();

    void checkForDirtyRemoval(const QModelIndex& sourceIndex, const QVector<int>& roles);

    //Fix for missing role names in source model
    void applyRoleNamesFix();
};

template<typename T>
void WritableProxyModelPrivate::setData(const QModelIndex& index, const QVariant& value, int role, IndexedValues<T>& indexedMap)
{
    auto valueMap = indexedMap.take(index);
    valueMap[role] = value;
    indexedMap.insert(index, valueMap);
}

void WritableProxyModelPrivate::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (proxyToSourceRowMapping[index.row()] >= 0)
    {
        setData(q.mapToSource(index), value, role, cache);
        return;
    }

    setData(index, value, role, insertedRows);
}

QVariant WritableProxyModelPrivate::data(const QModelIndex& index, int role, bool& found) const
{
    if (index.row() < 0 || index.row() >= proxyToSourceRowMapping.size())
    {
        found = false;
        return {};
    }

    if (proxyToSourceRowMapping[index.row()] >= 0)
        //value in cache (updated role value)
        return data(q.mapToSource(index), role, found, cache);

    //value in inserted rows
    return data(index, role, found, insertedRows);
}

template<typename T>
QVariant WritableProxyModelPrivate::data(const QModelIndex& index, int role, bool& found, const IndexedValues<T>& indexedMap) const
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
    if (row < 0 || row >= proxyToSourceRowMapping.size())
        return -1;

    return proxyToSourceRowMapping[row];
}

int WritableProxyModelPrivate::sourceToProxyRow(int row) const
{
    for (int i = 0; i < proxyToSourceRowMapping.size(); ++i)
    {
        if (proxyToSourceRowMapping[i] == row)
            return i;
    }
    return -1;
}

void WritableProxyModelPrivate::storePersitentIndexes()
{
    const auto persistentIndexes = q.persistentIndexList();

    for (const QModelIndex& persistentIndex: persistentIndexes) {

        Q_ASSERT(persistentIndex.isValid());
        const auto srcIndex = q.mapToSource(persistentIndex);

        if (srcIndex.isValid()) {
            proxyIndexes << persistentIndex;
            layoutChangePersistentIndexes << srcIndex;
        }
    }
}

void WritableProxyModelPrivate::updatePersistentIndexes()
{
    for (int i = 0; i < proxyIndexes.size(); ++i) {
        q.changePersistentIndex(proxyIndexes.at(i),
                                q.mapFromSource(layoutChangePersistentIndexes.at(i)));
    }

    layoutChangePersistentIndexes.clear();
    proxyIndexes.clear();
}

void WritableProxyModelPrivate::createProxyToSourceRowMap()
{
    if (!q.sourceModel())
        return;

    auto sourceModel = q.sourceModel();

    proxyToSourceRowMapping.clear();
    int sourceIter = 0;
    for (int i = 0; i < q.rowCount(); ++i) {
        if (insertedRows.contains(q.index(i, 0)))
        {
            proxyToSourceRowMapping.append(-1);
            continue;
        }

        while(removedRows.contains(sourceModel->index(sourceIter, 0))
              && sourceIter < sourceModel->rowCount())
            ++sourceIter;

        proxyToSourceRowMapping.append(sourceIter);
        sourceIter++;
    }
}

bool WritableProxyModelPrivate::contains(const QModelIndex& sourceIndex, const QVector<int>& roles) const {
    if (cache.contains(sourceIndex)) {
        auto valueMap = cache[sourceIndex];
        return std::any_of(roles.begin(), roles.end(), [&valueMap](int role) { return valueMap.contains(role); });
    }

    if (insertedRows.contains(q.mapFromSource(sourceIndex))) {
        auto valueMap = insertedRows[q.mapFromSource(sourceIndex)];
        for (auto& role : roles) {
            if (!valueMap.contains(role))
                return false;
        }
        return true;
    }

    return false;
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
    for (auto iter = removedRows.begin(); iter != removedRows.end();)
    {
        if (iter->isValid())
        {
            ++iter;
            continue;
        }

        iter = removedRows.erase(iter);
    }

    for (auto iter = cache.begin(); iter != cache.end();)
    {
        if (iter.key().isValid())
        {
            ++iter;
            continue;
        }

        iter = cache.erase(iter);
    }
}

int WritableProxyModelPrivate::countOffset() const
{
    return insertedRows.count() - removedRows.count();
}

void WritableProxyModelPrivate::moveFromCacheToInserted(const QModelIndex& sourceIndex)
{
    if (!q.sourceModel() || syncedRemovals)
        return;
    
    //User updated this row. Move it in inserted rows. We shouldn't delete it
    auto proxyIndex = insertedRows.insert(q.mapFromSource(sourceIndex), cache.take(sourceIndex));
    // syncedRemovalsInitialized cannot be changed after this point
    syncedRemovalsInitialized = true;

    auto itemData = q.sourceModel()->itemData(sourceIndex);
    for (auto it = itemData.begin(); it != itemData.end(); ++it)
    {
        if (proxyIndex.value().contains(it.key()))
            continue;

        proxyIndex.value()[it.key()] = it.value();
    }

    if (proxyIndex.key().isValid())
        proxyToSourceRowMapping[proxyIndex.key().row()] = -1;
}

void WritableProxyModelPrivate::checkForDirtyRemoval(const QModelIndex& sourceIndex, const QVector<int>& roles)
{
    q.setDirty(!cache.isEmpty() || !insertedRows.isEmpty() || !removedRows.isEmpty());

    if (!q.sourceModel() || !q.dirty())
        return;

    auto sourceCount = q.sourceModel()->rowCount();
    auto proxyCount = q.rowCount();
    auto insertedRowsCount = insertedRows.size();

    if (sourceCount != proxyCount - insertedRowsCount)
        return;

    if (cache.contains(sourceIndex))
    {
        auto& cachedData = cache[sourceIndex];
        for (auto& role : roles)
        {
            if (cachedData.contains(role) && cachedData[role] == q.sourceModel()->data(sourceIndex, role))
                cachedData.remove(role);
        }

        if (cachedData.isEmpty()) {
            cache.remove(sourceIndex);
            q.setDirty(!cache.isEmpty() || !insertedRows.isEmpty() || !removedRows.isEmpty());
            return;
        }
    }
    
}

void WritableProxyModelPrivate::applyRoleNamesFix()
{
    if (!q.sourceModel())
        return;

    if (q.sourceModel()->rowCount() != 0)
        return;

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

    for (int i = start; i <= end; ++i)
    {
        auto proxyRow = sourceToProxyRow(i);

        if (proxyRow == -1) //is removed
        {
            //first removed row is hit
            if (currentStart != -1)
            {
                result.append({ currentStart, currentEnd });
                currentStart = -1;
                currentEnd = -1;
            }
            continue;
        }

        if (currentStart == -1) //first row to be added to current range
        {
            currentStart = proxyRow;
            currentEnd = currentStart;
            continue;
        }

        if (currentEnd + 1 == proxyRow) //continue current range
        {
            currentEnd = proxyRow;
            continue;
        }

        result.append({ currentStart, currentEnd });
        currentStart = proxyRow;
        currentEnd = proxyRow;
    }

    if (currentStart != -1)
        result.append({ currentStart, currentEnd });

    return result;
}

bool WritableProxyModelPrivate::removeRows(int row, int count, const QModelIndex& parent)
{
    if (row < 0 || count < 1 || row + count > q.rowCount(parent))
        return false;

    q.beginRemoveRows(parent, row, row + count - 1);


    QVector<QPersistentModelIndex> populateRemovedRows;
    QVector<QModelIndex> removeFromInsertedRows;

    for (int i = row; i < row + count; ++i) {
        auto proxyIndex = q.index(i, 0, parent);
        auto sourceIndex = q.mapToSource(proxyIndex);
        if (sourceIndex.isValid())
            populateRemovedRows.push_back(sourceIndex);
        else
            removeFromInsertedRows.push_back(proxyIndex);
    }

    for (auto iter = removeFromInsertedRows.rbegin(); iter != removeFromInsertedRows.rend(); ++iter)
    {
        insertedRows.remove(*iter);
        adjustInsertedRowsBy(iter->row(), -1);
    }

    for (auto iter = populateRemovedRows.rbegin(); iter != populateRemovedRows.rend(); ++iter)
    {
         removedRows.insert(*iter);
         adjustInsertedRowsBy(sourceToProxyRow(iter->row()), -1);
    }

    createProxyToSourceRowMap();
    q.endRemoveRows();

    checkForDirtyRemoval({}, {});
    return true;
}

void WritableProxyModelPrivate::adjustInsertedRowsBy(int start, int offset)
{
    if (offset == 0)
        return;

    IndexedValues<QModelIndex> newInsertedRows;
    for (auto iter = insertedRows.begin(); iter != insertedRows.end(); ++iter)
    {
        auto key = iter.key();
        auto value = iter.value();
        if (key.row() >= start)
        {
            auto index = q.createIndex(key.row() + offset, 0);
            newInsertedRows.insert(index, value);
        }
        else
            newInsertedRows.insert(key, value);
    }
    insertedRows.swap(newInsertedRows);
}

void WritableProxyModelPrivate::alignInsertedRowsAtBeginning()
{
    for (int i = 0; i < proxyToSourceRowMapping.size(); ++i)
    {
        if (proxyToSourceRowMapping[i] != -1)
            continue;

        adjustInsertedRowsBy(i, -i);
    }
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
    for (int row = 0; row < rowCount; ++row)
    {
        auto index = this->index(row, 0);
        auto data = itemData(index);
        QVariantMap rowMap;
        for (auto it = data.begin(); it != data.end(); ++it)
            rowMap[QString::number(it.key())] = it.value();
        result[QString::number(row)] = rowMap;
    }

    return result;
}

QVariantList WritableProxyModel::getInsertedItems() const
{
    if (!d->dirty || !sourceModel())
        return {};

    QVariantList result;

    for (auto iter = d->insertedRows.begin(); iter != d->insertedRows.end(); ++iter)
    {
        auto index = iter.key();
        if (!index.isValid())
            continue;
            
        auto data = iter.value();
        QVariantMap rowMap;
        for (auto it = data.begin(); it != data.end(); ++it)
            rowMap[roleNames()[it.key()]] = it.value();
        result.append(rowMap);
    }

    return result;
}

QVariantList WritableProxyModel::getEditedItems() const
{
    if (!d->dirty || !sourceModel())
        return {};
    
    QVariantList result;

    for (auto iter = d->cache.begin(); iter != d->cache.end(); ++iter)
    {
        auto index = iter.key();
        if (!index.isValid())
            continue;
            
        auto data = itemData(index);
        QVariantMap rowMap;
        for (auto it = data.begin(); it != data.end(); ++it)
            rowMap[roleNames()[it.key()]] = it.value();
        result.append(rowMap);
    }

    return result;
}

QVariantList WritableProxyModel::getRemovedItems() const
{
    if (!d->dirty || !sourceModel())
        return {};

    QVariantList result;

    for (auto iter = d->removedRows.begin(); iter != d->removedRows.end(); ++iter)
    {
        if (!iter->isValid())
            continue;

        QVariantMap rowMap;
        auto roleNames = this->roleNames();
        for (auto it = roleNames.begin(); it != roleNames.end(); ++it)
            rowMap[it.value()] = sourceModel()->data(*iter, it.key());
        result.append(rowMap);
    }

    return result;
}

bool WritableProxyModel::insert(int at, const QVariantMap& data)
{
    if(!sourceModel())
        return false;

    auto rowCount = this->rowCount();

    if (at < 0 || at > rowCount)
        return false;

    beginInsertRows({}, at, at);

    auto roleNames = this->roleNames();
    QMap<int/*role*/, QVariant/*value*/> rowMap;
    
    for (auto it = data.begin(); it != data.end(); ++it)
    {
        auto role = roleNames.key(it.key().toUtf8(), -1);
        if (role == -1)
            continue;

        rowMap.insert(role, it.value());
    }

    d->adjustInsertedRowsBy(at, 1);

    auto index = createIndex(at, 0);
    d->insertedRows.insert(index, rowMap);

    d->createProxyToSourceRowMap();

    endInsertRows();

    setDirty(true);

    return true;
}

bool WritableProxyModel::append(const QVariantMap& data)
{
    return insert(rowCount(), data);
}

bool WritableProxyModel::remove(int at)
{
    if (at < 0 || at >= rowCount())
        return false;

    return removeRows(at, 1);
}

QVariantMap WritableProxyModel::get(int at) const
{
    if (at < 0 || at >= rowCount())
        return {};

    auto index = this->index(at, 0);
    auto data = this->itemData(index);
    auto roleNames = this->roleNames();
    QVariantMap rowMap;
    for (auto it = data.begin(); it != data.end(); ++it)
    {
        auto roleName = roleNames[it.key()];
        rowMap[roleName] = it.value();
    }
    return rowMap;
}

bool WritableProxyModel::set(int at, const QVariantMap& data)
{
    if (at < 0 || at >= rowCount())
        return false;

    auto index = this->index(at, 0);
    QMap<int, QVariant> itemData;
    auto roleNames = this->roleNames();

    for (auto it = data.begin(); it != data.end(); ++it)
    {
        auto role = roleNames.key(it.key().toUtf8(), -1);
        itemData[role] = it.value();
    }

    return setItemData(index, itemData);
}

bool WritableProxyModel::dirty() const
{
    return d->dirty;
}

void WritableProxyModel::setDirty(bool flag)
{
    if (d->dirty == flag)
        return;

    d->dirty = flag;
    emit dirtyChanged();
}

bool WritableProxyModel::syncedRemovals() const
{
    return d->syncedRemovals;
}

void WritableProxyModel::setSyncedRemovals(bool syncedRemovals)
{
    if (d->syncedRemovalsInitialized)
    {
        qWarning() << "WritableProxyModel: syncedRemovals cannot be updated after it has been initialized";
        return;
    }

    if (syncedRemovals == d->syncedRemovals)
        return;

    d->syncedRemovals = syncedRemovals;
    d->syncedRemovalsInitialized = true;
    emit syncedRemovalsChanged();
}

void WritableProxyModel::setSourceModel(QAbstractItemModel* sourceModel)
{
    if (sourceModel == QAbstractProxyModel::sourceModel())
        return;

    beginResetModel();

    d->clear();

    if (QAbstractProxyModel::sourceModel())
        disconnect(QAbstractProxyModel::sourceModel(), nullptr, this, nullptr);

    setDirty(false);
    QAbstractProxyModel::setSourceModel(sourceModel);

    if (!sourceModel)
    {
        endResetModel();
        return;
    }

    d->applyRoleNamesFix();

    d->createProxyToSourceRowMap();
    connect(sourceModel, &QAbstractItemModel::dataChanged, this, &WritableProxyModel::onSourceDataChanged);
    connect(sourceModel, &QAbstractItemModel::rowsAboutToBeInserted, this, &WritableProxyModel::onRowsAboutToBeInserted);
    connect(sourceModel, &QAbstractItemModel::rowsInserted, this, &WritableProxyModel::onRowsInserted);
    connect(sourceModel, &QAbstractItemModel::rowsAboutToBeRemoved, this, &WritableProxyModel::onRowsAboutToBeRemoved);
    connect(sourceModel, &QAbstractItemModel::rowsRemoved, this, &WritableProxyModel::onRowsRemoved);
    connect(sourceModel, &QAbstractItemModel::modelAboutToBeReset, this, &WritableProxyModel::onModelAboutToBeReset);
    connect(sourceModel, &QAbstractItemModel::modelReset, this, &WritableProxyModel::onModelReset);
    connect(sourceModel, &QAbstractItemModel::rowsAboutToBeMoved, this, &WritableProxyModel::onRowsAboutToBeMoved);
    connect(sourceModel, &QAbstractItemModel::rowsMoved, this, &WritableProxyModel::onRowsMoved);
    connect(sourceModel, &QAbstractItemModel::layoutAboutToBeChanged, this, &WritableProxyModel::onLayoutAboutToBeChanged);
    connect(sourceModel, &QAbstractItemModel::layoutChanged, this, &WritableProxyModel::onModelReset);

    endResetModel();
}

int WritableProxyModel::columnCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0; //no children

    return 1;
}

int WritableProxyModel::rowCount(const QModelIndex& parent) const
{
    if (parent.isValid())
        return 0; //no children

    if (!sourceModel())
        return 0;

    return sourceModel()->rowCount(parent) + d->countOffset();
}

QModelIndex WritableProxyModel::index(int row, int column, const QModelIndex& parent) const
{
    if (parent.isValid())
        return {}; //no children

    if (row < 0 || column < 0 || row >= rowCount(parent) || column >= columnCount(parent))
        return {};

    return createIndex(row, column);
}

QModelIndex WritableProxyModel::sibling(int row, int column, const QModelIndex& idx) const
{
    if (!idx.isValid())
        return {};

    if (row < 0 || column < 0 || row >= rowCount(idx.parent()) || column >= columnCount(idx.parent()))
        return {};

    return createIndex(row, column);
}

QModelIndex WritableProxyModel::parent(const QModelIndex& child) const
{
    //no children. List models only
    return {};
}

QModelIndex WritableProxyModel::mapToSource(const QModelIndex& proxyIndex) const
{
    if (!sourceModel())
        return {};

    if (!proxyIndex.isValid())
        return {};

    if (auto row = d->proxyToSourceRow(proxyIndex.row()); row >= 0)
        return sourceModel()->index(row, proxyIndex.column());

    return {};
}

QModelIndex WritableProxyModel::mapFromSource(const QModelIndex& sourceIndex) const
{
    if (!sourceIndex.isValid())
        return {};

    if (auto row = d->sourceToProxyRow(sourceIndex.row()); row >= 0)
        return index(row, sourceIndex.column());

    return {};
}

bool WritableProxyModel::hasChildren(const QModelIndex& parent) const
{
    if (parent.isValid())
        return false; //no children

    if (!sourceModel())
        return false;

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
    if (!index.isValid())
        return {};

    if (!sourceModel())
        return {};

    auto roleNames = this->roleNames();
    if (!roleNames.contains(role))
        return {};

    bool found = false;
    auto data = d->data(index, role, found);

    if (found)
        return data;

    return QAbstractProxyModel::data(index, role);
}

bool WritableProxyModel::setData(const QModelIndex& index, const QVariant& value, int role)
{
    if (!sourceModel())
        return false;

    if (!index.isValid())
        return false;

    d->setData(index, value, role);

    setDirty(true);

    emit dataChanged(index, index, { role });
    return true;
}

QMap<int, QVariant> WritableProxyModel::itemData(const QModelIndex& index) const
{
    if (!index.isValid())
        return {};

    QMap<int, QVariant> result;
    
    auto keysList = roleNames().keys();
    for (auto& role : keysList)
    {
        auto data = this->data(index, role);
        result[role] = data;
    }
    
    return result;
}

bool WritableProxyModel::setItemData(const QModelIndex& index, const QMap<int, QVariant>& roles)
{
    if (!index.isValid())
        return false;

    if (itemData(index) == roles)
        return false;

    for (auto it = roles.begin(); it != roles.end(); ++it)
        setData(index, it.value(), it.key());
    
    return true;
}

bool WritableProxyModel::removeRows(int row, int count, const QModelIndex& parent)
{
    return d->removeRows(row, count, parent);;
}

bool WritableProxyModel::insertRows(int row, int count, const QModelIndex& parent)
{
    if (!sourceModel())
        return false;

    if (row < 0 || count < 1 || row > rowCount(parent))
        return false;

    beginInsertRows(parent, row, row + count - 1);
    d->adjustInsertedRowsBy(row, count);

    for (int i = row; i < row + count; ++i)
    {
        auto index = createIndex(i, 0);
        d->insertedRows.insert(index, {});
    }

    d->createProxyToSourceRowMap();
    endInsertRows();
    setDirty(true);
    return true;
}

void WritableProxyModel::onSourceDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles)
{
    if (!sourceModel())
        return;

    if (!topLeft.isValid() || !bottomRight.isValid())
        return;

    if (!dirty())
    {
        auto begin = mapFromSource(topLeft);
        auto end = mapFromSource(bottomRight);
        emit dataChanged(begin, end, roles);
        return;
    }

    auto begin = qMin(topLeft.row(), rowCount() - 1);
    auto end = qMin(bottomRight.row(), rowCount() - 1);

    for (int row = topLeft.row(); row <= end; ++row)
    {
        auto sourceIndex = sourceModel()->index(row, 0);

        if (d->contains(sourceIndex, roles) || d->removedRows.contains(sourceIndex))
        {
            if (begin < row - 1)
                emit dataChanged(mapFromSource(sourceModel()->index(begin, 0)), mapFromSource(sourceModel()->index(row - 1, 0)), roles);

            begin = row + 1;
        }

        d->checkForDirtyRemoval(sourceIndex, roles);
    }

    if (begin <= end)
        emit dataChanged(mapFromSource(sourceModel()->index(begin, 0)), mapFromSource(sourceModel()->index(end, 0)), roles);
}

void WritableProxyModel::onRowsAboutToBeInserted(const QModelIndex& parent, int start, int end)
{
    if (!sourceModel())
        return;

    if (parent.isValid())
        return;

    if (!dirty())
    {
        beginInsertRows({}, start, end);
        return;
    }

    auto count = end - start + 1;
    auto sourceRowRanges = d->sourceRowRangesBetween(start, qMax(end, sourceModel()->rowCount()));
    if (sourceRowRanges.isEmpty())
    {
        //append
        beginInsertRows({}, rowCount(), rowCount() + end - start);
        return;
    }

    beginInsertRows({}, sourceRowRanges.first().first, sourceRowRanges.first().first + end - start);
    d->adjustInsertedRowsBy(sourceRowRanges.first().second, count);
}

void WritableProxyModel::onRowsInserted(const QModelIndex& parent, int first, int last)
{
    if (!sourceModel())
        return;

    if (parent.isValid())
        return;

    d->createProxyToSourceRowMap();
    endInsertRows();

    if (!sourceModel())
        return;

    int rowToRemove = first;
    for (int row = first; row <= last; ++row)
    {
        if (d->insertedRows.contains(index(rowToRemove, 0)))
        {
            auto insertedRowIndex = index(rowToRemove, 0);
            auto sourceRowIndex = index(d->sourceToProxyRow(row), 0);

            if (itemData(insertedRowIndex) == itemData(sourceRowIndex))
            {
                //rowToRemove remains in place if the proxy row is removed
                d->removeRows(rowToRemove, 1, {});
                continue;
            }
            rowToRemove++;
        }
    }
}

void WritableProxyModel::onRowsAboutToBeRemoved(const QModelIndex& parent, int start, int end)
{
    if (!sourceModel())
        return;

    if (parent.isValid())
        return;

    for (int row = start; row <= end; ++row)
    {
        auto sourceIndex = sourceModel()->index(row, 0);

        if (d->cache.contains(sourceIndex))
            d->moveFromCacheToInserted(sourceIndex);
    }

    auto sourceRemoveRanges = d->sourceRowRangesBetween(start, end);
    for (auto& sourceRemoveRange : sourceRemoveRanges)
    {
        auto proxyStart = sourceRemoveRange.first;
        auto proxyEnd = sourceRemoveRange.second;
        if (proxyStart == -1 || proxyEnd == -1)
            continue;

        d->removeRows(proxyStart, proxyEnd - proxyStart + 1);
    }
}

void WritableProxyModel::onRowsRemoved(const QModelIndex& parent, int first, int last)
{
    if (parent.isValid())
        return;

    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
    d->checkForDirtyRemoval({}, {});
}

void WritableProxyModel::onModelAboutToBeReset()
{
    beginResetModel();
    if (d->syncedRemovals)
    {
        d->clear();
        return;
    }

    for (auto iter = d->cache.begin(); iter != d->cache.end();)
    {
        auto key = iter.key();
        iter++;
        d->moveFromCacheToInserted(key);
    }
    d->alignInsertedRowsAtBeginning();
}

void WritableProxyModel::onModelReset()
{
    d->clearInvalidatedCache();
    d->createProxyToSourceRowMap();
    resetInternalData();
    d->checkForDirtyRemoval({}, {});
    endResetModel();
}


void WritableProxyModel::onRowsAboutToBeMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destinationParent, int destinationRow)
{
    if(sourceParent.isValid() || destinationParent.isValid())
        return;

    emit layoutAboutToBeChanged();

    d->storePersitentIndexes();
}

void WritableProxyModel::onRowsMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd, const QModelIndex& destinationParent, int destinationRow)
{
    if(sourceParent.isValid() || destinationParent.isValid())
        return;

    d->createProxyToSourceRowMap();
    d->updatePersistentIndexes();

    emit layoutChanged();
}

void WritableProxyModel::onLayoutAboutToBeChanged(const QList<QPersistentModelIndex>& sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    if (!sourceParents.isEmpty())
        return;

    emit layoutAboutToBeChanged();

    d->storePersitentIndexes();
}

void WritableProxyModel::onLayoutChanged(const QList<QPersistentModelIndex>& sourceParents, QAbstractItemModel::LayoutChangeHint hint)
{
    d->createProxyToSourceRowMap();
    d->updatePersistentIndexes();

    emit layoutChanged();
}
