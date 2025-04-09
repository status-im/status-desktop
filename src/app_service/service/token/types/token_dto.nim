import strutils, stew/shims/strformat
import json_serialization
import app_service/common/utils

type CommunityDataDto* = object
    id* {.serializedFieldName("id").}: string
    name* {.serializedFieldName("name").}: string
    color* {.serializedFieldName("color").}: string

type
  TokenDetailsDto* = object
    description* {.serializedFieldName("Description").}: string
    assetWebsiteUrl* {.serializedFieldName("AssetWebsiteUrl").}: string

type
  TokenDto* = ref object of RootObj
    groupKey* {.serializedFieldName("groupKey").}: string
    address* {.serializedFieldName("address").}: string
    name* {.serializedFieldName("name").}: string
    symbol* {.serializedFieldName("symbol").}: string
    decimals* {.serializedFieldName("decimals").}: int
    chainID* {.serializedFieldName("chainId").}: int
    communityData* {.serializedFieldName("community_data").}: CommunityDataDto
    image* {.serializedFieldName("image").}: string
    communityID* : string

proc tokenKey*(self: TokenDto): string =
  return makeTokenKey(self.chainID, self.address)

proc tokenGroupKey*(self: TokenDto): string =
  if self.communityData.id.isEmptyOrWhitespace:
    return self.groupKey
  return self.tokenKey()

proc `$`*(self: CommunityDataDto): string =
  result = fmt"""CommunityDataDto[
    id: {self.id},
    name: {self.name},
    color: {self.color}
    ]"""

proc `$`*(self: TokenDto): string =
  result = fmt"""TokenDto[
    groupKey: {self.groupKey},
    address: {self.address},
    name: {self.name},
    symbol: {self.symbol},
    decimals: {self.decimals},
    chainID: {self.chainID},
    communityData: {self.communityData},
    image: {self.image}
    communityID: {self.communityID}
    ]"""