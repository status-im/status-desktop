import sequtils, sugar, Tables
import ../../../../../../app_service/service/collectible/service
import collections_item, collectibles_utils

proc collectionToItem*(collection: CollectionData) : Item =
  return initItem(
      collection.collection.name,
      collection.collection.slug,
      collection.collection.imageUrl,
      collection.collection.ownedAssetCount,
      collection.collectiblesLoaded,
      toSeq(collection.collectibles.values).map(c => collectibleToItem(c))
  )