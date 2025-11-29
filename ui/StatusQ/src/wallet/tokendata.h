#pragma once

#include <QColor>
#include <QString>
#include <QVariant>

static constexpr auto undefinedTokenOrder = INT_MAX;

// Generic structure representing an asset, collectible, collection or community token
struct TokenData {
    QString key, tokenKey, crossChainId, chainId, address, symbol, name, communityId, communityName, communityImage,
        collectionUid, collectionName, image;
    QColor backgroundColor{Qt::transparent};
    QVariant balance, currencyBalance;
    QVariant balances, marketDetails, decimals;
    int customSortOrderNo{undefinedTokenOrder};
    bool isSelfCollection{false};
    // proxy roles
    QString groupName;
};

// mirrors CollectiblePreferencesItemType from src/backend/collectibles_types.nim
enum class CollectiblePreferencesItemType { NonCommunityCollectible = 1, CommunityCollectible, Collection, Community };

CollectiblePreferencesItemType tokenDataToCollectiblePreferencesItemType(bool isCommunity, bool itemsAreGroups);

struct TokenOrder {
    QString key; // crossChainId or tokenKey if crossChainId is empty
    int sortOrder;
    bool visible;
    bool isCommunityGroup;
    QString communityId;
    bool isCollectionGroup;
    QString collectionUid;
    /// covers separation of groups (collection or community) and collectibles (regular or community)
    CollectiblePreferencesItemType type;

    // Defines a default TokenOrder, order is not set (undefinedTokenOrder) and visible is false
    TokenOrder();
    TokenOrder(const QString& key,
               int sortOrder,
               bool visible,
               bool isCommunityGroup,
               const QString& communityId,
               bool isCollectionGroup,
               const QString& collectionUid,
               CollectiblePreferencesItemType type);

    bool operator==(const TokenOrder& rhs) const
    {
        return key == rhs.key && sortOrder == rhs.sortOrder && visible == rhs.visible &&
               isCommunityGroup == rhs.isCommunityGroup && (!isCommunityGroup || communityId == rhs.communityId) &&
               isCollectionGroup == rhs.isCollectionGroup &&
               (!isCollectionGroup || collectionUid == rhs.collectionUid) && type == rhs.type;
    }

    QString getGroupId() const { return !communityId.isEmpty() ? communityId : collectionUid; }
};

using SerializedTokenData = QHash<QString, TokenOrder>;

QString tokenOrdersToJson(const SerializedTokenData& data, bool areCollectibles);
SerializedTokenData tokenOrdersFromJson(const QString& json_string, bool areCollectibles);
