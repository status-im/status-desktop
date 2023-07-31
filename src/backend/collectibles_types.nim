import json, strformat
import stint, Tables

type
  # Mirrors services/wallet/thirdparty/collectible_types.go ContractID
  ContractID* = ref object of RootObj
    chainID*: int
    address*: string

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleUniqueID
  CollectibleUniqueID* = ref object of RootObj
    contractID*: ContractID
    tokenID*: UInt256

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleTrait
  CollectibleTrait* = ref object of RootObj
    trait_type*: string
    value*: string
    display_type*: string
    max_value*: string

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectionTrait
  CollectionTrait* = ref object of RootObj
    min*: float
    max*: float

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectionData
  CollectionData* = ref object of RootObj
    name*: string
    slug*: string
    imageUrl*: string
    traits*: Table[string, CollectionTrait]

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleData
  CollectibleData* = ref object of RootObj
    id* : CollectibleUniqueID
    name*: string
    description*: string
    permalink*: string
    imageUrl*: string
    animationUrl*: string
    animationMediaType*: string
    traits*: seq[CollectibleTrait]
    backgroundColor*: string
    tokenUri*: string
    collectionData*: CollectionData

  # Mirrors services/wallet/collectibles/types.go CollectibleHeader
  CollectibleHeader* = ref object of RootObj
    id* : CollectibleUniqueID
    name*: string
    imageUrl*: string
    animationUrl*: string
    animationMediaType*: string
    backgroundColor*: string
    collectionName*: string

  # Mirrors services/wallet/collectibles/types.go CollectibleDetails
  CollectibleDetails* = ref object of RootObj
    id* : CollectibleUniqueID
    name*: string
    description*: string
    imageUrl*: string
    animationUrl*: string
    animationMediaType*: string
    traits*: seq[CollectibleTrait]
    backgroundColor*: string
    tokenUri*: string
    collectionName*: string
    collectionSlug*: string
    collectionImageUrl*: string

  # Mirrors services/wallet/thirdparty/collectible_types.go TokenBalance
  CollectibleBalance* = ref object
    tokenId*: UInt256
    balance*: UInt256

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleOwner
  CollectibleOwner* = ref object
    address*: string
    balances*: seq[CollectibleBalance]

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleContractOwnership
  CollectibleContractOwnership* = ref object
    contractAddress*: string
    owners*: seq[CollectibleOwner]

# ContractID
proc `$`*(self: ContractID): string =
  return fmt"""ContractID(
    chainID:{self.chainID},
    address:{self.address}
  )"""

proc `==`*(a, b: ContractID): bool = 
  result = a.chainID == b.chainID and
    a.address == b.address

proc `%`*(t: ContractID): JsonNode {.inline.} =
  result = newJObject()
  result["chainID"] = %(t.chainID)
  result["address"] = %(t.address)
  
proc `%`*(t: ref ContractID): JsonNode {.inline.} =
  return %(t[])

proc fromJson*(t: JsonNode, T: typedesc[ContractID]): ContractID {.inline.} =
  result = ContractID()
  result.chainID = t["chainID"].getInt()
  result.address = t["address"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[ref ContractID]): ref ContractID {.inline.} =
  result = new(ContractID)
  result[] = fromJson(t, ContractID)

# CollectibleUniqueID
proc `$`*(self: CollectibleUniqueID): string =
  return fmt"""CollectibleUniqueID(
    contractID:{self.contractID},
    tokenID:{self.tokenID}
  )"""

proc `==`*(a, b: CollectibleUniqueID): bool = 
  result = a.contractID == b.contractID and
    a.tokenID == b.tokenID

proc `%`*(t: CollectibleUniqueID): JsonNode {.inline.} =
  result = newJObject()
  result["contractID"] = %(t.contractID)
  result["tokenID"] = %(t.tokenID.toString())
  
proc `%`*(t: ref CollectibleUniqueID): JsonNode {.inline.} =
  return %(t[])

proc fromJson*(t: JsonNode, T: typedesc[CollectibleUniqueID]): CollectibleUniqueID {.inline.} =
  result = CollectibleUniqueID()
  result.contractID = fromJson(t["contractID"], ContractID)
  result.tokenID = stint.parse(t["tokenID"].getStr(), UInt256)

