import json, stew/shims/strformat

include app_service/common/json_utils

import json_serialization

const WEEKLY_TIME_RANGE* = 0
const MONTHLY_TIME_RANGE* = 1
const HALF_YEARLY_TIME_RANGE* = 2
const YEARLY_TIME_RANGE* = 3
const ALL_TIME_RANGE* = 4

# Only contains DTO used for deserialisation of data from go lib

type CommunityDataDto* = object
    id* {.serializedFieldName("id").}: string
    name* {.serializedFieldName("name").}: string
    color* {.serializedFieldName("color").}: string

proc `$`*(self: CommunityDataDto): string =
  result = fmt"""CommunityDataDto[
    id: {self.id},
    name: {self.name},
    color: {self.color}
    ]"""

type
  TokenDto* = object
    address* {.serializedFieldName("address").}: string
    name* {.serializedFieldName("name").}: string
    symbol* {.serializedFieldName("symbol").}: string
    decimals* {.serializedFieldName("decimals").}: int
    chainID* {.serializedFieldName("chainId").}: int
    communityData* {.serializedFieldName("community_data").}: CommunityDataDto
    image* {.serializedFieldName("image").}: string
    communityID* : string

  TokenDtoSafe* = TokenDto

proc `$`*(self: TokenDto): string =
  result = fmt"""TokenDto[
    address: {self.address},
    name: {self.name},
    symbol: {self.symbol},
    decimals: {self.decimals},
    chainID: {self.chainID},
    communityData: {self.communityData},
    image: {self.image}
    ]"""

proc key*(self: TokenDto): string =
  result = self.address

type TokenSourceDto* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    tokens* {.serializedFieldName("tokens").}: seq[TokenDto]
    source* {.serializedFieldName("source").}: string
    version* {.serializedFieldName("version").}: string
    lastUpdateTimestamp* {.serializedFieldName("lastUpdateTimestamp").}: int64

type TokenListDto* = ref object of RootObj
    updatedAt* {.serializedFieldName("updatedAt").}: int64
    data* {.serializedFieldName("data").}: seq[TokenSourceDto]

proc `$`*(self: TokenSourceDto): string =
  result = fmt"""TokenSourceDto[
    name: {self.name},
    tokens: {self.tokens},
    source: {self.source},
    version: {self.version}
    lastUpdateTimestamp: {self.lastUpdateTimestamp}
    ]"""

type
  TokenMarketValuesDto* = object
    marketCap* {.serializedFieldName("MKTCAP").}: float64
    highDay* {.serializedFieldName("HIGHDAY").}: float64
    lowDay* {.serializedFieldName("LOWDAY").}: float64
    changePctHour* {.serializedFieldName("CHANGEPCTHOUR").}: float64
    changePctDay* {.serializedFieldName("CHANGEPCTDAY").}: float64
    changePct24hour* {.serializedFieldName("CHANGEPCT24HOUR").}: float64
    change24hour* {.serializedFieldName("CHANGE24HOUR").}: float64

type
  TokenDetailsDto* = object
    description* {.serializedFieldName("Description").}: string
    assetWebsiteUrl* {.serializedFieldName("AssetWebsiteUrl").}: string
