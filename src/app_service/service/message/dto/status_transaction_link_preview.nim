import json, stew/shims/strformat, NimQml, chronicles

include ../../../common/json_utils

QtObject:
  type StatusTransactionLinkPreview* = ref object of QObject
    txType: int
    amount: string
    asset: string
    toAsset: string
    address: string
    chainId: int

  proc setup*(self: StatusTransactionLinkPreview) =
    self.QObject.setup()

  proc delete*(self: StatusTransactionLinkPreview) =
    self.QObject.delete()

  proc newStatusTransactionLinkPreview*(txType: int, amount: string, asset: string, toAsset: string, address: string, chainId: int): StatusTransactionLinkPreview =
    new(result, delete)
    result.setup()
    result.txType = txType
    result.amount = amount
    result.asset = asset
    result.toAsset = toAsset
    result.address = address
    result.chainId = chainId

  proc txTypeChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getTxType*(self: StatusTransactionLinkPreview): int {.slot.} =
    result = self.txType
  QtProperty[int] txType:
    read = getTxType
    notify = txTypeChanged

  proc amountChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getAmount*(self: StatusTransactionLinkPreview): string {.slot.} =
    result = self.amount
  QtProperty[string] amount:
    read = getAmount
    notify = amountChanged

  proc assetChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getAsset*(self: StatusTransactionLinkPreview): string {.slot.} =
    result = self.asset
  QtProperty[string] asset:
    read = getAsset
    notify = assetChanged

  proc toAssetChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getToAsset*(self: StatusTransactionLinkPreview): string {.slot.} =
    result = self.toAsset
  QtProperty[string] toAsset:
    read = getToAsset
    notify = toAssetChanged

  proc addressChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getAddress*(self: StatusTransactionLinkPreview): string {.slot.} =
    result = self.address
  QtProperty[string] address:
    read = getAddress
    notify = addressChanged

  proc chainIdChanged*(self: StatusTransactionLinkPreview) {.signal.}
  proc getChainId*(self: StatusTransactionLinkPreview): int {.slot.} =
    result = self.chainId
  QtProperty[int] chainId:
    read = getChainId
    notify = chainIdChanged  

  proc toStatusTransactionLinkPreview*(jsonObj: JsonNode): StatusTransactionLinkPreview =
    var txType: int
    var amount: string
    var asset: string
    var toAsset: string
    var address: string
    var chainId: int

    discard jsonObj.getProp("txType", txType)
    discard jsonObj.getProp("amount", amount)
    discard jsonObj.getProp("asset", asset)
    discard jsonObj.getProp("toAsset", toAsset)
    discard jsonObj.getProp("address", address)
    discard jsonObj.getProp("chainId", chainId)

    result = newStatusTransactionLinkPreview(txType, amount, asset, toAsset, address, chainId)

  proc `$`*(self: StatusTransactionLinkPreview): string =
    result = fmt"""StatusTransactionLinkPreview(
      txType: {self.txType},
      amount: {self.amount},
      asset: {self.asset},
      toAsset: {self.toAsset},
      address: {self.address},
      chainId: {self.chainId}
    )"""

  proc `%`*(self: StatusTransactionLinkPreview): JsonNode =
    return %* {
      "txType": self.txType,
      "amount": self.amount,
      "asset": self.asset,
      "toAsset": self.toAsset,
      "address": self.address,
      "chainId": self.chainId
    }

  proc empty*(self: StatusTransactionLinkPreview): bool =
    return self.amount.len == 0 and self.asset.len == 0 and self.toAsset.len == 0 and self.address.len == 0