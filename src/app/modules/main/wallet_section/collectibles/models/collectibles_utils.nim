import sequtils, sugar
import ../../../../../../app_service/service/collectible/dto
import collectibles_item, collectible_trait_item

proc collectibleToItem*(c: CollectibleDto) : Item =
  return initItem(
    c.id,
    c.name,
    c.imageUrl,
    c.backgroundColor,
    c.description,
    c.permalink,
    c.properties.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.rankings.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)),
    c.statistics.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue))
  )
