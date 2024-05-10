#pragma once

#include <QObject>
#include <QJsonArray>

#include <optional>

class QAbstractItemModel;

namespace PermissionTypes {
enum Type { NoPermissions = -1, None = 0, Admin, Member, Read, ViewAndPost, TokenMaster, Owner };
}

class PermissionUtilsInternal : public QObject
{
    Q_OBJECT

public:
    explicit PermissionUtilsInternal(QObject* parent = nullptr);

    Q_INVOKABLE QVariantMap getTokenByKey(QAbstractItemModel *model, const QVariant& keyValue) const;

    //!< traverse the permissions @p model, and look for unique token keys recursively under holdingsListModel->key
    Q_INVOKABLE QStringList getUniquePermissionTokenKeys(QAbstractItemModel *model, int type) const;

    //!< traverse the permissions @p model, and look for unique channels recursively under channelsListModel->key; filtering out @p permissionTypes ([PermissionTypes.Type.FOO])
    //! @return an array of `array<key,channelName>`, sorted by `channelName`
    Q_INVOKABLE QJsonArray getUniquePermissionChannels(QAbstractItemModel *model, const QList<int> &permissionTypes = {}) const;

    //!< Check whether the user can join the community and under which (highest possible) role
    //!< @return either:
    //!          - `NoPermissions` if the permissionsModel is empty or malformed, or has no join type permissions
    //!          - if satisfied: `TokenMaster`, `Admin`, or `Member`, in this order of relevance
    //!          - `Member` if no such join permission(s) exist in the permissionsModel (e.g. when it has channel only permissions)
    //!          - `None` if no permission to join is satisfied (user can't join at all)
    Q_INVOKABLE int /*PermissionTypes::Type*/ isEligibleToJoinAs(QAbstractItemModel *permissionsModel) const;

    //!< @return true when the @p permissionsModel contains some kind of "join" permission; false when the community is free to join
    Q_INVOKABLE bool isTokenGatedCommunity(QAbstractItemModel *permissionsModel) const;

private:
    std::optional<PermissionTypes::Type> isEligibleToJoinAsInternal(QAbstractItemModel *permissionsModel) const;
};
