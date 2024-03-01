#include "tokendata.h"

#include <QJsonArray>
#include <QJsonDocument>
#include <QJsonObject>
#include <QList>

CollectiblePreferencesItemType tokenDataToCollectiblePreferencesItemType(const TokenData& token)
{
    if (!token.communityId.isEmpty()) {
        return CollectiblePreferencesItemType::CommunityCollectible;
    } else if (!token.collectionUid.isEmpty()) {
        return CollectiblePreferencesItemType::Collection;
    } else {
        return CollectiblePreferencesItemType::NonCommunityCollectible;
    }
    // TODO #13313: When is CollectiblePreferencesItemType::Community used? instead of CommunityCollectible?
}

TokenOrder::TokenOrder() : sortOrder(undefinedTokenOrder) {}

TokenOrder::TokenOrder(const QString& symbol,
                       int sortOrder,
                       bool visible,
                       const QString& communityId,
                       const QString& collectionUid,
                       CollectiblePreferencesItemType type)
    : symbol(symbol)
    , sortOrder(sortOrder)
    , visible(visible)
    , communityId(communityId)
    , collectionUid(collectionUid)
    , type(type)
{
}

/// reverse of tokenOrdersFromJson
QString tokenOrdersToJson(const SerializedTokenData& dataList, bool areCollectible)
{
    QJsonArray jsonArray;
    for (const TokenOrder& data : dataList) {
        QJsonObject obj;
        obj["key"] = data.symbol;
        obj["position"] = data.sortOrder;
        obj["visible"] = data.visible;
        if (!data.collectionUid.isEmpty()) {
            obj["collectionUid"] = data.collectionUid;
        }
        if (!data.communityId.isEmpty()) {
            obj["communityId"] = data.communityId;
        }

        if (areCollectible) {
            // see CollectiblePreferences in src/backend/collectibles_types.nim
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

/// reverse of tokenOrdersToJson
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
        if (obj.contains("collectionUid")) {
            data.collectionUid = obj["collectionUid"].toString();
        }
        if (obj.contains("communityId")) {
            data.communityId = obj["communityId"].toString();
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