import json, Tables, strformat, strutils


type CollectibleTraitType* {.pure.} = enum
  Properties = 0,
  Rankings = 1,
  Statistics = 2

type CollectionTrait* = ref object
    min*, max*: float

type CollectionDto* = ref object
    name*, slug*, imageUrl*: string
    ownedAssetCount*: int
    trait*: Table[string, CollectionTrait]

type CollectibleTrait* = ref object
    traitType*, value*, displayType*, maxValue*: string

type CollectibleDto* = ref object
    id*: int
    name*, description*, permalink*, imageThumbnailUrl*, imageUrl*, address*, backgroundColor*: string
    properties*, rankings*, statistics*: seq[CollectibleTrait]

proc isNumeric(s: string): bool =
  try:
    discard s.parseFloat()
    result = true
  except ValueError:
    result = false

proc `$`*(self: CollectionDto): string =
  return fmt"CollectionDto(name:{self.name}, slug:{self.slug}, owned asset count:{self.ownedAssetCount})"

proc `$`*(self: CollectibleDto): string =
  return fmt"CollectibleDto(id:{self.id}, name:{self.name}, description:{self.description}, permalink:{self.permalink}, address:{self.address}, imageUrl: {self.imageUrl}, imageThumbnailUrl: {self.imageThumbnailUrl}, backgroundColor: {self.backgroundColor})"

proc getCollectionTraits*(jsonCollection: JsonNode): Table[string, CollectionTrait] =
    var traitList: Table[string, CollectionTrait] = initTable[string, CollectionTrait]()
    for key, value in jsonCollection{"traits"}:
        traitList[key] = CollectionTrait(min: value{"min"}.getFloat, max: value{"max"}.getFloat)
    return traitList

proc toCollectionDto*(jsonCollection: JsonNode): CollectionDto =
    return CollectionDto(
        name: jsonCollection{"name"}.getStr,
        slug: jsonCollection{"slug"}.getStr,
        imageUrl: jsonCollection{"image_url"}.getStr,
        ownedAssetCount: jsonCollection{"owned_asset_count"}.getInt,
        trait: getCollectionTraits(jsonCollection)
    )

proc getTrait*(jsonAsset: JsonNode, traitType: CollectibleTraitType): seq[CollectibleTrait] =
    var traitList: seq[CollectibleTrait] = @[]
    case traitType:
        of CollectibleTraitType.Properties:
            for index in jsonAsset{"traits"}.items:
                if((index{"display_type"}.getStr != "number") and (index{"display_type"}.getStr != "boost_percentage") and (index{"display_type"}.getStr != "boost_number") and not isNumeric(index{"value"}.getStr)):
                    traitList.add(CollectibleTrait(traitType: index{"trait_type"}.getStr, value: index{"value"}.getStr, displayType: index{"display_type"}.getStr, maxValue: index{"max_value"}.getStr))
        of CollectibleTraitType.Rankings:
            for index in jsonAsset{"traits"}.items:
                if(index{"display_type"}.getStr != "number" and (index{"display_type"}.getStr != "boost_percentage") and (index{"display_type"}.getStr != "boost_number") and isNumeric(index{"value"}.getStr)):
                    traitList.add(CollectibleTrait(traitType: index{"trait_type"}.getStr, value: index{"value"}.getStr, displayType: index{"display_type"}.getStr, maxValue: index{"max_value"}.getStr))
        of CollectibleTraitType.Statistics:
            for index in jsonAsset{"traits"}.items:
                if(index{"display_type"}.getStr == "number" and (index{"display_type"}.getStr != "boost_percentage") and (index{"display_type"}.getStr != "boost_number") and isNumeric(index{"value"}.getStr)):
                    traitList.add(CollectibleTrait(traitType: index{"trait_type"}.getStr, value: index{"value"}.getStr, displayType: index{"display_type"}.getStr, maxValue: index{"max_value"}.getStr))
    return traitList

proc toCollectibleDto*(jsonAsset: JsonNode): CollectibleDto =
    return CollectibleDto(
        id: jsonAsset{"id"}.getInt,
        name: jsonAsset{"name"}.getStr,
        description: jsonAsset{"description"}.getStr,
        permalink: jsonAsset{"permalink"}.getStr,
        imageThumbnailUrl: jsonAsset{"image_thumbnail_url"}.getStr,
        imageUrl: jsonAsset{"image_url"}.getStr,
        address: jsonAsset{"asset_contract"}{"address"}.getStr,
        backgroundColor: jsonAsset{"background_color"}.getStr,
        properties: getTrait(jsonAsset, CollectibleTraitType.Properties),
        rankings: getTrait(jsonAsset, CollectibleTraitType.Rankings),
        statistics: getTrait(jsonAsset, CollectibleTraitType.Statistics)
    )
