#pragma once

#include <QAbstractProxyModel>

// WritableProxyModel is a QAbstractProxyModel that allows you to modify the data without modifying the source model.
// It is useful for implementing a "dirty" state for a model, where you can modify the data and then commit the changes
// to the source model.

// Supported features (reimplemented):
// - setData
// - setItemData
// - removeRows
// - insertRows
// - moveRows (TODO)
// - toVariantMap
// - to be continued...

// Limitations:
// - only 1 column (no grid models)
// - no parent index (no tree models)

class WritableProxyModelPrivate;

class WritableProxyModel : public QAbstractProxyModel
{
    Q_OBJECT

    Q_PROPERTY(bool dirty READ dirty NOTIFY dirtyChanged)
    //If true, the removals are synced with the source model. Removing an edited item from source will also remove it from proxy
    //If false, eemoving an edited item from source will not remove it from proxy. It will become a newly inserted row
    Q_PROPERTY(bool syncedRemovals READ syncedRemovals WRITE setSyncedRemovals NOTIFY syncedRemovalsChanged)

public:
    explicit WritableProxyModel(QObject* parent = nullptr);
    ~WritableProxyModel();

    Q_INVOKABLE QVariantMap toVariantMap() const;

    Q_INVOKABLE QVariantList getInsertedItems() const;
    Q_INVOKABLE QVariantList getEditedItems() const;
    Q_INVOKABLE QVariantList getRemovedItems() const;

    Q_INVOKABLE bool insert(int at, const QVariantMap& data = {});
    Q_INVOKABLE bool append(const QVariantMap& data = {});
    Q_INVOKABLE bool remove(int at);
    //Returns a VariantMap of the data at the given index
    //The map contains the role names as keys and the data as values
    Q_INVOKABLE QVariantMap get(int at) const;
    //Sets the data at the given index
    //The map contains the role names as keys and the data as values
    Q_INVOKABLE bool set(int at, const QVariantMap& data);

    bool dirty() const;
    bool syncedRemovals() const;

    //QAbstractProxyModel overrides
    void setSourceModel(QAbstractItemModel* sourceModel) override;

    int	columnCount(const QModelIndex& parent = QModelIndex()) const override;
    int	rowCount(const QModelIndex& parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;

    QMap<int, QVariant> itemData(const QModelIndex& index) const override;
    bool setItemData(const QModelIndex& index, const QMap<int, QVariant>& roles) override;

    bool removeRows(int row, int count, const QModelIndex& parent = QModelIndex()) override;
    bool insertRows(int row, int count, const QModelIndex& parent = QModelIndex()) override;

    QModelIndex index(int row, int column, const QModelIndex& parent = QModelIndex()) const override;
    QModelIndex sibling(int row, int column, const QModelIndex& idx) const override;
    QModelIndex parent(const QModelIndex& child) const override;
    QModelIndex mapToSource(const QModelIndex& proxyIndex) const override;
    QModelIndex mapFromSource(const QModelIndex& sourceIndex) const override;

    bool hasChildren(const QModelIndex& parent = QModelIndex()) const override;
    void revert() override;

signals:
    void dirtyChanged();
    void syncedRemovalsChanged();

private:
    void setDirty(bool flag);
    void setSyncedRemovals(bool syncedRemovals);

    void onSourceDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles);
    void onRowsAboutToBeInserted(const QModelIndex& parent, int start, int end);
    void onRowsInserted(const QModelIndex& parent, int first, int last);
    void onRowsAboutToBeRemoved(const QModelIndex& parent, int start, int end);
    void onRowsRemoved(const QModelIndex& parent, int first, int last);
    void onModelAboutToBeReset();
    void onModelReset();
    void onLayoutAboutToBeChanged(const QList<QPersistentModelIndex>& sourceParents, QAbstractItemModel::LayoutChangeHint hint);
    void onLayoutChanged(const QList<QPersistentModelIndex>& sourceParents, QAbstractItemModel::LayoutChangeHint hint);
    void onRowsAboutToBeMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd, const QModelIndex& destinationParent, int destinationRow);
    void onRowsMoved(const QModelIndex& sourceParent, int sourceStart, int sourceEnd, const QModelIndex& destinationParent, int destinationRow);

    QScopedPointer<WritableProxyModelPrivate> d;
    friend class WritableProxyModelPrivate;
};
