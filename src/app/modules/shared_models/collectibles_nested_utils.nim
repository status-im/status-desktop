import sequtils, sugar, times
import collectibles_item as flat_item
import collectibles_nested_item as nested_item

proc collectibleToCollectibleNestedItem*(flatItem: flat_item.Item): nested_item.Item =
  return nested_item.initItem(
    flatItem.getId(),
    flatItem.getChainId(),
    flatItem.getName(),
    flatItem.getImageUrl(),
    flatItem.getCollectionId(),
    flatItem.getCollectionName(),
    false
  )

proc collectibleToCollectionNestedItem*(flatItem: flat_item.Item): nested_item.Item =
  return nested_item.initItem(
    flatItem.getCollectionId(),
    flatItem.getChainId(),
    flatItem.getCollectionName(),
    flatItem.getCollectionImageUrl(),
    flatItem.getCollectionId(),
    flatItem.getCollectionName(),
    true
  )
