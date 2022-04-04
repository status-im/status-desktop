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

  Permission* = ref object of RootObj
    dapp* {.serializedFieldName("dapp").}: string
    address* {.serializedFieldName("address").}: string
    permissions* {.serializedFieldName("permissions").}: seq[string]

  SavedAddress* = ref object of RootObj
    name* {.serializedFieldName("name").}: string
    address* {.serializedFieldName("address").}: string

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


rpc(clientVersion, "web3"):
  discard

rpc(getCustomTokens, "wallet"):
  discard

rpc(deleteCustomTokenByChainID, "wallet"):
  chainId: int
  address: string

rpc(addCustomToken, "wallet"):
  token: Token

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

rpc(addSavedAddress, "wallet"):
  savedAddress: SavedAddress

rpc(deleteSavedAddress, "wallet"):
  address: string

rpc(getSavedAddresses, "wallet"):
  discard

rpc(getTokens, "wallet"):
  chainId: int

rpc(getTokensBalancesForChainIDs, "wallet"):
  chainIds: seq[int]
  accounts: seq[string]
  tokens: seq[string]

rpc(discoverToken, "wallet"):
  chainId: int
  address: string

rpc(getPendingTransactions, "wallet"):
  discard

rpc(fetchPrices, "wallet"):
  symbols: seq[string]
  currency: string

rpc(generateAccount, "accounts"):
  password: string
  name: string
  color: string
  emoji: string

rpc(addAccountWithMnemonic, "accounts"):
  mnemonic: string
  password: string
  name: string
  color: string
  emoji: string

rpc(addAccountWithPrivateKey, "accounts"):
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