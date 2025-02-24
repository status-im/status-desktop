#pragma once

#include <QIdentityProxyModel>
#include <QPointer>
#include <QQmlComponent>
#include <QQmlContext>
#include <QQmlPropertyMap>
#include <QSet>

#include "modelsyncedcontainer.h"

class QQmlEngine;

class ObjectProxyModel : public QIdentityProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QQmlComponent* delegate READ delegate
               WRITE setDelegate NOTIFY delegateChanged)

    Q_PROPERTY(QStringList expectedRoles READ expectedRoles
               WRITE setExpectedRoles NOTIFY expectedRolesChanged)

    Q_PROPERTY(QStringList exposedRoles READ exposedRoles
               WRITE setExposedRoles NOTIFY exposedRolesChanged)

public:
    explicit ObjectProxyModel(QObject* parent = nullptr);

    QVariant data(const QModelIndex& index, int role) const override;
    void setSourceModel(QAbstractItemModel* sourceModel) override;
    QHash<int, QByteArray> roleNames() const override;

    QQmlComponent* delegate() const;
    void setDelegate(QQmlComponent* delegate);

    void setExpectedRoles(const QStringList& expectedRoles);
    const QStringList& expectedRoles() const;

    void setExposedRoles(const QStringList& exposedRoles);
    const QStringList& exposedRoles() const;

    Q_INVOKABLE QObject* proxyObject(int index) const;

signals:
    void delegateChanged();
    void expectedRolesChanged();
    void exposedRolesChanged();

protected slots:
    void resetInternalData();

private slots:
    void onCustomRoleChanged();
    void emitAllDataChanged();

private:
    struct Entry {
        std::unique_ptr<QObject> proxy;
        QQmlPropertyMap* rowData = nullptr;
        QQmlContext* context = nullptr;
    };

    void initRoles();
    void updateRoleNames();
    void updateIndexes(int from, int to);

    QHash<int, QByteArray> findExpectedRoles(const QHash<int, QByteArray> &roleNames,
                                             const QStringList &expectedRoles);

    QPointer<QQmlComponent> m_delegate;
    QHash<int, QByteArray> m_expectedRoleNames;

    bool m_dataChangedQueued = false;

    QStringList m_expectedRoles;
    QStringList m_exposedRoles;

    QHash<int, QByteArray> m_roleNames;
    QSet<int> m_exposedRolesSet;

    mutable ModelSyncedContainer<Entry> m_container;
};
