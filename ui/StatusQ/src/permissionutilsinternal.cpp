#include "StatusQ/permissionutilsinternal.h"

#include <QAbstractItemModel>
#include <QDebug>

#include <set>
#include <vector>
#include <algorithm>

namespace {
constexpr int roleByName(QAbstractItemModel* model, const QString &roleName)
{
    if (!model)
        return -1;

    return model->roleNames().key(roleName.toUtf8(), -1);
}
}

Q_DECL_CONST_FUNCTION Q_DECL_CONSTEXPR inline uint qHash(PermissionTypes::Type key, uint seed = 0) noexcept {
    return qHash(static_cast<int>(key), seed);
}

PermissionUtilsInternal::PermissionUtilsInternal(QObject* parent)
    : QObject(parent)
{
}

QStringList PermissionUtilsInternal::getUniquePermissionTokenKeys(QAbstractItemModel* model, int tokenType) const
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
            const auto keyRole = roleByName(holdingItems, QStringLiteral("key"));

            if (keyRole == -1) {
                qWarning() << Q_FUNC_INFO << "Requested roleName 'key' not found!";
                continue;
            }

            const auto typeRole = roleByName(holdingItems, QStringLiteral("type"));

            if (typeRole == -1) {
                qWarning() << Q_FUNC_INFO << "Requested roleName 'type' not found!";
                continue;
            }

            for (int j = 0; j < holdingItemsCount; j++) {
                auto idx = holdingItems->index(j, 0);
                QString key = holdingItems->data(idx, keyRole).toString().toUpper();
                int type  = holdingItems->data(idx, typeRole).toInt();

                if (type == tokenType)
                    result.insert(key);
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

std::optional<PermissionTypes::Type> PermissionUtilsInternal::isEligibleToJoinAsInternal(
    QAbstractItemModel *permissionsModel) const
{
    if (!permissionsModel)
        return PermissionTypes::Type::NoPermissions;

    const auto permissionTypeRole = roleByName(permissionsModel, QStringLiteral("permissionType"));
    if (permissionTypeRole == -1) {
        qWarning() << Q_FUNC_INFO << "Requested roleName 'permissionType' not found; no permissions at all";
        return PermissionTypes::Type::NoPermissions;
    }

    const auto tokenCriteriaMetRole = roleByName(permissionsModel, QStringLiteral("tokenCriteriaMet"));
    if (tokenCriteriaMetRole == -1) {
        qWarning() << Q_FUNC_INFO << "Requested roleName 'tokenCriteriaMet' not found; no permissions at all";
        return PermissionTypes::Type::NoPermissions;
    }

    constexpr auto isJoinTypePermission = [](PermissionTypes::Type type) {
        return type == PermissionTypes::Type::TokenMaster ||
               type == PermissionTypes::Type::Admin ||
               type == PermissionTypes::Type::Member;
    };

    constexpr auto isMemberPermission = [](PermissionTypes::Type type) {
        return type == PermissionTypes::Type::Member;
    };

    const auto permissionsCount = permissionsModel->rowCount();
    bool hasMemberPermission{false};
    QSet<PermissionTypes::Type> tmpRes;
    for (int i = 0; i < permissionsCount; i++) {
        const auto permissionType = static_cast<PermissionTypes::Type>(permissionsModel->data(permissionsModel->index(i, 0), permissionTypeRole).toInt());
        if (isJoinTypePermission(permissionType)) {
            if (isMemberPermission(permissionType))
                hasMemberPermission = true;
            const auto tokenCriteriaMet = permissionsModel->data(permissionsModel->index(i, 0), tokenCriteriaMetRole).toBool();
            if (tokenCriteriaMet) {
                tmpRes.insert(permissionType);
            }
        }
    }

    if (tmpRes.contains(PermissionTypes::Type::TokenMaster))
        return PermissionTypes::Type::TokenMaster;

    if (tmpRes.contains(PermissionTypes::Type::Admin))
        return PermissionTypes::Type::Admin;

    if (tmpRes.contains(PermissionTypes::Type::Member))
        return PermissionTypes::Type::Member;

    if (!hasMemberPermission)
        return {}; // no join permissions -> free to join

    return PermissionTypes::Type::None; // not allowed to join due to permissions not satisfied
}

int /*PermissionTypes::Type*/ PermissionUtilsInternal::isEligibleToJoinAs(QAbstractItemModel *permissionsModel) const
{
    return isEligibleToJoinAsInternal(permissionsModel).value_or(PermissionTypes::Type::Member);
}

bool PermissionUtilsInternal::isTokenGatedCommunity(QAbstractItemModel *permissionsModel) const
{
    const auto result = isEligibleToJoinAsInternal(permissionsModel);
    return result && *result > PermissionTypes::Type::NoPermissions;
}

QVariantMap PermissionUtilsInternal::getTokenByKey(QAbstractItemModel *model,
                                                   const QVariant &keyValue) const
{
    if (!model)
        return {};

    const auto roles = model->roleNames();
    const auto keyRole = roles.key(QByteArrayLiteral("key"), -1);
    const auto subItemsRole = roles.key(QByteArrayLiteral("subItems"), -1);

    const auto count = model->rowCount();
    for (int i = 0; i < count; i++) {
        const auto modelIndex = model->index(i, 0);
        if (keyRole != -1 && modelIndex.data(keyRole) == keyValue) {
            QVariantMap result;
            for (auto it = roles.cbegin(); it != roles.cend(); ++it)
                result.insert(it.value(), modelIndex.data(it.key()));
            return result;
        }

        if (subItemsRole != -1) {
            const auto subItemModel = qvariant_cast<QAbstractItemModel *>(modelIndex.data(subItemsRole));
            if (subItemModel) {
                const auto subItem = getTokenByKey(subItemModel, keyValue);
                if (!subItem.isEmpty())
                    return subItem;
            }
        }
    }

    return {};
}
