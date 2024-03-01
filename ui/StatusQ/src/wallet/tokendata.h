#pragma once

#include <QColor>
#include <QString>
#include <QVariant>

static const auto undefinedTokenOrder = INT_MAX;

// Generic structure representing a token, collectible, collection or community token
struct TokenData {
    QString symbol, name, communityId, communityName, communityImage, collectionUid, collectionName, image;
    QColor backgroundColor{Qt::transparent};
    QVariant balance, currencyBalance;
    QVariant balances, marketDetails, decimals;
    int customSortOrderNo{undefinedTokenOrder};
    bool isSelfCollection{false};
};

// mirrors CollectiblePreferencesItemType from src/backend/collectibles_types.nim
enum class CollectiblePreferencesItemType { NonCommunityCollectible = 1, CommunityCollectible, Collection, Community };

CollectiblePreferencesItemType tokenDataToCollectiblePreferencesItemType(const TokenData& tokenData);

struct TokenOrder {
    QString symbol;
    int sortOrder;
    bool visible;
    QString communityId;
    QString collectionUid;
    CollectiblePreferencesItemType type;

    // Defines a default TokenOrder, order is not set (undefinedTokenOrder) and visible is false
    TokenOrder();
    TokenOrder(const QString& symbol,
               int sortOrder,
               bool visible,
               const QString& communityId,
               const QString& collectionUid,
               CollectiblePreferencesItemType type);

    bool operator==(const TokenOrder& rhs) const
    {
        return symbol == rhs.symbol && sortOrder == rhs.sortOrder && visible == rhs.visible &&
               communityId == rhs.communityId && collectionUid == rhs.collectionUid && type == rhs.type;
    }

    QString getGroupId() const { return !communityId.isEmpty() ? communityId : collectionUid; }
};

using SerializedTokenData = QHash<QString, TokenOrder>;

QString tokenOrdersToJson(const SerializedTokenData& data, bool areCollectibles);
SerializedTokenData tokenOrdersFromJson(const QString& json_string, bool areCollectibles);
