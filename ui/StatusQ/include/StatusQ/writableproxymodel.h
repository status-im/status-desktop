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

public:
    explicit WritableProxyModel(QObject* parent = nullptr);
    ~WritableProxyModel();

    Q_INVOKABLE QVariantMap toVariantMap() const;
    Q_INVOKABLE bool insert(int at);
    Q_INVOKABLE bool remove(int at);
    //Returns a VariantMap of the data at the given index
    //The map contains the role names as keys and the data as values
    Q_INVOKABLE QVariantMap get(int at) const;
    //Sets the data at the given index
    //The map contains the role names as keys and the data as values
    Q_INVOKABLE bool set(int at, const QVariantMap& data);

    bool dirty() const;

    //QAbstractProxyModel overrides
    void setSourceModel(QAbstractItemModel* sourceModel) override;

    int	columnCount(const QModelIndex &parent = QModelIndex()) const override;
    int	rowCount(const QModelIndex &parent = QModelIndex()) const override;

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    bool setData(const QModelIndex& index, const QVariant& value, int role = Qt::EditRole) override;

    QMap<int, QVariant> itemData(const QModelIndex &index) const override;
    bool setItemData(const QModelIndex& index, const QMap<int, QVariant>& roles) override;

    bool removeRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;
    bool insertRows(int row, int count, const QModelIndex &parent = QModelIndex()) override;

    QModelIndex index(int row, int column, const QModelIndex &parent = QModelIndex()) const override;
    QModelIndex sibling(int row, int column, const QModelIndex &idx) const override;
    QModelIndex parent(const QModelIndex &child) const override;
    QModelIndex mapToSource(const QModelIndex &proxyIndex) const override;
    QModelIndex mapFromSource(const QModelIndex &sourceIndex) const override;

    bool hasChildren(const QModelIndex &parent = QModelIndex()) const override;
    void revert() override;

    // TODO: implement these
    // bool moveRows(const QModelIndex &sourceParent, int sourceRow, int count, const QModelIndex &destinationParent, int destinationChild) override;
    // bool	submit() override;

signals:
    void dirtyChanged();

private:
    void setDirty(bool flag);

    void handleSourceDataChanged(const QModelIndex& topLeft, const QModelIndex& bottomRight, const QVector<int>& roles);
    void handleRowsAboutToBeInserted(const QModelIndex &parent, int start, int end);
    void handleRowsInserted(const QModelIndex &parent, int first, int last);
    void handleRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end);
    void handleRowsRemoved(const QModelIndex &parent, int first, int last);
    void handleModelAboutToBeReset();
    void handleModelReset();
    void handleLayoutAboutToBeChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint);
    void handleLayoutChanged(const QList<QPersistentModelIndex> &sourceParents, QAbstractItemModel::LayoutChangeHint hint);
    void handleRowsMoved(const QModelIndex &sourceParent, int sourceStart, int sourceEnd, const QModelIndex &destinationParent, int destinationRow);

    bool m_dirty{false};

    QScopedPointer<WritableProxyModelPrivate> d;
    friend class WritableProxyModelPrivate;
};
