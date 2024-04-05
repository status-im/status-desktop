#include "tokendata.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QList>

// This is used by he collectibles to deconflict types saved. However, the UX ignores them on restore/load
// and relies on the fact that all identities ("key" in backend and "symbol" in frontend) are unique between all
// types
CollectiblePreferencesItemType tokenDataToCollectiblePreferencesItemType(bool isCommunity, bool itemsAreGroups)
{
    if (itemsAreGroups) {
        if (isCommunity) {
            return CollectiblePreferencesItemType::Community;
        } else {
            return CollectiblePreferencesItemType::Collection;
        }
    } else {
        if (isCommunity) {
            return CollectiblePreferencesItemType::CommunityCollectible;
        } else {
            return CollectiblePreferencesItemType::NonCommunityCollectible;
        }
    }
}

struct GroupingInfo {
    bool isCommunity = false;
    bool itemsAreGroups = false;
};

GroupingInfo collectiblePreferencesItemTypeToGroupsInfo(CollectiblePreferencesItemType type)
{
    switch (type) {
    case CollectiblePreferencesItemType::Community:
        return {true /* isCommunity */, true /*itemsAreGroups*/};
    case CollectiblePreferencesItemType::Collection:
        return {false /* isCommunity */, true /*itemsAreGroups*/};
    case CollectiblePreferencesItemType::CommunityCollectible:
        return {true /* isCommunity */, false /*itemsAreGroups*/};
    case CollectiblePreferencesItemType::NonCommunityCollectible:
        return {false /* isCommunity */, false /*itemsAreGroups*/};
    default:
        qFatal("Unknown collectible type");
        return {false, false};
    }
}

TokenOrder::TokenOrder() : sortOrder(undefinedTokenOrder) {}

TokenOrder::TokenOrder(const QString& symbol,
                       int sortOrder,
                       bool visible,
                       bool isCommunityGroup,
                       const QString& communityId,
                       bool isCollectionGroup,
                       const QString& collectionUid,
                       CollectiblePreferencesItemType type)
    : symbol(symbol)
    , sortOrder(sortOrder)
    , visible(visible)
    , isCommunityGroup(isCommunityGroup)
    , communityId(communityId)
    , isCollectionGroup(isCollectionGroup)
    , collectionUid(collectionUid)
    , type(type)
{
}

/// reverse of \c tokenOrdersFromJson
///
/// for protocol structure, see:
/// \see CollectiblePreferences in src/backend/collectibles_types.nim
/// \see TokenPreferences in src/backend/backend.nim
QString tokenOrdersToJson(const SerializedTokenData& dataList, bool areCollectible)
{
    QJsonArray jsonArray;
    for (const TokenOrder& data : dataList) {
        QJsonObject obj;
        // The  collectibles group ordering is handled in the backend.
        obj["key"] = data.symbol;
        obj["position"] = data.sortOrder;
        obj["visible"] = data.visible;

        if (areCollectible) {
            // ignore communityId and collectionId which are embedded in key for collectibles
            // ignore isCommunityGroup and isCollectionGroup that are embedded in type for collectibles
            // by providing the required separation of groups and collectibles which are not yet used

            // see CollectiblePreferences in src/backend/collectibles_types.nim
            obj["type"] = static_cast<int>(data.type);
        } else { // is asset
            // We ignore isCollectionGroup that doesn't exist for assets
            // see TokenPreferences in src/backend/backend.nim

            // isCommunityGroup is true only if communityId is valid
            if (data.isCommunityGroup) {
                obj["groupPosition"] = data.sortOrder;
                obj["communityId"] = data.communityId;
            }
        }
        jsonArray.append(obj);
    }

    QJsonDocument doc(jsonArray);
    QString json_string = doc.toJson(QJsonDocument::Compact);

    return json_string;
}

/// reverse of \c tokenOrdersToJson
///
/// for protocol structure, see:
/// \see CollectiblePreferences in src/backend/collectibles_types.nim
/// \see TokenPreferences in src/backend/backend.nim
SerializedTokenData tokenOrdersFromJson(const QString& json_string, bool areCollectibles)
{
    QJsonDocument doc = QJsonDocument::fromJson(json_string.toUtf8());
    QJsonArray jsonArray = doc.array();

    SerializedTokenData dataList;
    for (const QJsonValue& value : jsonArray) {
        QJsonObject obj = value.toObject();
        TokenOrder data;

        data.symbol = obj["key"].toString();
        data.sortOrder = obj["position"].toInt();
        data.visible = obj["visible"].toBool();
        if (areCollectibles) {
            // see CollectiblePreferences in src/backend/collectibles_types.nim
            data.type = static_cast<CollectiblePreferencesItemType>(obj["type"].toInt());
            auto groupingInfo = collectiblePreferencesItemTypeToGroupsInfo(data.type);
            data.isCommunityGroup = groupingInfo.isCommunity;
            if (data.isCommunityGroup) {
                data.communityId = data.symbol;
            }
            data.isCollectionGroup = groupingInfo.itemsAreGroups;
            if (data.isCollectionGroup) {
                data.collectionUid = data.symbol;
            }
        } else { // is asset
            // see TokenPreferences in src/backend/backend.nim
            if (obj.contains("groupPosition")) {
                data.isCommunityGroup = true;
                data.communityId = obj["communityId"].toString();
            }
        }

        dataList.insert(data.symbol, data);
    }

    return dataList;
}