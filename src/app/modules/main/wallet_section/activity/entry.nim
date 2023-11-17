import NimQml, json, strformat, sequtils, strutils, logging, stint

import backend/activity as backend
import app/modules/shared_models/currency_amount

import app/global/global_singleton

import app_service/service/currency/service

import web3/ethtypes as eth

# Additional data needed to build an Entry, which is
# not included in the metadata and needs to be
# fetched from a different source.
type
  ExtraData* = object
    inAmount*: float64
    outAmount*: float64

  AmountToCurrencyConvertor* = proc (amount: UInt256, symbol: string): CurrencyAmount

# Used to display an activity history header entry in the QML UI
QtObject:
  type
    ActivityEntry* = ref object of QObject
      valueConvertor: AmountToCurrencyConvertor
      metadata: backend.ActivityEntry
      extradata: ExtraData

      amountCurrency: CurrencyAmount
      noAmount: CurrencyAmount

      nftName: string
      nftImageURL: string

  proc setup(self: ActivityEntry) =
    self.QObject.setup

  proc delete*(self: ActivityEntry) =
    self.QObject.delete

  proc isInTransactionType(self: ActivityEntry): bool =
    return self.metadata.activityType == backend.ActivityType.Receive or self.metadata.activityType == backend.ActivityType.Mint

  proc newMultiTransactionActivityEntry*(metadata: backend.ActivityEntry, extradata: ExtraData, valueConvertor: AmountToCurrencyConvertor): ActivityEntry =
    new(result, delete)
    result.valueConvertor = valueConvertor
    result.metadata = metadata
    result.extradata = extradata
    result.noAmount = newCurrencyAmount()
    result.amountCurrency = valueConvertor(
      if result.isInTransactionType(): metadata.amountIn else: metadata.amountOut,
      if result.isInTransactionType(): metadata.symbolIn.get("") else: metadata.symbolOut.get(""),
    )
    result.setup()

  proc newTransactionActivityEntry*(metadata: backend.ActivityEntry, fromAddresses: seq[string], extradata: ExtraData, valueConvertor: AmountToCurrencyConvertor): ActivityEntry =
    new(result, delete)
    result.valueConvertor = valueConvertor
    result.metadata = metadata
    result.extradata = extradata

    result.amountCurrency = valueConvertor(
      if result.isInTransactionType(): metadata.amountIn else: metadata.amountOut,
      if result.isInTransactionType(): metadata.symbolIn.get("") else: metadata.symbolOut.get(""),
    )
    result.noAmount = newCurrencyAmount()

    result.setup()

  proc isMultiTransaction*(self: ActivityEntry): bool {.slot.} =
    return self.metadata.getPayloadType() == backend.PayloadType.MultiTransaction

  QtProperty[bool] isMultiTransaction:
    read = isMultiTransaction

  proc isPendingTransaction*(self: ActivityEntry): bool {.slot.} =
    return self.metadata.getPayloadType() == backend.PayloadType.PendingTransaction

  QtProperty[bool] isPendingTransaction:
    read = isPendingTransaction

  proc `$`*(self: ActivityEntry): string =
    return fmt"""ActivityEntry(
      metadata:{$self.metadata},
    )"""

  # TODO: is this the right way to pass transaction identity? Why not use the instance?
  proc getId*(self: ActivityEntry): string {.slot.} =
    if self.isMultiTransaction():
      return $(self.metadata.getMultiTransactionId().get())
    return $(self.metadata.getTransactionIdentity().get().hash)

  QtProperty[string] id:
    read = getId

  proc getMetadata*(self: ActivityEntry): backend.ActivityEntry =
    return self.metadata

  proc getSender*(self: ActivityEntry): string {.slot.} =
    return if self.metadata.sender.isSome(): "0x" & self.metadata.sender.unsafeGet().toHex() else: ""

  QtProperty[string] sender:
    read = getSender

  proc getRecipient*(self: ActivityEntry): string {.slot.} =
    return if self.metadata.recipient.isSome(): "0x" & self.metadata.recipient.unsafeGet().toHex() else: ""

  QtProperty[string] recipient:
    read = getRecipient

  proc getInSymbol*(self: ActivityEntry): string {.slot.} =
    return self.metadata.symbolIn.get("")

  QtProperty[string] inSymbol:
    read = getInSymbol

  proc getOutSymbol*(self: ActivityEntry): string {.slot.} =
    return self.metadata.symbolOut.get("")

  QtProperty[string] outSymbol:
    read = getOutSymbol

  proc getSymbol*(self: ActivityEntry): string {.slot.} =
    if self.isInTransactionType():
      return self.getInSymbol()
    return self.getOutSymbol()

  QtProperty[string] symbol:
    read = getSymbol

  proc getTimestamp*(self: ActivityEntry): int {.slot.} =
    return self.metadata.timestamp

  QtProperty[int] timestamp:
    read = getTimestamp

  proc getStatus*(self: ActivityEntry): int {.slot.} =
    return self.metadata.activityStatus.int

  QtProperty[int] status:
    read = getStatus

  proc getChainIdIn*(self: ActivityEntry): int {.slot.} =
    return self.metadata.chainIdIn.get(ChainId(0)).int

  QtProperty[int] chainIdIn:
    read = getChainIdIn

  proc getChainIdOut*(self: ActivityEntry): int {.slot.} =
    return self.metadata.chainIdOut.get(ChainId(0)).int

  QtProperty[int] chainIdOut:
    read = getChainIdOut

  proc getChainId*(self: ActivityEntry): int {.slot.} =
    if self.isInTransactionType():
      return self.getChainIdIn()
    return self.getChainIdOut()

  QtProperty[int] chainId:
    read = getChainId

  proc getIsNFT*(self: ActivityEntry): bool {.slot.} =
    return self.metadata.transferType.isSome() and self.metadata.transferType.unsafeGet() == TransferType.Erc721

  QtProperty[bool] isNFT:
    read = getIsNFT

  proc nftNameChanged*(self: ActivityEntry) {.signal.}

  proc getNftName*(self: ActivityEntry): string {.slot.} =
    return self.nftName

  proc setNftName*(self: ActivityEntry, nftName: string) =
    self.nftName = nftName
    self.nftNameChanged()

  QtProperty[string] nftName:
    read = getNftName
    write = setNftName
    notify = nftNameChanged

  proc nftImageUrlChanged*(self: ActivityEntry) {.signal.}

  proc getNftImageUrl*(self: ActivityEntry): string {.slot.} =
    return self.nftImageUrl

  proc setNftImageUrl*(self: ActivityEntry, nftImageUrl: string) =
    self.nftImageUrl = nftImageUrl
    self.nftImageUrlChanged()

  QtProperty[string] nftImageUrl:
    read = getNftImageUrl
    write = setNftImageUrl
    notify = nftImageUrlChanged

  proc getTxType*(self: ActivityEntry): int {.slot.} =
    return self.metadata.activityType.int

  QtProperty[int] txType:
    read = getTxType

  proc getTokenInAddress*(self: ActivityEntry): string {.slot.} =
    if self.metadata.tokenIn.isSome:
      let address = self.metadata.tokenIn.unsafeGet().address
      if address.isSome:
        return "0x" & toHex(address.unsafeGet())
    return ""

  QtProperty[string] tokenInAddress:
    read = getTokenInAddress

  proc getTokenOutAddress*(self: ActivityEntry): string {.slot.} =
    if self.metadata.tokenOut.isSome:
      let address = self.metadata.tokenOut.unsafeGet().address
      if address.isSome:
        return "0x" & toHex(address.unsafeGet())
    return ""

  QtProperty[string] tokenOutAddress:
    read = getTokenOutAddress

  proc getTokenAddress*(self: ActivityEntry): string {.slot.} =
    if self.isInTransactionType():
      return self.getTokenInAddress()
    return self.getTokenOutAddress()

  QtProperty[string] tokenAddress:
    read = getTokenAddress

  proc getTokenID*(self: ActivityEntry): string {.slot.} =
    if self.metadata.getPayloadType() == backend.PayloadType.MultiTransaction:
      error "getTokenID: ActivityEntry is not a transaction"
      return ""

    var tokenId: Option[TokenID]
    if self.isInTransactionType():
      if self.metadata.tokenIn.isSome():
        tokenId = self.metadata.tokenIn.unsafeGet().tokenId
    elif self.metadata.tokenOut.isSome():
        tokenId = self.metadata.tokenOut.unsafeGet().tokenId

    if tokenId.isSome():
      return $stint.fromHex(UInt256, string(tokenId.unsafeGet()))
    return ""

  QtProperty[string] tokenID:
    read = getTokenID

  proc getOutAmount*(self: ActivityEntry): float {.slot.} =
    return self.extradata.outAmount

  QtProperty[float] outAmount:
    read = getOutAmount

  proc getInAmount*(self: ActivityEntry): float {.slot.} =
    return self.extradata.inAmount

  QtProperty[float] inAmount:
    read = getInAmount

  proc getAmount*(self: ActivityEntry): float {.slot.} =
    if self.isInTransactionType():
      return self.getInAmount()
    return self.getOutAmount()

  QtProperty[float] amount:
    read = getAmount

  proc getAmountCurrency*(self: ActivityEntry): QVariant {.slot.} =
    return newQVariant(self.amountCurrency)

  QtProperty[QVariant] amountCurrency:
    read = getAmountCurrency
