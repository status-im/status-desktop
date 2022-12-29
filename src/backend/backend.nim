import json, json_serialization
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

  Network* = ref object of RootObj
    chainId* {.serializedFieldName("chainId").}: int
    nativeCurrencyDecimals* {.serializedFieldName("nativeCurrencyDecimals").}: int
    layer* {.serializedFieldName("layer").}: int
    chainName* {.serializedFieldName("chainName").}: string
    rpcURL* {.serializedFieldName("rpcUrl").}: string
    blockExplorerURL* {.serializedFieldName("blockExplorerUrl").}: string
    iconURL* {.serializedFieldName("iconUrl").}: string
    nativeCurrencyName* {.serializedFieldName("nativeCurrencyName").}: string
    nativeCurrencySymbol* {.serializedFieldName("nativeCurrencySymbol").}: string
    isTest* {.serializedFieldName("isTest").}: bool
    enabled* {.serializedFieldName("enabled").}: bool
    chainColor* {.serializedFieldName("chainColor").}: string
    shortName* {.serializedFieldName("shortName").}: string

rpc(clientVersion, "web3"):
  discard

rpc(getOpenseaCollectionsByOwner, "wallet"):
  chainId: int
  address: string

rpc(getOpenseaAssetsByOwnerAndCollection, "wallet"):
  chainId: int
  address: string
  collectionSlug: string
  limit: int

rpc(getEthereumChains, "wallet"):
  onlyEnabled: bool

rpc(addEthereumChain, "wallet"):
  network: Network

rpc(deleteEthereumChain, "wallet"):
  chainId: int

rpc(upsertSavedAddress, "wakuext"):
  savedAddress: SavedAddress

rpc(deleteSavedAddress, "wakuext"):
  chainId: int
  address: string

rpc(getSavedAddresses, "wallet"):
  discard

rpc(getTokens, "wallet"):
  chainId: int

rpc(getTokensBalancesForChainIDs, "wallet"):
  chainIds: seq[int]
  accounts: seq[string]
  tokens: seq[string]

rpc(getPendingTransactionsByChainIDs, "wallet"):
  chainIds: seq[int]

rpc(getWalletToken, "wallet"):
  accounts: seq[string]

rpc(startWallet, "wallet"):
  discard

rpc(startBalanceHistory, "wallet"):
  discard

rpc(getTransactionEstimatedTime, "wallet"):
  chainId: int
  maxFeePerGas: float

rpc(fetchPrices, "wallet"):
  symbols: seq[string]
  currency: string

rpc(generateAccountWithDerivedPath, "accounts"):
  password: string
  name: string
  color: string
  emoji: string
  path: string
  derivedFrom: string

rpc(generateAccountWithDerivedPathPasswordVerified, "accounts"):
  password: string
  name: string
  color: string
  emoji: string
  path: string
  derivedFrom: string

rpc(addAccountWithMnemonicAndPath, "accounts"):
  mnemonic: string
  password: string
  name: string
  color: string
  emoji: string
  path: string

rpc(addAccountWithMnemonicAndPathPasswordVerified, "accounts"):
  mnemonic: string
  password: string
  name: string
  color: string
  emoji: string
  path: string

rpc(addAccountWithPrivateKey, "accounts"):
  privateKey: string
  password: string
  name: string
  color: string
  emoji: string

rpc(addAccountWithPrivateKeyPasswordVerified, "accounts"):
  privateKey: string
  password: string
  name: string
  color: string
  emoji: string

rpc(addAccountWatch, "accounts"):
  address: string
  name: string
  color: string
  emoji: string

rpc(activityCenterNotifications, "wakuext"):
  cursorVal: JsonNode
  limit: int

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

rpc(unreadActivityCenterNotificationsCount, "wakuext"):
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
  currency: string

rpc(fetchTokenDetails, "wallet"):
  symbols: seq[string]

rpc(addMigratedKeyPair, "accounts"):
  keycardUid: string
  keyPairName: string
  keyUid: string
  accountAddresses: seq[string]
  keyStoreDir: string

rpc(getAllKnownKeycards, "accounts"):
  discard

rpc(getAllMigratedKeyPairs, "accounts"):
  discard

rpc(getMigratedKeyPairByKeyUID, "accounts"):
  keyUid: string

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
  chainId: int
  address: string
  currency: string
  timeInterval: int