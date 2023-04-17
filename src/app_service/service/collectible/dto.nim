import json, Tables, stint, strformat, strutils, times

# Unique identifier for collectible on a specific chain
type
  UniqueID* = object
    contractAddress*: string
    tokenId*: UInt256

type CollectibleTraitType* {.pure.} = enum
  Properties = 0,
  Rankings = 1,
  Statistics = 2

type CollectionTrait* = ref object
    min*, max*: float

type CollectionDto* = ref object
    name*, slug*, imageUrl*: string
    trait*: Table[string, CollectionTrait]

type CollectibleTrait* = ref object
    traitType*, value*, displayType*, maxValue*: string

type CollectibleDto* = ref object
    id*: int
    tokenId*: Uint256
    address*, collectionSlug*, name*, description*, permalink*, imageThumbnailUrl*, imageUrl*, animationUrl*, animationMediaType*, backgroundColor*: string
    properties*, rankings*, statistics*: seq[CollectibleTrait]

type CollectibleBalance* = ref object
    tokenId*: UInt256
    balance*: UInt256

proc `$`*(self: CollectibleBalance): string =
  return fmt"""CollectibleBalance(
    tokenId:{self.tokenId}, 
    balance:{self.balance}
    """

type CollectibleOwner* = ref object
    address*: string
    balances*: seq[CollectibleBalance] 

proc `$`*(self: CollectibleOwner): string =
  return fmt"""CollectibleOwner(
    address:{self.address}, 
    balances:{self.balances}
    """

type CollectibleOwnershipDto* = ref object
    contractAddress*: string
    owners*: seq[CollectibleOwner]

proc `$`*(self: CollectibleOwnershipDto): string =
  return fmt"""CollectibleOwnershipDto(
    contractAddress:{self.contractAddress}, 
    owners:{self.owners}
    """
proc newCollectibleDto*: CollectibleDto =
  return CollectibleDto(
    id: -1
  )

proc isValid*(self: CollectibleDto): bool =
  return self.id >= 0

proc newCollectionDto*: CollectionDto =
  return CollectionDto(
    slug: ""
  )

proc isValid*(self: CollectionDto): bool =
  return self.slug != ""

proc isNumeric(s: string): bool =
  try:
    discard s.parseFloat()
    result = true
  except ValueError:
    result = false

proc `$`*(self: CollectionDto): string =
  return fmt"""CollectionDto(
    name:{self.name}, 
    slug:{self.slug}, 
    imageUrl:{self.imageUrl}
    """

proc `$`*(self: CollectibleDto): string =
  return fmt"""CollectibleDto(
    id:{self.id}, 
    address:{self.address}, 
    tokenId:{self.tokenId}, 
    collectionSlug:{self.collectionSlug}, 
    name:{self.name}, 
    description:{self.description}, 
    permalink:{self.permalink}, 
    imageUrl: {self.imageUrl}, 
    imageThumbnailUrl: {self.imageThumbnailUrl}, 
    animationUrl: {self.animationUrl}, 
    animationMediaType: {self.animationMediaType}, 
    backgroundColor: {self.backgroundColor})
    """

proc getCollectionTraits*(jsonCollection: JsonNode): Table[string, CollectionTrait] =
    var traitList: Table[string, CollectionTrait] = initTable[string, CollectionTrait]()
    for key, value in jsonCollection{"traits"}.getFields():
        traitList[key] = CollectionTrait(min: value{"min"}.getFloat, max: value{"max"}.getFloat)
    return traitList

proc toCollectionDto*(jsonCollection: JsonNode): CollectionDto =
    return CollectionDto(
        name: jsonCollection{"name"}.getStr,
        slug: jsonCollection{"slug"}.getStr,
        imageUrl: jsonCollection{"image_url"}.getStr,
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
        address: jsonAsset{"asset_contract"}{"address"}.getStr,
        tokenId: stint.parse(jsonAsset{"token_id"}.getStr, Uint256),
        collectionSlug: jsonAsset{"collection"}{"slug"}.getStr,
        name: jsonAsset{"name"}.getStr,
        description: jsonAsset{"description"}.getStr,
        permalink: jsonAsset{"permalink"}.getStr,
        imageThumbnailUrl: jsonAsset{"image_thumbnail_url"}.getStr,
        imageUrl: jsonAsset{"image_url"}.getStr,
        animationUrl: jsonAsset{"animation_url"}.getStr,
        animationMediaType: jsonAsset{"animation_media_type"}.getStr,
        backgroundColor: jsonAsset{"background_color"}.getStr,
        properties: getTrait(jsonAsset, CollectibleTraitType.Properties),
        rankings: getTrait(jsonAsset, CollectibleTraitType.Rankings),
        statistics: getTrait(jsonAsset, CollectibleTraitType.Statistics)
    )

proc getCollectibleBalances(jsonAsset: JsonNode): seq[CollectibleBalance] =
  var balanceList: seq[CollectibleBalance] = @[]
  for item in jsonAsset.items:
      balanceList.add(CollectibleBalance(
          tokenId: stint.parse(item{"tokenId"}.getStr, Uint256),
          balance: stint.parse(item{"balance"}.getStr, Uint256)
      ))
  return balanceList

proc getCollectibleOwners(jsonAsset: JsonNode): seq[CollectibleOwner] =
  var ownerList: seq[CollectibleOwner] = @[]
  for item in jsonAsset.items:
      ownerList.add(CollectibleOwner(
          address: item{"ownerAddress"}.getStr,
          balances: getCollectibleBalances(item{"tokenBalances"})
      ))
  return ownerList

proc toCollectibleOwnershipDto*(jsonAsset: JsonNode): CollectibleOwnershipDto =
    return CollectibleOwnershipDto(
        contractAddress: jsonAsset{"contractAddress"}.getStr,
        owners: getCollectibleOwners(jsonAsset{"owners"})
    )
