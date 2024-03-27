import stint

import ./collectibles_entry as flat_item
import ./collectibles_nested_item as nested_item
import app_service/common/types

proc collectibleToCommunityCollectibleNestedItem*(flatItem: flat_item.CollectiblesEntry, count: UInt256): nested_item.Item =
  return nested_item.initItem(
    flatItem.getIDAsString(),
    flatItem.getChainID(),
    flatItem.getName(),
    flatItem.getImageURL(),
    flatItem.getCommunityId(),
    flatItem.getCommunityName(),
    TokenType(flatItem.getTokenType()),
    ItemType.CommunityCollectible,
    count
  )

proc collectibleToCommunityNestedItem*(flatItem: flat_item.CollectiblesEntry, count: UInt256): nested_item.Item =
  return nested_item.initItem(
    flatItem.getCommunityId(),
    flatItem.getChainID(),
    flatItem.getCommunityName(),
    flatItem.getCommunityImage(),
    flatItem.getCommunityId(),
    flatItem.getCommunityName(),
    TokenType(flatItem.getTokenType()),
    ItemType.Community,
    count
  )

proc collectibleToNonCommunityCollectibleNestedItem*(flatItem: flat_item.CollectiblesEntry, count: UInt256): nested_item.Item =
  return nested_item.initItem(
    flatItem.getIDAsString(),
    flatItem.getChainID(),
    flatItem.getName(),
    flatItem.getImageURL(),
    flatItem.getCollectionIDAsString(),
    flatItem.getCollectionName(),
    TokenType(flatItem.getTokenType()),
    ItemType.NonCommunityCollectible,
    count
  )

proc collectibleToCollectionNestedItem*(flatItem: flat_item.CollectiblesEntry, count: UInt256): nested_item.Item =
  return nested_item.initItem(
    flatItem.getCollectionIDAsString(),
    flatItem.getChainID(),
    flatItem.getCollectionName(),
    flatItem.getCollectionImageURL(),
    flatItem.getCollectionIDAsString(),
    flatItem.getCollectionName(),
    TokenType(flatItem.getTokenType()),
    ItemType.Collection,
    count
  )