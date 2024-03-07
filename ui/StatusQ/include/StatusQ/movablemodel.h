#pragma once

#include <QAbstractListModel>
#include <QPointer>

#include <vector>

class MovableModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel
               WRITE setSourceModel NOTIFY sourceModelChanged)

    Q_PROPERTY(bool synced READ synced NOTIFY syncedChanged)
public:
    explicit MovableModel(QObject* parent = nullptr);

    void setSourceModel(QAbstractItemModel *sourceModel);
    QAbstractItemModel* sourceModel() const;

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void desyncOrder();
    Q_INVOKABLE void syncOrder();
    Q_INVOKABLE void move(int from, int to, int count = 1);
    Q_INVOKABLE QVector<int> order() const;

    bool synced() const;

signals:
    void sourceModelChanged();
    void syncedChanged();

protected slots:
    void resetInternalData();

private:
    // source signals handling for synced state
    void syncedSourceDataChanged(const QModelIndex& topLeft,
                           const QModelIndex& bottomRight,
                           const QVector<int>& roles);
    void sourceLayoutAboutToBeChanged(const QList<QPersistentModelIndex>& parents,
                                      QAbstractItemModel::LayoutChangeHint hint);
    void sourceLayoutChanged(const QList<QPersistentModelIndex>& parents,
                             QAbstractItemModel::LayoutChangeHint hint);

    // source signals handling for desynced state
    void desyncedSourceDataChanged(const QModelIndex& topLeft,
                                   const QModelIndex& bottomRight,
                                   const QVector<int>& roles);
    void sourceRowsInserted(const QModelIndex &parent, int first, int last);
    void sourceRowsAboutToBeRemoved(const QModelIndex &parent, int first, int last);

    // other
    void connectSignalsForSyncedState();
    void syncOrderInternal();

    QPointer<QAbstractItemModel> m_sourceModel;
    bool m_synced = true;
    std::vector<QPersistentModelIndex> m_indexes;

    // helpers for handling layoutChanged from source when synced
    QList<QPersistentModelIndex> m_layoutChangePersistentIndexes;
    QModelIndexList m_proxyIndexes;
};
