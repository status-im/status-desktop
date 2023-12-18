#pragma once

#include <QAbstractListModel>
#include <QPointer>

class LeftJoinModel : public QAbstractListModel
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* leftModel READ leftModel
               WRITE setLeftModel NOTIFY leftModelChanged)

    Q_PROPERTY(QAbstractItemModel* rightModel READ rightModel
               WRITE setRightModel NOTIFY rightModelChanged)

    Q_PROPERTY(QString joinRole READ joinRole
               WRITE setJoinRole NOTIFY joinRoleChanged)

public:
    explicit LeftJoinModel(QObject* parent = nullptr);

    void setLeftModel(QAbstractItemModel* model);
    QAbstractItemModel* leftModel() const;

    void setRightModel(QAbstractItemModel* model);
    QAbstractItemModel* rightModel() const;

    void setJoinRole(const QString& joinRole);
    const QString& joinRole() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role) const override;

signals:
    void leftModelChanged();
    void rightModelChanged();
    void joinRoleChanged();

private:
    void initializeIfReady(bool reset);
    void initialize(bool reset);

    void connectLeftModelSignals();
    void connectRightModelSignals();

    int m_rightModelRolesOffset = 0;
    QHash<int, QByteArray> m_leftRoleNames;
    QHash<int, QByteArray> m_rightRoleNames;
    QHash<int, QByteArray> m_roleNames;
    QVector<int> m_joinedRoles;

    QString m_joinRole;
    int m_leftModelJoinRole = 0;
    int m_rightModelJoinRole = 0;

    QPointer<QAbstractItemModel> m_leftModel;
    QPointer<QAbstractItemModel> m_rightModel;

    bool m_initialized = false;

    mutable QPersistentModelIndex m_lastUsedRightModelIndex;
};
