#pragma once

#include <QObject>
#include <QJsonArray>

class QAbstractItemModel;

class PermissionUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit PermissionUtilsInternal(QObject* parent = nullptr);

    //!< traverse the permissions @p model, and look for unique token keys recursively under holdingsListModel->key
    Q_INVOKABLE QStringList getUniquePermissionTokenKeys(QAbstractItemModel *model) const;

    //!< traverse the permissions @p model, and look for unique channels recursively under channelsListModel->key; filtering out @permissionTypes ([PermissionTypes.Type.FOO])
    //! @return an array of array<key,channelName>
    Q_INVOKABLE QJsonArray getUniquePermissionChannels(QAbstractItemModel *model, const QList<int> &permissionTypes = {}) const;
};
