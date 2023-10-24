#pragma once

#include <QIdentityProxyModel>
#include <QQmlListProperty>

class RoleRename : public QObject {
    Q_OBJECT

    Q_PROPERTY(QString from READ from WRITE setFrom NOTIFY fromChanged)
    Q_PROPERTY(QString to READ to WRITE setTo NOTIFY toChanged)

public:
    explicit RoleRename(QObject* parent = nullptr);

    void setFrom(const QString& from);
    const QString& from() const;

    void setTo(const QString& to);
    const QString& to() const;

signals:
    void fromChanged();
    void toChanged();

private:
    QString m_from;
    QString m_to;
};

class RolesRenamingModel : public QIdentityProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QQmlListProperty<RoleRename> mapping READ mapping CONSTANT)

public:
    explicit RolesRenamingModel(QObject* parent = nullptr);

    QQmlListProperty<RoleRename> mapping();
    QHash<int, QByteArray> roleNames() const override;

private:
    mutable bool m_rolesFetched = false;
    QList<RoleRename*> m_mapping;
};
