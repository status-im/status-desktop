import tables, json, strformat, strutils

include  app_service/common/json_utils

const WalletTypeGenerated* = "generated" # refers to accounts generated from the profile keypair
const WalletTypeSeed* = "seed"
const WalletTypeWatch* = "watch"
const WalletTypeKey* = "key"

const AccountNonOperable* = "no" # an account is non operable it is not a keycard account and there is no keystore file for it and no keystore file for the address it is derived from
const AccountPartiallyOperable* = "partially" # an account is partially operable if it is not a keycard account and there is created keystore file for the address it is derived from
const AccountFullyOperable* = "fully" # an account is fully operable if it is not a keycard account and there is a keystore file for it

type
  WalletAccountDto* = ref object of RootObj
    name*: string
    address*: string
    mixedcaseAddress*: string
    keyUid*: string
    path*: string
    colorId*: string
    publicKey*: string
    walletType*: string
    isWallet*: bool
    isChat*: bool
    emoji*: string
    ens*: string
    assetsLoading*: bool
    hasBalanceCache*: bool
    hasMarketValuesCache*: bool
    removed*: bool # needs for synchronization
    operable*: string
    createdAt*: int
    position*: int
    prodPreferredChainIDs*: string
    testPreferredChainIDs*: string
    hideFromTotalBalance*: bool

proc toWalletAccountDto*(jsonObj: JsonNode): WalletAccountDto =
  result = WalletAccountDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("mixedcase-address", result.mixedcaseAddress)
  discard jsonObj.getProp("key-uid", result.keyUid)
  discard jsonObj.getProp("path", result.path)
  discard jsonObj.getProp("colorId", result.colorId)
  result.colorId = result.colorId.toUpper() # to match `preDefinedWalletAccountColors` on the qml side
  discard jsonObj.getProp("wallet", result.isWallet)
  discard jsonObj.getProp("chat", result.isChat)
  discard jsonObj.getProp("public-key", result.publicKey)
  discard jsonObj.getProp("type", result.walletType)
  discard jsonObj.getProp("emoji", result.emoji)
  discard jsonObj.getProp("removed", result.removed)
  discard jsonObj.getProp("operable", result.operable)
  discard jsonObj.getProp("createdAt", result.createdAt)
  discard jsonObj.getProp("position", result.position)
  discard jsonObj.getProp("prodPreferredChainIds", result.prodPreferredChainIds)
  discard jsonObj.getProp("testPreferredChainIds", result.testPreferredChainIds)
  discard jsonObj.getProp("hidden", result.hideFromTotalBalance)
  result.assetsLoading = true
  result.hasBalanceCache = false
  result.hasMarketValuesCache = false

proc `$`*(self: WalletAccountDto): string =
  result = fmt"""WalletAccountDto[
    name: {self.name},
    address: {self.address},
    mixedcaseAddress: {self.mixedcaseAddress},
    keyUid: {self.keyUid},
    path: {self.path},
    colorId: {self.colorId},
    publicKey: {self.publicKey},
    walletType: {self.walletType},
    isChat: {self.isChat},
    emoji: {self.emoji},
    assetsLoading: {self.assetsLoading},
    hasBalanceCache: {self.hasBalanceCache},
    hasMarketValuesCache: {self.hasMarketValuesCache},
    removed: {self.removed},
    operable: {self.operable},
    prodPreferredChainIds: {self.prodPreferredChainIds},
    testPreferredChainIds: {self.testPreferredChainIds},
    hideFromTotalBalance: {self.hideFromTotalBalance}
    ]"""

proc `%`*(x: WalletAccountDto): JsonNode =
  result = newJobject()
  result["name"] = % x.name
  result["address"] = % x.address
  result["mixedcaseAddress"] = % x.mixedcaseAddress
  result["keyUid"] = % x.keyUid
  result["path"] = % x.path
  result["colorId"] = % x.colorId
  result["publicKey"] = % x.publicKey
  result["isWallet"] = % x.isWallet
  result["isChat"] = % x.isChat
  result["emoji"] = % x.emoji
  result["ens"] = % x.ens
  result["assetsLoading"] = % x.assetsLoading
  result["hasBalanceCache"] = % x.hasBalanceCache
  result["hasMarketValuesCache"] = % x.hasMarketValuesCache
  result["removed"] = % x.removed
  result["operable"] = % x.operable
  result["createdAt"] = % x.createdAt
  result["position"] = % x.position
  result["prodPreferredChainIds"] = % x.prodPreferredChainIds
  result["testPreferredChainIds"] = % x.testPreferredChainIds
  result["hideFromTotalBalance"] = % x.hideFromTotalBalance