import NimQml, json

import ./io_interface
import ../../../shared_models/token_model as token_model

import ./item as account_item

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      assets: token_model.Model
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

  proc getAssetsModel*(self: View): token_model.Model =
    return self.assets

  proc assetsChanged(self: View) {.signal.}
  proc getAssets*(self: View): QVariant {.slot.} =
    return newQVariant(self.assets)
  QtProperty[QVariant] assets:
    read = getAssets
    notify = assetsChanged

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

  proc setData*(self: View, item: account_item.Item) =
    self.setAssetsLoading(item.getAssetsLoading())  
    self.hasBalanceCache = item.getHasBalanceCache()
    self.hasBalanceCacheChanged()
    self.hasMarketValuesCache = item.getHasMarketValuesCache()
    self.hasMarketValuesCacheChanged()

  proc setCacheValues*(self: View, hasBalanceCache: bool, hasMarketValuesCache: bool) =
    self.hasBalanceCache = hasBalanceCache
    self.hasBalanceCacheChanged()
    self.hasMarketValuesCache = hasMarketValuesCache
    self.hasMarketValuesCacheChanged()   
