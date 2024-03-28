#pragma once

#include <QObject>
#include <QJsonArray>

class QAbstractItemModel;

namespace PermissionTypes {
enum Type { NoPermissions = -1, None = 0, Admin, Member, Read, ViewAndPost, TokenMaster, Owner };
}

class PermissionUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit PermissionUtilsInternal(QObject* parent = nullptr);

    //!< traverse the permissions @p model, and look for unique token keys recursively under holdingsListModel->key
    Q_INVOKABLE QStringList getUniquePermissionTokenKeys(QAbstractItemModel *model) const;

    //!< traverse the permissions @p model, and look for unique channels recursively under channelsListModel->key; filtering out @p permissionTypes ([PermissionTypes.Type.FOO])
    //! @return an array of `array<key,channelName>`, sorted by `channelName`
    Q_INVOKABLE QJsonArray getUniquePermissionChannels(QAbstractItemModel *model, const QList<int> &permissionTypes = {}) const;

    //!< Check whether the user can join the community and under which (highest possible) role
    //!< @return either:
    //!          - `NoPermissions` if the permissionsModel is empty or malformed
    //!          - `Member` if no such join permission(s) exist in the permissionsModel (e.g. when it has channel only permissions)
    //!          - if satisfied: `TokenMaster`, `Admin`, or `Member`, in this order of relevance
    //!          - `None` if no permission to join is satisfied (user can't join at all)
    Q_INVOKABLE int /*PermissionTypes::Type*/ isEligibleToJoinAs(QAbstractItemModel *permissionsModel) const;
};
