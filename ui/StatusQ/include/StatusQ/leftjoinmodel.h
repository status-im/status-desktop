#pragma once

#include <QAbstractListModel>
#include <QPointer>
#include <QQmlParserStatus>

class LeftJoinModel : public QAbstractListModel, public QQmlParserStatus
{
    Q_OBJECT
    Q_INTERFACES(QQmlParserStatus)

    Q_PROPERTY(QAbstractItemModel* leftModel READ leftModel
               WRITE setLeftModel NOTIFY leftModelChanged)

    Q_PROPERTY(QAbstractItemModel* rightModel READ rightModel
               WRITE setRightModel NOTIFY rightModelChanged)

    Q_PROPERTY(QString joinRole READ joinRole
               WRITE setJoinRole NOTIFY joinRoleChanged)

    Q_PROPERTY(QStringList rolesToJoin READ rolesToJoin
               WRITE setRolesToJoin NOTIFY rolesToJoinChanged)

public:
    explicit LeftJoinModel(QObject* parent = nullptr);

    void setLeftModel(QAbstractItemModel* model);
    QAbstractItemModel* leftModel() const;

    void setRightModel(QAbstractItemModel* model);
    QAbstractItemModel* rightModel() const;

    void setJoinRole(const QString& joinRole);
    const QString& joinRole() const;

    void setRolesToJoin(const QStringList& roles);
    const QStringList& rolesToJoin() const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role) const override;

    void classBegin() override;
    void componentComplete() override;

signals:
    void leftModelChanged();
    void rightModelChanged();
    void joinRoleChanged();
    void rolesToJoinChanged();

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
    QStringList m_rolesToJoin;
    int m_leftModelJoinRole = 0;
    int m_rightModelJoinRole = 0;

    QPointer<QAbstractItemModel> m_leftModel;
    QPointer<QAbstractItemModel> m_rightModel;

    bool m_initialized = false;

    mutable QPersistentModelIndex m_lastUsedRightModelIndex;

    // helpers for handling layoutChanged from source
    QList<QPersistentModelIndex> m_layoutChangePersistentIndexes;
    QModelIndexList m_proxyIndexes;
};
