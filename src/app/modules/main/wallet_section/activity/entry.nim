import NimQml, json, strformat, sequtils, strutils, logging, stint

import backend/transactions
import backend/activity as backend
import app/modules/shared_models/currency_amount

import app/global/global_singleton

import app_service/service/transaction/dto
import app_service/service/currency/dto as currency
import app_service/service/currency/service

import web3/ethtypes as eth

# Additional data needed to build an Entry, which is
# not included in the metadata and needs to be
# fetched from a different source.
type
  ExtraData* = object
    inAmount*: float64
    outAmount*: float64
    # TODO: Fields below should come from the metadata. see #11597
    inSymbol*: string
    outSymbol*: string

  AmountToCurrencyConvertor* = proc (amount: UInt256, symbol: string): CurrencyAmount

# It is used to display an activity history entry in the QML UI
#
# TODO remove this legacy after the NFT is served async; see #11598
# TODO add all required metadata from filtering; see #11597
#
# Looking into going away from carying the whole detailed data and just keep the required data for the UI
# and request the detailed data on demand
#
# Outdated: The ActivityEntry contains one of the following instances transaction, pending transaction or multi-transaction
QtObject:
  type
    ActivityEntry* = ref object of QObject
      # TODO: these should be removed; see #11598
      multi_transaction: MultiTransactionDto
      transaction: ref TransactionDto
      isPending: bool

      valueConvertor: AmountToCurrencyConvertor
      metadata: backend.ActivityEntry
      extradata: ExtraData

      totalFees: CurrencyAmount
      amountCurrency: CurrencyAmount
      noAmount: CurrencyAmount

  proc setup(self: ActivityEntry) =
    self.QObject.setup

  proc delete*(self: ActivityEntry) =
    self.QObject.delete

  proc newMultiTransactionActivityEntry*(mt: MultiTransactionDto, metadata: backend.ActivityEntry, extradata: ExtraData, valueConvertor: AmountToCurrencyConvertor): ActivityEntry =
    new(result, delete)
    result.multi_transaction = mt
    result.transaction = nil
    result.isPending = false
    result.valueConvertor = valueConvertor
    result.metadata = metadata
    result.extradata = extradata
    result.noAmount = newCurrencyAmount()
    result.amountCurrency = valueConvertor(
      if metadata.activityType == backend.ActivityType.Receive: metadata.amountIn else: metadata.amountOut,
      if metadata.activityType == backend.ActivityType.Receive: mt.toAsset else: mt.fromAsset,
    )
    result.setup()

  proc newTransactionActivityEntry*(tr: ref TransactionDto, metadata: backend.ActivityEntry, fromAddresses: seq[string], extradata: ExtraData, valueConvertor: AmountToCurrencyConvertor): ActivityEntry =
    new(result, delete)
    result.multi_transaction = nil
    result.transaction = tr
    result.isPending = metadata.payloadType == backend.PayloadType.PendingTransaction
    result.valueConvertor = valueConvertor
    result.metadata = metadata
    result.extradata = extradata

    result.totalFees = valueConvertor(stint.fromHex(UInt256, tr.totalFees), "Gwei")
    result.amountCurrency = valueConvertor(
      if metadata.activityType == backend.ActivityType.Receive: metadata.amountIn else: metadata.amountOut,
      tr.symbol
    )
    result.noAmount = newCurrencyAmount()

    result.setup()

  proc isMultiTransaction*(self: ActivityEntry): bool {.slot.} =
    return self.multi_transaction != nil

  QtProperty[bool] isMultiTransaction:
    read = isMultiTransaction

  proc isPendingTransaction*(self: ActivityEntry): bool {.slot.} =
    return (not self.isMultiTransaction()) and self.isPending

  QtProperty[bool] isPendingTransaction:
    read = isPendingTransaction

  proc `$`*(self: ActivityEntry): string =
    let mtStr = if self.multi_transaction != nil: $(self.multi_transaction.id) else: "0"
    let trStr = if self.transaction != nil: $(self.transaction[]) else: "nil"

    return fmt"""ActivityEntry(
      multi_transaction.id:{mtStr},
      transaction:{trStr},
      isPending:{self.isPending}
    )"""

  proc isInTransactionType(self: ActivityEntry): bool =
    return self.metadata.activityType == backend.ActivityType.Receive or self.metadata.activityType == backend.ActivityType.Mint

  proc getMultiTransaction*(self: ActivityEntry): MultiTransactionDto =
    if not self.isMultiTransaction():
      raise newException(Defect, "ActivityEntry is not a MultiTransaction")
    return self.multi_transaction

  proc getId*(self: ActivityEntry): string {.slot.} =
    if self.isMultiTransaction():
      return $self.multi_transaction.id
    elif self.transaction != nil:
      return self.transaction[].id
    return ""

  QtProperty[string] id:
    read = getId

  proc getSender*(self: ActivityEntry): string {.slot.} =
    return if self.metadata.sender.isSome(): "0x" & self.metadata.sender.unsafeGet().toHex() else: ""

  QtProperty[string] sender:
    read = getSender

  proc getRecipient*(self: ActivityEntry): string {.slot.} =
    return if self.metadata.recipient.isSome(): "0x" & self.metadata.recipient.unsafeGet().toHex() else: ""

  QtProperty[string] recipient:
    read = getRecipient

  proc getInSymbol*(self: ActivityEntry): string {.slot.} =
    return self.extradata.inSymbol

  QtProperty[string] inSymbol:
    read = getInSymbol

  proc getOutSymbol*(self: ActivityEntry): string {.slot.} =
    return self.extradata.outSymbol

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

  proc getNFTName*(self: ActivityEntry): string {.slot.} =
    # TODO: complete this async #11597
    return ""

  # TODO: lazy load this in activity history service. See #11597
  QtProperty[string] nftName:
    read = getNFTName

  proc getNFTImageURL*(self: ActivityEntry): string {.slot.} =
    # TODO: complete this async #11597
    return ""

  # TODO: lazy load this in activity history service. See #11597
  QtProperty[string] nftImageURL:
    read = getNFTImageURL

  proc getTotalFees*(self: ActivityEntry): QVariant {.slot.} =
    if self.transaction == nil:
      error "getTotalFees: ActivityEntry is not an transaction entry"
      return newQVariant(self.noAmount)
    return newQVariant(self.totalFees)

  # TODO: lazy load this in activity history service. See #11597
  QtProperty[QVariant] totalFees:
    read = getTotalFees

  proc getTxType*(self: ActivityEntry): int {.slot.} =
    return self.metadata.activityType.int

  QtProperty[int] txType:
    read = getTxType

  proc getTokenType*(self: ActivityEntry): string {.slot.} =
    let s = if self.transaction != nil: self.transaction[].symbol else: ""
    if self.transaction != nil:
      return self.transaction[].typeValue
    if self.isInTransactionType() and self.metadata.tokenOut.isSome:
      return $self.metadata.tokenOut.unsafeGet().tokenType
    if self.metadata.tokenIn.isSome:
      return $self.metadata.tokenIn.unsafeGet().tokenType
    return ""

  # TODO: used only in details, move it to a entry_details.nim. See #11598
  QtProperty[string] tokenType:
    read = getTokenType
    
  proc getTokenInAddress*(self: ActivityEntry): string {.slot.} =
    if self.metadata.tokenIn.isSome:
      let address = self.metadata.tokenIn.unsafeGet().address
      if address.isSome:
        return toHex(address.unsafeGet())
    return ""

  QtProperty[string] tokenInAddress:
    read = getTokenInAddress

  proc getTokenOutAddress*(self: ActivityEntry): string {.slot.} =
    if self.metadata.tokenOut.isSome:
      let address = self.metadata.tokenOut.unsafeGet().address
      if address.isSome:
        return toHex(address.unsafeGet())
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
    if self.metadata.payloadType == backend.PayloadType.MultiTransaction:
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
    return float(self.extradata.outAmount)

  QtProperty[float] outAmount:
    read = getOutAmount

  proc getInAmount*(self: ActivityEntry): float {.slot.} =
    return float(self.extradata.inAmount)

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
