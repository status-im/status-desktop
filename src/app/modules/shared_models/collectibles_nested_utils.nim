import ./collectibles_entry as flat_item
import ./collectibles_nested_item as nested_item
import app_service/common/types

proc collectibleToCollectibleNestedItem*(flatItem: flat_item.CollectiblesEntry): nested_item.Item =
  return nested_item.initItem(
    flatItem.getIDAsString(),
    flatItem.getChainID(),
    flatItem.getName(),
    flatItem.getImageURL(),
    flatItem.getCollectionIDAsString(),
    flatItem.getCollectionName(),
    false,
    flatItem.getCommunityID(),
    TokenType(flatItem.getTokenType())
  )

proc collectibleToCollectionNestedItem*(flatItem: flat_item.CollectiblesEntry): nested_item.Item =
  return nested_item.initItem(
    flatItem.getCollectionIDAsString(),
    flatItem.getChainID(),
    flatItem.getCollectionName(),
    flatItem.getCollectionImageURL(),
    flatItem.getCollectionIDAsString(),
    flatItem.getCollectionName(),
    true,
    flatItem.getCommunityID(),
    TokenType(flatItem.getTokenType())
  )