proc fromJson*(t: JsonNode, T: typedesc[ref CollectibleUniqueID]): ref CollectibleUniqueID {.inline.} =
  result = new(CollectibleUniqueID)
  result[] = fromJson(t, CollectibleUniqueID)

# CollectibleTrait
proc `$`*(self: CollectibleTrait): string =
  return fmt"""CollectibleTrait(
    trait_type:{self.trait_type},
    value:{self.value},
    display_type:{self.display_type},
    max_value:{self.max_value}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CollectibleTrait]): CollectibleTrait {.inline.} =
  result = CollectibleTrait()
  result.trait_type = t["trait_type"].getStr()
  result.value = t["value"].getStr()
  result.display_type = t["display_type"].getStr()
  result.max_value = t["max_value"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[ref CollectibleTrait]): ref CollectibleTrait {.inline.} =
  result = new(CollectibleTrait)
  result[] = fromJson(t, CollectibleTrait)

# CollectionTrait
proc `$`*(self: CollectionTrait): string =
  return fmt"""CollectionTrait(
    min:{self.min},
    max:{self.max}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CollectionTrait]): CollectionTrait {.inline.} =
  result = CollectionTrait()
  result.min = t["min"].getFloat()
  result.max = t["max"].getFloat()

proc fromJson*(t: JsonNode, T: typedesc[ref CollectionTrait]): ref CollectionTrait {.inline.} =
  result = new(CollectionTrait)
  result[] = fromJson(t, CollectionTrait)

# CollectionData
proc `$`*(self: CollectionData): string =
  return fmt"""CollectionData(
    name:{self.name},
    slug:{self.slug},
    imageUrl:{self.imageUrl},
    traits:{self.traits}
  )"""

proc getCollectionTraits*(t: JsonNode): Table[string, CollectionTrait] =
  var traitList: Table[string, CollectionTrait] = initTable[string, CollectionTrait]()
  for key, value in t{"traits"}.getFields():
    traitList[key] = fromJson(value, CollectionTrait)
  return traitList

proc fromJson*(t: JsonNode, T: typedesc[CollectionData]): CollectionData {.inline.} =
  result = CollectionData()
  result.name = t["name"].getStr()
  result.slug = t["slug"].getStr()
  result.imageUrl = t["image_url"].getStr()
  result.traits = getCollectionTraits(t["traits"])

proc fromJson*(t: JsonNode, T: typedesc[ref CollectionData]): ref CollectionData {.inline.} =
  result = new(CollectionData)
  result[] = fromJson(t, CollectionData)

# CollectibleData
proc `$`*(self: CollectibleData): string =
  return fmt"""CollectibleData(
    id:{self.id},
    name:{self.name},
    description:{self.description},
    permalink:{self.permalink},
    imageUrl:{self.imageUrl},
    animationUrl:{self.animationUrl},
    animationMediaType:{self.animationMediaType},
    traits:{self.traits},
    backgroundColor:{self.backgroundColor},
    tokenUri:{self.tokenUri},
  )"""

proc getCollectibleTraits*(t: JsonNode): seq[CollectibleTrait] =
  var traitList: seq[CollectibleTrait] = @[]
  for item in t.getElems():
    traitList.add(fromJson(item, CollectibleTrait))
  return traitList

proc fromJson*(t: JsonNode, T: typedesc[CollectibleData]): CollectibleData {.inline.} =
  result = CollectibleData()
  result.id = fromJson(t["id"], CollectibleUniqueID)
  result.name = t["name"].getStr()
  result.description = t["description"].getStr()
  result.permalink = t["permalink"].getStr()
  result.imageUrl = t["image_url"].getStr()
  result.animationUrl = t["animation_url"].getStr()
  result.animationMediaType = t["animation_media_type"].getStr()
  result.traits = getCollectibleTraits(t["traits"])
  result.backgroundColor = t["background_color"].getStr()
  result.tokenUri = t["token_uri"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[ref CollectibleData]): ref CollectibleData {.inline.} =
  result = new(CollectibleData)
  result[] = fromJson(t, CollectibleData)

