#pragma once

#include <QObject>

class QAbstractItemModel;

class PermissionUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit PermissionUtilsInternal(QObject* parent = nullptr);

    //!< traverse the permissions @p model, and look for unique token keys recursively under holdingsListModel->key
    Q_INVOKABLE QStringList getUniquePermissionTokenKeys(QAbstractItemModel *model) const;

    //!< traverse the permissions @p model, and look for unique channel keys recursively under channelsListModel->key; filtering out @permissionTypes ([PermissionTypes.Type.FOO])
    Q_INVOKABLE QStringList getUniquePermissionChannels(QAbstractItemModel *model, const QList<int> &permissionTypes = {}) const;
};
