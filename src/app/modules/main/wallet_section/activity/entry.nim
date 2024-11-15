import NimQml, json, stew/shims/strformat, sequtils, strutils, logging, stint

import backend/activity as backend
import app/modules/shared_models/currency_amount

import app/global/global_singleton

import app_service/common/wallet_constants
import app_service/service/currency/service

import app/modules/shared/wallet_utils

import web3/ethtypes as eth

import ./transaction_identities_model as txid

# Additional data needed to build an Entry, which is
# not included in the metadata and needs to be
# fetched from a different source.
type
  ExtraData* = object
    inAmount*: float64
    outAmount*: float64

# Used to display an activity history header entry in the QML UI
QtObject:
  type
    ActivityEntry* = ref object of QObject
      metadata: backend.ActivityEntry
      extradata: ExtraData

      transactions: txid.Model

      amountCurrency: CurrencyAmount
      noAmount: CurrencyAmount

      nftName: string
      nftImageURL: string

      # true for entries that were changed/added in the current session
      highlight: bool

  proc setup(self: ActivityEntry) =
    self.QObject.setup

  proc delete*(self: ActivityEntry) =
    self.QObject.delete

  proc isInTransactionType(self: ActivityEntry): bool =
    return self.metadata.activityType == backend.ActivityType.Receive or self.metadata.activityType == backend.ActivityType.Mint

  proc extractCurrencyAmount(self: ActivityEntry, currencyService: Service): CurrencyAmount =
    let amount = if self.isInTransactionType(): self.metadata.amountIn else: self.metadata.amountOut
    let symbol = if self.isInTransactionType(): self.metadata.symbolIn.get("") else: self.metadata.symbolOut.get("")
    return currencyAmountToItem(
      currencyService.parseCurrencyValue(symbol, amount),
      currencyService.getCurrencyFormat(symbol),
    )

  proc newMultiTransactionActivityEntry*(metadata: backend.ActivityEntry, extradata: ExtraData, currencyService: Service): ActivityEntry =
    new(result, delete)
    result.metadata = metadata
    result.extradata = extradata

    result.transactions = txid.newModel()
    result.transactions.setItems(metadata.transactions)

    result.noAmount = newCurrencyAmount()
    result.amountCurrency = result.extractCurrencyAmount(currencyService)

    result.highlight = metadata.isNew

    result.setup()

  proc newTransactionActivityEntry*(metadata: backend.ActivityEntry, fromAddresses: seq[string], extradata: ExtraData, currencyService: Service): ActivityEntry =
    new(result, delete)
    result.metadata = metadata
    result.extradata = extradata
    result.transactions = txid.newModel()
    result.noAmount = newCurrencyAmount()

    result.amountCurrency = result.extractCurrencyAmount(currencyService)

    result.highlight = metadata.isNew

    result.setup()

  proc buildMultiTransactionExtraData(metadata: backend.ActivityEntry, currencyService: Service): ExtraData =
    if metadata.symbolIn.isSome():
      result.inAmount = currencyService.parseCurrencyValue(metadata.symbolIn.get(), metadata.amountIn)
    if metadata.symbolOut.isSome():
      result.outAmount = currencyService.parseCurrencyValue(metadata.symbolOut.get(), metadata.amountOut)

  proc buildTransactionExtraData(metadata: backend.ActivityEntry, currencyService: Service): ExtraData =
    if metadata.symbolIn.isSome() or metadata.amountIn > 0:
      result.inAmount = currencyService.parseCurrencyValue(metadata.symbolIn.get(""), metadata.amountIn)
    if metadata.symbolOut.isSome() or metadata.amountOut > 0:
      result.outAmount = currencyService.parseCurrencyValue(metadata.symbolOut.get(""), metadata.amountOut)

  proc buildExtraData(backendEntry: backend.ActivityEntry, currencyService: Service): ExtraData =
    var extraData: ExtraData
    case backendEntry.getPayloadType():
      of MultiTransaction:
        extraData = buildMultiTransactionExtraData(backendEntry, currencyService)
      of SimpleTransaction, PendingTransaction:
        extraData = buildTransactionExtraData(backendEntry, currencyService)
    return extraData

  proc newActivityEntry*(backendEntry: backend.ActivityEntry, addresses: seq[string], currencyService: Service): ActivityEntry =
    var ae: entry.ActivityEntry
    let extraData = buildExtraData(backendEntry, currencyService)
    case backendEntry.getPayloadType():
      of MultiTransaction:
        ae = newMultiTransactionActivityEntry(backendEntry, extraData, currencyService)
      of SimpleTransaction, PendingTransaction:
        ae = newTransactionActivityEntry(backendEntry, addresses, extraData, currencyService)
    return ae

  proc resetAmountCurrency*(self: ActivityEntry, service: Service) =
    self.extraData = buildExtraData(self.metadata, service)
    self.amountCurrency = self.extractCurrencyAmount(service)

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
      extradata:{$self.extradata},
      transactions:{$self.transactions},
    )"""

  # TODO: is this the right way to pass transaction identity? Why not use the instance?
  proc getId*(self: ActivityEntry): string {.slot.} =
    if self.isMultiTransaction():
      return $(self.metadata.getMultiTransactionId().get())
    return $(self.metadata.getTransactionIdentity().get().hash)

  QtProperty[string] id:
    read = getId

  proc getTransactions*(self: ActivityEntry): QVariant {.slot.} =
    return newQVariant(self.transactions)

  QtProperty[QVariant] transactions:
    read = getTransactions
  
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

  proc statusChanged*(self: ActivityEntry) {.signal.}

  proc getStatus*(self: ActivityEntry): int {.slot.} =
    return self.metadata.activityStatus.int

  proc setStatus*(self: ActivityEntry, status: ActivityStatus) =
    self.metadata.activityStatus = status
    self.statusChanged()

  QtProperty[int] status:
    read = getStatus
    notify = statusChanged

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
    if self.metadata.transferType.isNone():
      return false
    let transferType = self.metadata.transferType.unsafeGet()
    return transferType == TransferType.Erc721 or transferType == TransferType.Erc1155

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

  proc getCommunityId*(self: ActivityEntry): string {.slot.} =
    if self.metadata.communityId.isSome():
      return self.metadata.communityId.unsafeGet()
    return ""

  QtProperty[string] communityId:
    read = getCommunityId

  # TODO #15621: This should come from the backend, for now we use a workaround.
  # All Approvals triggered from the app will be to perform a swap on Paraswap
  proc getApprovalSpender*(self: ActivityEntry): string {.slot.} =
    if self.isMultiTransaction() and self.metadata.activityType == backend.ActivityType.Approve:
      return PARASWAP_V6_2_CONTRACT_ADDRESS
    return ""

  QtProperty[string] approvalSpender:
    read = getApprovalSpender
  
  # TODO #15621: This should come from the backend, for now we use a workaround.
  # This will only be used to determine the swap provider, which will be Paraswap for
  # all swaps triggered from the app.
  proc getInteractedContractAddress*(self: ActivityEntry): string {.slot.} =
    if self.isMultiTransaction() and 
    self.metadata.activityType == backend.ActivityType.Swap and
    self.getChainIdIn() == 0:   # Differentiate between Swaps triggered from the app and external detected Swaps
      return PARASWAP_V6_2_CONTRACT_ADDRESS
    return ""

  QtProperty[string] interactedContractAddress:
    read = getInteractedContractAddress

  proc highlightChanged*(self: ActivityEntry) {.signal.}

  proc getHighlight*(self: ActivityEntry): bool {.slot.} =
    return self.highlight

  proc doneHighlighting*(self: ActivityEntry) {.slot.} =
    if self.highlight:
      self.highlight = false
      self.highlightChanged()

  QtProperty[bool] highlight:
    read = getHighlight
    notify = highlightChanged
