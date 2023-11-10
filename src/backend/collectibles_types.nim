import json, strformat, json_serialization
import stint, Tables, options
import community_tokens_types

type
  # Mirrors services/wallet/thirdparty/collectible_types.go ContractID
  ContractID* = ref object of RootObj
    chainID*: int
    address*: string

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleUniqueID
  CollectibleUniqueID* = ref object of RootObj
    contractID*: ContractID
    tokenID*: UInt256

  # see status-go/services/wallet/collectibles/service.go CollectibleDataType
  CollectibleDataType* {.pure.} = enum
    UniqueID, Header, Details, CommunityHeader

  # Mirrors services/wallet/thirdparty/collectible_types.go CollectibleTrait
  CollectibleTrait* = ref object of RootObj
    trait_type*: string
    value*: string
    display_type*: string
    max_value*: string

  CollectibleData* = ref object of RootObj
    name*: string
    description*: Option[string]
    imageUrl*: Option[string]
    animationUrl*: Option[string]
    animationMediaType*: Option[string]
    traits*: Option[seq[CollectibleTrait]]
    backgroundColor*: Option[string]

  CollectionData* = ref object of RootObj
    name*: string
    slug*: string
    imageUrl*: string

  CommunityData* = ref object of RootObj
    id*: string
    name*: string
    color*: string
    privilegesLevel*: PrivilegesLevel
    imageUrl*: Option[string]

  Collectible* = ref object of RootObj
    dataType*: CollectibleDataType
    id* : CollectibleUniqueID
    collectibleData*: Option[CollectibleData]
    collectionData*: Option[CollectionData]
    communityData*: Option[CommunityData]

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

# CollectionData
proc `$`*(self: CollectionData): string =
  return fmt"""CollectionData(
    name:{self.name},
    slug:{self.slug},
    imageUrl:{self.imageUrl}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CollectionData]): CollectionData =
  result = CollectionData()
  result.name = t["name"].getStr()
  result.slug = t["slug"].getStr()
  result.imageUrl = t["image_url"].getStr()

proc fromJson*(t: JsonNode, T: typedesc[ref CollectionData]): ref CollectionData =
  result = new(CollectionData)
  result[] = fromJson(t, CollectionData)

# CollectibleData
proc `$`*(self: CollectibleData): string =
  return fmt"""CollectibleData(
    name:{self.name},
    description:{self.description},
    imageUrl:{self.imageUrl},
    animationUrl:{self.animationUrl},
    animationMediaType:{self.animationMediaType},
    traits:{self.traits},
    backgroundColor:{self.backgroundColor}
  )"""

proc getCollectibleTraits*(t: JsonNode): Option[seq[CollectibleTrait]] =
  var traitList: seq[CollectibleTrait] = @[]
  for item in t.getElems():
    traitList.add(fromJson(item, CollectibleTrait))
  if traitList.len == 0:
    return none(seq[CollectibleTrait])
  else:
    return some(traitList)

proc fromJson*(t: JsonNode, T: typedesc[CollectibleData]): CollectibleData =
  result = CollectibleData()

  result.name = t["name"].getStr()
  let descriptionNode = t{"description"}
  if descriptionNode != nil and descriptionNode.kind != JNull:
    result.description = some(descriptionNode.getStr())
  else:
    result.description = none(string)
  let imageUrlNode = t{"image_url"}
  if imageUrlNode != nil and imageUrlNode.kind != JNull:
    result.imageUrl = some(imageUrlNode.getStr())
  else:
    result.imageUrl = none(string)
  let animationUrlNode = t{"animation_url"}
  if animationUrlNode != nil and animationUrlNode.kind != JNull:
    result.animationUrl = some(animationUrlNode.getStr())
  else:
    result.animationUrl = none(string)
  let animationMediaTypeNode = t{"animation_media_type"}
  if animationMediaTypeNode != nil and animationMediaTypeNode.kind != JNull:
    result.animationMediaType = some(animationMediaTypeNode.getStr())
  else:
    result.animationMediaType = none(string)
  result.traits = getCollectibleTraits(t{"traits"})
  let backgroundColorNode = t{"background_color"}
  if backgroundColorNode != nil and backgroundColorNode.kind != JNull:
    result.backgroundColor = some(backgroundColorNode.getStr())
  else:
    result.backgroundColor = none(string)

proc fromJson*(t: JsonNode, T: typedesc[ref CollectibleData]): ref CollectibleData {.inline.} =
  result = new(CollectibleData)
  result[] = fromJson(t, CollectibleData)

# CommunityData
proc `$`*(self: CommunityData): string =
  return fmt"""CommunityData(
    id:{self.id},
    name:{self.name},
    color:{self.color},
    privilegesLevel:{self.privilegesLevel},
    imageUrl:{self.imageUrl}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[CommunityData]): CommunityData =
  result = CommunityData()
  result.id = t["id"].getStr
  result.name = t["name"].getStr
  result.color = t["color"].getStr
  result.privilegesLevel = PrivilegesLevel(t["privileges_level"].getInt)
  let imageUrlNode = t{"image_url"}
  if imageUrlNode != nil and imageUrlNode.kind != JNull:
    result.imageUrl = some(imageUrlNode.getStr())
  else:
    result.imageUrl = none(string)

proc fromJson*(t: JsonNode, T: typedesc[ref CommunityData]): ref CommunityData {.inline.} =
  result = new(CommunityData)
  result[] = fromJson(t, CommunityData)

# Collectible
proc `$`*(self: Collectible): string =
  return fmt"""Collectible(
    dataType:{self.dataType},
    id:{self.id},
    collectibleData:{self.collectibleData},
    collectionData:{self.collectionData},
    communityData:{self.communityData}
  )"""

proc fromJson*(t: JsonNode, T: typedesc[Collectible]): Collectible {.inline.} =
  result = Collectible()
  result.dataType = t["data_type"].getInt().CollectibleDataType
  result.id = fromJson(t["id"], CollectibleUniqueID)
  let collectibleDataNode = t{"collectible_data"}
  if collectibleDataNode != nil and collectibleDataNode.kind != JNull:
    result.collectibleData = some(fromJson(collectibleDataNode, CollectibleData))
  else:
    result.collectibleData = none(CollectibleData)
  let collectionDataNode = t{"collection_data"}
  if collectionDataNode != nil and collectionDataNode.kind != JNull:
    result.collectionData = some(fromJson(collectionDataNode, CollectionData))
  else:
    result.collectionData = none(CollectionData)
  let communityDataNode = t{"community_data"}
  if communityDataNode != nil and communityDataNode.kind != JNull:
    result.communityData = some(fromJson(communityDataNode, CommunityData))
  else:
    result.communityData = none(CommunityData)

proc toIds(self: seq[Collectible]): seq[CollectibleUniqueID] =
  result = @[]
  for c in self:
    result.add(c.id)

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