import sequtils, sugar, times
import ../../../../../../app_service/service/collectible/dto
import collectibles_item, collectible_trait_item

proc collectibleToItem*(c: CollectibleDto, co: CollectionDto, isPinned: bool = false) : Item =
  return initItem(
    c.id,
    c.address,
    c.tokenId,
    c.name,
    c.imageUrl,
    c.backgroundColor,
    c.description,
    c.permalink,
    c.properties.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.rankings.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.statistics.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    co.name,
    co.slug,
    co.imageUrl,
    isPinned
  )
