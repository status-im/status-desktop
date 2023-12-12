import json, strformat

include app_service/common/json_utils

import json_serialization

# TODO: remove once this is moved to wallet_accounts service
const WEEKLY_TIME_RANGE* = 0
const MONTHLY_TIME_RANGE* = 1
const HALF_YEARLY_TIME_RANGE* = 2
const YEARLY_TIME_RANGE* = 3
const ALL_TIME_RANGE* = 4

# Only contains DTO used for deserialisation of data from go lib

type
  TokenDto* = ref object of RootObj
    address* {.serializedFieldName("address").}: string
    name* {.serializedFieldName("name").}: string
    symbol* {.serializedFieldName("symbol").}: string
    decimals* {.serializedFieldName("decimals").}: int
    chainID* {.serializedFieldName("chainId").}: int
    communityID* {.serializedFieldName("communityId").}: string
    image* {.serializedFieldName("image").}: string

proc `$`*(self: TokenDto): string =
  result = fmt"""TokenDto[
    address: {self.address},
    name: {self.name},
    symbol: {self.symbol},
    decimals: {self.decimals},
    chainID: {self.chainID},
    communityID: {self.communityID},
    image: {self.image}
    ]"""

# TODO: Remove after https://github.com/status-im/status-desktop/issues/12513
proc newTokenDto*(
  address: string,
  name: string,
  symbol: string,
  decimals: int,
  chainId: int,
  communityId: string = "",
  image: string = ""
): TokenDto =
  return TokenDto(
    address: address,
    name: name,
    symbol: symbol,
    decimals: decimals,
    chainId: chainId,
    communityId: communityId,
    image: image
  )

type TokenSourceDto* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    tokens* {.serializedFieldName("tokens").}: seq[TokenDto]
    updatedAt* {.serializedFieldName("updatedAt").}: int64
    source* {.serializedFieldName("source").}: string
    version* {.serializedFieldName("version").}: string

proc `$`*(self: TokenSourceDto): string =
  result = fmt"""TokenSourceDto[
    name: {self.name},
    tokens: {self.tokens},
    updatedAt: {self.updatedAt},
    source: {self.source},
    version: {self.version}
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