# CollectibleHeader
proc `$`*(self: CollectibleHeader): string =
  return fmt"""CollectibleHeader(
    id:{self.id},
    name:{self.name},
    imageUrl:{self.imageUrl},
    animationUrl:{self.animationUrl},
    animationMediaType:{self.animationMediaType},
    backgroundColor:{self.backgroundColor},
    collectionName:{self.collectionName}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CollectibleHeader]): CollectibleHeader {.inline.} =
  result = CollectibleHeader()
  result.id = fromJson(t["id"], CollectibleUniqueID)
  result.name = t["name"].getStr()
  result.imageUrl = t["image_url"].getStr()
  result.animationUrl = t["animation_url"].getStr()
  result.animationMediaType = t["animation_media_type"].getStr()
  result.backgroundColor = t["background_color"].getStr()
  result.collectionName = t["collection_name"].getStr()

# CollectibleDetails
proc `$`*(self: CollectibleDetails): string =
  return fmt"""CollectibleDetails(
    id:{self.id},
    name:{self.name},
    description:{self.description},
    imageUrl:{self.imageUrl},
    animationUrl:{self.animationUrl},
    animationMediaType:{self.animationMediaType},
    traits:{self.traits},
    backgroundColor:{self.backgroundColor},
    collectionName:{self.collectionName},
    collectionSlug:{self.collectionSlug},
    collectionImageUrl:{self.collectionImageUrl},
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CollectibleDetails]): CollectibleDetails {.inline.} =
  result = CollectibleDetails()
  result.id = fromJson(t["id"], CollectibleUniqueID)
  result.name = t["name"].getStr()
  result.description = t["description"].getStr()
  result.imageUrl = t["image_url"].getStr()
  result.animationUrl = t["animation_url"].getStr()
  result.animationMediaType = t["animation_media_type"].getStr()
  result.traits = getCollectibleTraits(t["traits"])
  result.backgroundColor = t["background_color"].getStr()
  result.collectionName = t["collection_name"].getStr()
  result.collectionSlug = t["collection_slug"].getStr()
  result.collectionImageUrl = t["collection_image_url"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[ref CollectibleDetails]): ref CollectibleDetails {.inline.} =
  result = new(CollectibleDetails)
  result[] = fromJson(t, CollectibleDetails)

# CollectibleBalance
proc `$`*(self: CollectibleBalance): string =
  return fmt"""CollectibleBalance(
    tokenId:{self.tokenId}, 
    balance:{self.balance}
    """

proc getCollectibleBalances(jsonAsset: JsonNode): seq[CollectibleBalance] =
  var balanceList: seq[CollectibleBalance] = @[]
  for item in jsonAsset.items:
      balanceList.add(CollectibleBalance(
          tokenId: stint.parse(item{"tokenId"}.getStr, Uint256),
          balance: stint.parse(item{"balance"}.getStr, Uint256)
      ))
  return balanceList

# CollectibleOwner
proc `$`*(self: CollectibleOwner): string =
  return fmt"""CollectibleOwner(
    address:{self.address}, 
    balances:{self.balances}
    """

proc getCollectibleOwners(jsonAsset: JsonNode): seq[CollectibleOwner] =
  var ownerList: seq[CollectibleOwner] = @[]
  for item in jsonAsset.items:
      ownerList.add(CollectibleOwner(
          address: item{"ownerAddress"}.getStr,
          balances: getCollectibleBalances(item{"tokenBalances"})
      ))
  return ownerList

# CollectibleContractOwnership
proc `$`*(self: CollectibleContractOwnership): string =
  return fmt"""CollectibleContractOwnership(
    contractAddress:{self.contractAddress}, 
    owners:{self.owners}
    """

proc fromJson*(t: JsonNode, T: typedesc[CollectibleContractOwnership]): CollectibleContractOwnership {.inline.} =
    return CollectibleContractOwnership(
        contractAddress: t{"contractAddress"}.getStr,
        owners: getCollectibleOwners(t{"owners"})
    )