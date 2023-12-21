import json, json_serialization, strformat
import hashes
import ./core, ./response_type
from ./gen import rpc

export response_type

type
  Token* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    chainId* {.serializedFieldName("chainId").}: int
    address* {.serializedFieldName("address").}: string
    symbol* {.serializedFieldName("symbol").}: string
    decimals* {.serializedFieldName("decimals").}: int
    color* {.serializedFieldName("color").}: string

  Bookmark* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    url* {.serializedFieldName("url").}: string
    imageUrl* {.serializedFieldName("imageUrl").}: string
    removed* {.serializedFieldName("removed").}: bool
    deletedAt* {.serializedFieldName("deletedAt").}: int

  Permission* = ref object of RootObj
    dapp* {.serializedFieldName("dapp").}: string
    address* {.serializedFieldName("address").}: string
    permissions* {.serializedFieldName("permissions").}: seq[string]

  SavedAddress* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    address* {.serializedFieldName("address").}: string
    favourite* {.serializedFieldName("favourite").}: bool
    chainShortNames* {.serializedFieldName("chainShortNames").}: string
    ens* {.serializedFieldName("ens").}: string
    isTest* {.serializedFieldName("isTest").}: bool

  Network* = ref object of RootObj
    chainId* {.serializedFieldName("chainId").}: int
    nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
    layer* {.serializedFieldName("layer").}: int
    chainName* {.serializedFieldName("chainName").}: string
    rpcURL* {.serializedFieldName("rpcUrl").}: string
    originalRpcURL* {.serializedFieldName("originalRpcUrl").}: string
    fallbackURL* {.serializedFieldName("fallbackUrl").}: string
    originalFallbackURL* {.serializedFieldName("originalFallbackURL").}: string
    blockExplorerURL* {.serializedFieldName("blockExplorerUrl").}: string
    iconURL* {.serializedFieldName("iconUrl").}: string
    nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
    nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
    isTest* {.serializedFieldName("isTest").}: bool
    enabled* {.serializedFieldName("enabled").}: bool
    chainColor* {.serializedFieldName("chainColor").}: string
    shortName* {.serializedFieldName("shortName").}: string
    relatedChainID* {.serializedFieldName("relatedChainID").}: int

  ActivityCenterNotificationsRequest* = ref object of RootObj
    cursor* {.serializedFieldName("cursor").}: string
    limit* {.serializedFieldName("limit").}: int
    activityTypes* {.serializedFieldName("activityTypes").}: seq[int]
    readType* {.serializedFieldName("readType").}: int

  ActivityCenterCountRequest* = ref object of RootObj
    activityTypes* {.serializedFieldName("activityTypes").}: seq[int]
    readType* {.serializedFieldName("readType").}: int

  TokenPreferences* = ref object of RootObj
    key* {.serializedFieldName("key").}: string
    position* {.serializedFieldName("position").}: int
    groupPosition* {.serializedFieldName("groupPosition").}: int
    visible* {.serializedFieldName("visible").}: bool
    communityId* {.serializedFieldName("communityId").}: string

proc fromJson*(t: JsonNode, T: typedesc[TokenPreferences]): TokenPreferences {.inline.} =
  result = TokenPreferences()
  discard t.getProp("key", result.key)
  discard t.getProp("position", result.position)
  discard t.getProp("groupPosition", result.groupPosition)
  discard t.getProp("visible", result.visible)
  discard t.getProp("communityId", result.communityId)

rpc(clientVersion, "web3"):
  discard

rpc(getEthereumChains, "wallet"):
  discard

rpc(addEthereumChain, "wallet"):
  network: Network

rpc(deleteEthereumChain, "wallet"):
  chainId: int

rpc(fetchChainIDForURL, "wallet"):
  url: string

rpc(upsertSavedAddress, "wakuext"):
  savedAddress: SavedAddress

rpc(deleteSavedAddress, "wakuext"):
  address: string
  ens: string
  isTest: bool

rpc(getSavedAddresses, "wallet"):
  discard

rpc(checkConnected, "wallet"):
  discard

rpc(getTokens, "wallet"):
  chainId: int

rpc(getTokenList, "wallet"):
  discard

rpc(getPendingTransactions, "wallet"):
  discard

type
  TransactionIdentity* = ref object
    chainId*: int
    hash*: string
    address*: string

proc hash*(ti: TransactionIdentity): Hash =
  var h: Hash = 0
  h = h !& hash(ti.chainId)
  h = h !& hash(ti.hash)
  h = h !& hash(ti.address)
  result = !$h

proc `==`*(a, b: TransactionIdentity): bool =
  result = (a.chainId == b.chainId) and (a.hash == b.hash) and (a.address == b.address)

proc `$`*(self: TransactionIdentity): string =
  return fmt"""TransactionIdentity(
    chainId:{self.chainId},
    hash:{self.hash},
    address:{self.address},
  )"""

