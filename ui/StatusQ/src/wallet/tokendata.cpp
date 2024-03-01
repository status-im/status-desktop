#include "tokendata.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QList>

CollectiblePreferencesItemType tokenDataToCollectiblePreferencesItemType(const TokenData& token, bool isCommunity, bool itemsAreGroups)
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
        obj["key"] = data.symbol;
        obj["position"] = data.sortOrder;
        obj["visible"] = data.visible;
        if (data.isCommunityGroup) {
            obj["isCommunityGroup"] = true;
            obj["communityId"] = data.communityId;
        }
        if (data.isCollectionGroup) {
            obj["isCollectionGroup"] = true;
            obj["collectionUid"] = data.collectionUid;
        }

        if (areCollectible) {
            // see CollectiblePreferences in src/backend/collectibles_types.nim
            // type cover separation of groups and collectibles
            obj["type"] = static_cast<int>(data.type);
        } else { // is asset
            // see TokenPreferences in src/backend/backend.nim
            // TODO #13312: handle "groupPosition" for asset
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
        if (obj.contains("isCommunityGroup")) {
            data.isCommunityGroup = obj["isCommunityGroup"].toBool();
            data.communityId = obj["communityId"].toString();
        }
        if (obj.contains("isCollectionGroup")) {
            data.isCollectionGroup = obj["isCollectionGroup"].toBool();
            data.collectionUid = obj["collectionUid"].toString();
        }

        if (areCollectibles) {
            // see CollectiblePreferences in src/backend/collectibles_types.nim
            data.type = static_cast<CollectiblePreferencesItemType>(obj["type"].toInt());
        } else { // is asset
            // see TokenPreferences in src/backend/backend.nim
            // TODO #13312: handle "groupPosition" for assets
        }

        dataList.insert(data.symbol, data);
    }

    return dataList;
}