#pragma once

#include <QIdentityProxyModel>

class LeftJoinModel : public QIdentityProxyModel
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

    QHash<int, QByteArray> roleNames() const override;
    QVariant data(const QModelIndex& index, int role) const override;
    void setSourceModel(QAbstractItemModel* newSourceModel) override;

signals:
    void leftModelChanged();
    void rightModelChanged();
    void joinRoleChanged();

private:
    void initializeIfReady();
    void initialize();

    int m_rightModelRolesOffset = 0;
    QHash<int, QByteArray> m_roleNames;
    QVector<int> m_joinedRoles;

    QString m_joinRole;
    int m_leftModelJoinRole = 0;
    int m_rightModelJoinRole = 0;

    QAbstractItemModel* m_leftModel = nullptr;
    QAbstractItemModel* m_rightModel = nullptr;

    bool m_leftModelDestroyed = false;
    bool m_rightModelDestroyed = false;

    mutable QPersistentModelIndex m_lastUsedRightModelIndex;
};
