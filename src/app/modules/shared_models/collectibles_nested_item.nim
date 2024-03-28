import stew/shims/strformat
import app_service/common/types
import stint

type
  ItemType* {.pure.} = enum
    CommunityCollectible = 0,
    NonCommunityCollectible = 1,
    Collection = 2,
    Community = 3

type
  Item* = object
    id: string  # CollectibleID if single collectible, GroupID (CollectionID/CommunityID) otherwise
    chainId: int
    name: string
    iconUrl: string
    groupId: string
    groupName: string
    tokenType: TokenType
    itemType: ItemType
    count: UInt256

proc initItem*(
  id: string,
  chainId: int,
  name: string,
  iconUrl: string,
  groupId: string,
  groupName: string,
  tokenType: TokenType,
  itemType: ItemType,
  count: UInt256,
): Item =
  result.id = id
  result.chainId = chainId
  result.name = name
  result.iconUrl = iconUrl
  result.groupId = groupId
  result.groupName = groupName
  result.tokenType = tokenType
  result.itemType = itemType
  result.count = count

proc `$`*(self: Item): string =
  result = fmt"""CollectiblesNestedEntry(
    id: {self.id},
    chainId: {self.chainId},
    name: {self.name},
    iconUrl: {self.iconUrl},
    groupId: {self.groupId},
    groupName: {self.groupName},
    tokenType: {self.tokenType},
    itemType: {self.itemType},
    count: {self.count},
    ]"""

proc getId*(self: Item): string =
  return self.id

proc getChainId*(self: Item): int =
  return self.chainId

proc getName*(self: Item): string =
  return self.name

proc getIconUrl*(self: Item): string =
  return self.iconUrl

proc getGroupId*(self: Item): string =
  return self.groupId

proc getGroupName*(self: Item): string =
  return self.groupName

proc getTokenType*(self: Item): int =
  return self.tokenType.int

proc getItemType*(self: Item): int =
  return self.itemType.int

proc getCount*(self: Item): UInt256 =
  return self.count

proc getCountAsString*(self: Item): string =
  return $self.count
