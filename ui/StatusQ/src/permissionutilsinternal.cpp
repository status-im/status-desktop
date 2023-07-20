#include "StatusQ/permissionutilsinternal.h"

#include <QAbstractItemModel>
#include <QDebug>

#include <set>
#include <vector>
#include <algorithm>

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

QJsonArray PermissionUtilsInternal::getUniquePermissionChannels(QAbstractItemModel* model, const QList<int> &permissionTypes) const
{
    if (!model)
        return {};

    const auto role = roleByName(model, QStringLiteral("channelsListModel"));
    if (role == -1) {
        qWarning() << Q_FUNC_INFO << "Requested roleName 'channelsListModel' not found!";
        return {};
    }

    const auto permissionTypeRole = roleByName(model, QStringLiteral("permissionType"));

    std::vector<std::pair<QString,QString>> tmpRes; // key,channelName

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
                const auto nameRole = roleByName(channelItems, QStringLiteral("channelName"));
                if (keyRole == -1) {
                    qWarning() << Q_FUNC_INFO << "Requested roleName 'key' not found!";
                    continue;
                }
                tmpRes.emplace_back(channelItems->data(channelItems->index(j, 0), keyRole).toString(),
                                    channelItems->data(channelItems->index(j, 0), nameRole).toString());
            }
        }
    }

    // sort by value (channel name)
    std::sort(tmpRes.begin(), tmpRes.end(), [](const auto& lhs, const auto& rhs) {
        return lhs.second.localeAwareCompare(rhs.second) < 0;
    });

    // remove dupes
    tmpRes.erase(std::unique(tmpRes.begin(), tmpRes.end()), tmpRes.end());

    // construct the (sorted) result
    QJsonArray result;
    std::transform(tmpRes.cbegin(), tmpRes.cend(), std::back_inserter(result), [](const auto& channel) -> QJsonArray {
        return {channel.first, channel.second};
    });

    return result;
}
