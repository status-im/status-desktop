#pragma once

#include <QAbstractListModel>
#include <QPointer>

#include <vector>

class MovableModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* sourceModel READ sourceModel
               WRITE setSourceModel NOTIFY sourceModelChanged)

    Q_PROPERTY(bool detached READ detached NOTIFY detachedChanged)
public:
    explicit MovableModel(QObject *parent = nullptr);

    void setSourceModel(QAbstractItemModel *sourceModel);
    QAbstractItemModel *sourceModel() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    Q_INVOKABLE void detach();
    Q_INVOKABLE void move(int from, int to, int count = 1);
    Q_INVOKABLE QVector<int> order() const;

    bool detached() const;

signals:
    void sourceModelChanged();
    void detachedChanged();

protected slots:
    void resetInternalData();

private:
    QPointer<QAbstractItemModel> m_sourceModel;

    bool m_detached = false;
    std::vector<QPersistentModelIndex> m_indexes;
};