rpc(getPendingTransactionsForIdentities, "wallet"):
  identities = seq[TransactionIdentity]

rpc(getTransfersForIdentities, "wallet"):
  identities = seq[TransactionIdentity]

rpc(getWalletToken, "wallet"):
  accounts: seq[string]

rpc(fetchMarketValues, "wallet"):
  symbols: seq[string]
  currency: string

rpc(startWallet, "wallet"):
  discard

rpc(getTransactionEstimatedTime, "wallet"):
  chainId: int
  maxFeePerGas: float

rpc(fetchPrices, "wallet"):
  symbols: seq[string]
  currencies: seq[string]

rpc(fetchDecodedTxData, "wallet"):
  data: string

rpc(activityCenterNotifications, "wakuext"):
  request: ActivityCenterNotificationsRequest

rpc(activityCenterNotificationsCount, "wakuext"):
  request: ActivityCenterCountRequest

rpc(markAllActivityCenterNotificationsRead, "wakuext"):
  discard

rpc(markActivityCenterNotificationsRead, "wakuext"):
  ids: seq[string]

rpc(markActivityCenterNotificationsUnread, "wakuext"):
  ids: seq[string]

rpc(acceptActivityCenterNotifications, "wakuext"):
  ids: seq[string]

rpc(dismissActivityCenterNotifications, "wakuext"):
  ids: seq[string]

rpc(deleteActivityCenterNotifications, "wakuext"):
  ids: seq[string]

rpc(hasUnseenActivityCenterNotifications, "wakuext"):
  discard

rpc(markAsSeenActivityCenterNotifications, "wakuext"):
  discard

rpc(getBookmarks, "browsers"):
  discard

rpc(storeBookmark, "browsers"):
  bookmark: Bookmark

rpc(updateBookmark, "browsers"):
  originalUrl: string
  bookmark: Bookmark

rpc(deleteBookmark, "browsers"):
  url: string

rpc(setTenorAPIKey, "gif"):
  key: string

rpc(fetchGifs, "gif"):
  path: string

rpc(updateRecentGifs, "gif"):
  recentGifs: JsonNode

rpc(updateFavoriteGifs, "gif"):
  favoriteGifs: JsonNode

rpc(getRecentGifs, "gif"):
  discard

rpc(getFavoriteGifs, "gif"):
  discard

rpc(getDappPermissions, "permissions"):
  discard

rpc(addDappPermissions, "permissions"):
  permission: Permission

rpc(deleteDappPermissionsByNameAndAddress, "permissions"):
  dapp: string
  address: string

rpc(fetchMarketValues, "wallet"):
  symbols: seq[string]
  currencies: seq[string]

rpc(fetchTokenDetails, "wallet"):
  symbols: seq[string]

rpc(saveOrUpdateKeycard, "accounts"):
  keycard: JsonNode
  accountsComingFromKeycard: bool

rpc(deleteKeycardAccounts, "accounts"):
  keycardUid: string
  accountsToRemove: seq[string]

rpc(getAllKnownKeycards, "accounts"):
  discard

rpc(getKeycardsWithSameKeyUID, "accounts"):
  keyUid: string

rpc(getKeycardByKeycardUID, "accounts"):
  keycardUid: string

rpc(setKeycardName, "accounts"):
  keycardUid: string
  keyPairName: string

rpc(keycardLocked, "accounts"):
  keycardUid: string

rpc(keycardUnlocked, "accounts"):
  keycardUid: string

rpc(updateKeycardUID, "accounts"):
  oldKeycardUID: string
  newKeycardUID: string

rpc(deleteKeycard, "accounts"):
  keycardUid: string

rpc(deleteAllKeycardsWithKeyUID, "accounts"):
  keyUid: string

rpc(moveWalletAccount, "accounts"):
  fromPosition: int
  toPosition: int

rpc(updateTokenPreferences, "accounts"):
  preferences: seq[TokenPreferences]

rpc(getTokenPreferences, "accounts"):
  discard

rpc(updateKeypairName, "accounts"):
  keyUid: string
  name: string

rpc(getHourlyMarketValues, "wallet"):
  symbol: string
  currency: string
  limit: int
  aggregate: int

rpc(getDailyMarketValues, "wallet"):
  symbol: string
  currency: string
  limit: int
  allDate: bool
  aggregate: int

rpc(getName, "ens"):
  chainId: int
  address: string

rpc(getBalanceHistory, "wallet"):
  chainIds: seq[int]
  addresses: seq[string]
  tokenSymbol: string
  currencySymbol: string
  timeInterval: int

rpc(getCachedCurrencyFormats, "wallet"):
  discard

rpc(fetchAllCurrencyFormats, "wallet"):
  discard

rpc(hasPairedDevices, "accounts"):
  discard
