import json, json_serialization, stew/shims/strformat

type RpcProviderType* {.pure.} = enum
  EmbeddedProxy = "embedded-proxy"
  EmbeddedDirect = "embedded-direct"
  User = "user"

type RpcProviderAuthType* {.pure.} = enum
  NoAuth = "no-auth"
  BasicAuth = "basic-auth"
  TokenAuth = "token-auth"

type RpcProviderDto* = ref object of RootObj
  id* {.serializedFieldName("id").}: int
  chainId* {.serializedFieldName("chainId").}: int
  name* {.serializedFieldName("name").}: string
  url* {.serializedFieldName("url").}: string
  isRpsLimiterEnabled* {.serializedFieldName("enableRpsLimiter").}: bool
  providerType* {.serializedFieldName("type").}: RpcProviderType
  isEnabled* {.serializedFieldName("enabled").}: bool
  authType* {.serializedFieldName("authType").}: RpcProviderAuthType
  authLogin* {.serializedFieldName("authLogin").}: string
  authPassword* {.serializedFieldName("authPassword").}: string
  authToken* {.serializedFieldName("authToken").}: string

proc `$`*(self: RpcProviderDto): string =
  return fmt"""RpcProviderDto(
    id:{self.id},
    chainId:{self.chainId},
    name:{self.name},
    url:{self.url},
    isRpsLimiterEnabled:{self.isRpsLimiterEnabled},
    providerType:{self.providerType},
    isEnabled:{self.isEnabled},
    authType:{self.authType},
    authLogin:{self.authLogin},
    authPassword:{self.authPassword},
    authToken:{self.authToken}
  )"""

proc `%`*(t: RpcProviderDto): JsonNode {.inline.} =
  result = parseJson(t.toJson)

type NetworkDto* = ref object of RootObj
  chainId* {.serializedFieldName("chainId").}: int
  nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
  layer* {.serializedFieldName("layer").}: int
  chainName* {.serializedFieldName("chainName").}: string
  rpcProviders* {.serializedFieldName("rpcProviders").}: seq[RpcProviderDto]
  blockExplorerUrl* {.serializedFieldName("blockExplorerUrl").}: string
  iconUrl* {.serializedFieldName("iconUrl").}: string
  nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
  nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
  isTest* {.serializedFieldName("isTest").}: bool
  isEnabled* {.serializedFieldName("enabled").}: bool
  chainColor* {.serializedFieldName("chainColor").}: string
  shortName* {.serializedFieldName("shortName").}: string
  relatedChainID* {.serializedFieldName("relatedChainID").}: int

proc `$`*(self: NetworkDto): string =
  return fmt"""NetworkDto(
    chainId:{self.chainId},
    nativeCurrencyDecimals:{self.nativeCurrencyDecimals},
    layer:{self.layer},
    chainName:{self.chainName},
    name:{self.chainName},
    rpcProviders:{self.rpcProviders},
    blockExplorerUrl:{self.blockExplorerUrl},
    iconUrl:{self.iconUrl},
    nativeCurrencyName:{self.nativeCurrencyName},
    nativeCurrencySymbol:{self.nativeCurrencySymbol},
    isTest:{self.isTest},
    isEnabled:{self.isEnabled},
    chainColor:{self.chainColor},
    shortName:{self.shortName},
    relatedChainId:{self.relatedChainId}
  )"""

proc `%`*(t: NetworkDto): JsonNode {.inline.} =
  result = parseJson(t.toJson)

type CombinedNetworkDto* = ref object of RootObj
  prod* {.serializedFieldName("Prod").}: NetworkDto
  test* {.serializedFieldName("Test").}: NetworkDto

proc `$`*(self: CombinedNetworkDto): string =
  return fmt"""CombinedNetworkDto(
    prod:{$self.prod},
    test:{$self.test},
  )"""

proc `%`*(t: CombinedNetworkDto): JsonNode {.inline.} =
  result = parseJson(t.toJson)