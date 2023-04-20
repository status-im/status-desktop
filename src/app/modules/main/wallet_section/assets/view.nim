import NimQml, sequtils, sugar, json

import ./io_interface
import ../../../shared_models/token_model as token_model
import ../../../shared_models/token_item as token_item
import ../../../shared_models/currency_amount

import ./item as account_item

const GENERATED = "generated"
const GENERATED_FROM_IMPORTED = "generated from imported accounts"

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      defaultAccount: account_item.Item
      name: string
      keyUid: string
      address: string
      path: string
      color: string
      walletType: string
      currencyBalance: CurrencyAmount
      assets: token_model.Model
      emoji: string
      assetsLoading: bool
      hasBalanceCache: bool
      hasMarketValuesCache: bool

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.assets.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.setup()
    result.delegate = delegate
    result.assets = token_model.newModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.name)

  proc nameChanged(self: View) {.signal.}

  QtProperty[QVariant] name:
    read = getName
    notify = nameChanged

  proc getKeyUid(self: View): QVariant {.slot.} =
    return newQVariant(self.keyUid)
  proc keyUidChanged(self: View) {.signal.}
  QtProperty[QVariant] keyUid:
    read = getKeyUid
    notify = keyUidChanged

  proc getAddress(self: View): QVariant {.slot.} =
    return newQVariant(self.address)
  proc addressChanged(self: View) {.signal.}
  QtProperty[QVariant] address:
    read = getAddress
    notify = addressChanged

  proc getPath(self: View): QVariant {.slot.} =
    return newQVariant(self.path)

  proc pathChanged(self: View) {.signal.}

  QtProperty[QVariant] path:
    read = getPath
    notify = pathChanged

  proc getColor(self: View): QVariant {.slot.} =
    return newQVariant(self.color)

  proc colorChanged(self: View) {.signal.}

  QtProperty[QVariant] color:
    read = getColor
    notify = colorChanged

  proc getWalletType(self: View): QVariant {.slot.} =
    return newQVariant(self.walletType)

  proc walletTypeChanged(self: View) {.signal.}

  QtProperty[QVariant] walletType:
    read = getWalletType
    notify = walletTypeChanged

  proc currencyBalanceChanged(self: View) {.signal.}
  proc getCurrencyBalance*(self: View): QVariant {.slot.} =
    return newQVariant(self.currencyBalance)
  proc setCurrencyBalance*(self: View, value: CurrencyAmount) =
    self.currencyBalance = value
    self.currencyBalanceChanged()
  QtProperty[QVariant] currencyBalance:
    read = getCurrencyBalance
    notify = currencyBalanceChanged

  proc getAssetsModel*(self: View): token_model.Model =
    return self.assets

  proc assetsChanged(self: View) {.signal.}
  proc getAssets*(self: View): QVariant {.slot.} =
    return newQVariant(self.assets)
  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged

  proc getEmoji(self: View): QVariant {.slot.} =
    return newQVariant(self.emoji)

  proc emojiChanged(self: View) {.signal.}

  QtProperty[QVariant] emoji:
    read = getEmoji
    notify = emojiChanged

  proc getAssetsLoading(self: View): QVariant {.slot.} =
    return newQVariant(self.assetsLoading)
  proc assetsLoadingChanged(self: View) {.signal.}
  QtProperty[QVariant] assetsLoading:
    read = getAssetsLoading
    notify = assetsLoadingChanged

  proc setAssetsLoading*(self:View, assetLoading: bool) =
    if assetLoading != self.assetsLoading:
      self.assetsLoading = assetLoading
      self.assetsLoadingChanged()

  proc getHasBalanceCache(self: View): QVariant {.slot.} =
    return newQVariant(self.hasBalanceCache)
  proc hasBalanceCacheChanged(self: View) {.signal.}
  QtProperty[QVariant] hasBalanceCache:
    read = getHasBalanceCache
    notify = hasBalanceCacheChanged

  proc getHasMarketValuesCache(self: View): QVariant {.slot.} =
    return newQVariant(self.hasMarketValuesCache)
  proc hasMarketValuesCacheChanged(self: View) {.signal.}
  QtProperty[QVariant] hasMarketValuesCache:
    read = getHasMarketValuesCache
    notify = hasMarketValuesCacheChanged

  proc update(self: View, address: string, accountName: string, color: string, emoji: string) {.slot.} =
    self.delegate.update(address, accountName, color, emoji)

  proc setDefaultWalletAccount*(self: View, default: account_item.Item) =
    self.defaultAccount = default

  proc setData*(self: View, item: account_item.Item) =
    if(self.name != item.getName()):
      self.name = item.getName()
      self.nameChanged()
    if(self.keyUid != item.getKeyUid()):
      self.keyUid = item.getKeyUid()
      self.keyUidChanged()
    if(self.address != item.getAddress()):
      self.address = item.getAddress()
      self.addressChanged()
    if(self.path != item.getPath()):
      self.path = item.getPath()
      self.pathChanged()
    if(self.color != item.getColor()):
      self.color = item.getColor()
      self.colorChanged()
    if(self.walletType != item.getWalletType()):
      self.walletType = item.getWalletType()
      self.walletTypeChanged()
    if(self.emoji != item.getEmoji()):
      self.emoji = item.getEmoji()
      self.emojiChanged()
    self.setAssetsLoading(item.getAssetsLoading())  
    self.hasBalanceCache = item.getHasBalanceCache()
    self.hasBalanceCacheChanged()
    self.hasMarketValuesCache = item.getHasMarketValuesCache()
    self.hasMarketValuesCacheChanged()

  proc findTokenSymbolByAddress*(self: View, address: string): string {.slot.} =
    return self.delegate.findTokenSymbolByAddress(address)

  proc hasGas*(self: View, chainId: int, nativeGasSymbol: string, requiredGas: float): bool {.slot.} =
    return self.assets.hasGas(chainId, nativeGasSymbol, requiredGas)

  proc setCacheValues*(self: View, hasBalanceCache: bool, hasMarketValuesCache: bool) =
    self.hasBalanceCache = hasBalanceCache
    self.hasBalanceCacheChanged()
    self.hasMarketValuesCache = hasMarketValuesCache
    self.hasMarketValuesCacheChanged()   

  proc getHasCollectiblesCache(self: View): bool {.slot.} =
    return self.delegate.getHasCollectiblesCache(self.address)
