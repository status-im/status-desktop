#include "StatusQ/permissionutilsinternal.h"

#include <QAbstractItemModel>
#include <QDebug>

#include <set>

namespace {
int roleByName(QAbstractItemModel* model, const QString &roleName)
{
    if (!model)
        return -1;

    return model->roleNames().key(roleName.toUtf8(), -1);
}
}

PermissionUtilsInternal::PermissionUtilsInternal(QObject* parent)
    : QObject(parent)
{
}

QStringList PermissionUtilsInternal::getUniquePermissionTokenKeys(QAbstractItemModel* model) const
{
    if (!model)
        return {};

    const auto role = roleByName(model, QStringLiteral("holdingsListModel"));
    if (role == -1) {
        qWarning() << Q_FUNC_INFO << "Requested roleName 'holdingsListModel' not found!";
        return {};
    }

    std::set<QString> result; // unique, sorted by default

    const auto permissionsCount = model->rowCount();
    for (int i = 0; i < permissionsCount; i++) {
        const auto isPrivate = model->data(model->index(i, 0), roleByName(model, QStringLiteral("isPrivate"))).toBool();
        if (isPrivate)
            continue;

        const auto holdings = model->data(model->index(i, 0), role);
        if (holdings.isValid() && !holdings.isNull()) {
            const auto holdingItems = holdings.value<QAbstractItemModel*>();
            if (!holdingItems) {
                qWarning() << Q_FUNC_INFO << "Unable to cast 'holdingsListModel' to QAbstractItemModel *!";
                continue;
            }
            const auto holdingItemsCount = holdingItems->rowCount();
            for (int j = 0; j < holdingItemsCount; j++) {
                const auto keyRole = roleByName(holdingItems, QStringLiteral("key"));
                if (keyRole == -1) {
                    qWarning() << Q_FUNC_INFO << "Requested roleName 'key' not found!";
                    continue;
                }
                result.insert(holdingItems->data(holdingItems->index(j, 0), keyRole).toString().toUpper());
            }
        }
    }

    return {result.cbegin(), result.cend()};
}

// TODO return a QVariantMap (https://github.com/status-im/status-desktop/issues/11481) with key->channelName
QStringList PermissionUtilsInternal::getUniquePermissionChannels(QAbstractItemModel* model, const QList<int> &permissionTypes) const
{
    if (!model)
        return {};

    const auto role = roleByName(model, QStringLiteral("channelsListModel"));
    if (role == -1) {
        qWarning() << Q_FUNC_INFO << "Requested roleName 'channelsListModel' not found!";
        return {};
    }

    const auto permissionTypeRole = roleByName(model, QStringLiteral("permissionType"));

    std::set<QString> result; // unique, sorted by default

    const auto permissionsCount = model->rowCount();
    for (int i = 0; i < permissionsCount; i++) {
        if (!permissionTypes.isEmpty()) {
            const auto permissionType = model->data(model->index(i, 0), permissionTypeRole).toInt();
            if (!permissionTypes.contains(permissionType))
                continue;
        }

        const auto channels = model->data(model->index(i, 0), role);
        if (channels.isValid() && !channels.isNull()) {
            const auto channelItems = channels.value<QAbstractItemModel *>();
            if (!channelItems) {
                qWarning() << Q_FUNC_INFO << "Unable to cast 'channelsListModel' to QAbstractItemModel *!";
                continue;
            }

            const auto channelItemsCount = channelItems->rowCount();
            for (int j = 0; j < channelItemsCount; j++) {
                const auto keyRole = roleByName(channelItems, QStringLiteral("key"));
                if (keyRole == -1) {
                    qWarning() << Q_FUNC_INFO << "Requested roleName 'key' not found!";
                    continue;
                }
                result.insert(channelItems->data(channelItems->index(j, 0), keyRole).toString());
            }
        }
    }

    return {result.cbegin(), result.cend()};
}
