import ./collectibles_entry as flat_item
import ./collectibles_nested_item as nested_item

proc collectibleToCollectibleNestedItem*(flatItem: flat_item.CollectiblesEntry): nested_item.Item =
  return nested_item.initItem(
    flatItem.getID(),
    flatItem.getChainID(),
    flatItem.getName(),
    flatItem.getImageURL(),
    flatItem.getCollectionID(),
    flatItem.getCollectionName(),
    false
  )

proc collectibleToCollectionNestedItem*(flatItem: flat_item.CollectiblesEntry): nested_item.Item =
  return nested_item.initItem(
    flatItem.getCollectionID(),
    flatItem.getChainID(),
    flatItem.getCollectionName(),
    flatItem.getCollectionImageURL(),
    flatItem.getCollectionID(),
    flatItem.getCollectionName(),
    true
  )
