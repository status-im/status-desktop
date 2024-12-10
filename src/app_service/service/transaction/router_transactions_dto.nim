import json, stint

include  ../../common/json_utils

const
  TxStatusSending* = "Sending"
  TxStatusPending* = "Pending"
  TxStatusSuccess* = "Success"
  TxStatusFailed* = "Failed"

type
  ErrorResponse* = ref object
    details*: string
    code*: string
type
  SendDetailsDto* = ref object
    uuid*: string
    sendType*: int
    fromAddress*: string
    toAddress*: string
    fromToken*: string
    toToken*: string
    fromAmount*: UInt256 # total amount
    toAmount*: UInt256
    ownerTokenBeingSent*: bool
    errorResponse*: ErrorResponse
    username*: string
    publicKey*: string
    packId*: string

type
  SigningDetails* = ref object
    address*: string
    addressPath*: string
    keyUid*: string
    signOnKeycard*: bool
    hashes*: seq[string]

type
  RouterTransactionsForSigningDto* = ref object
    sendDetails*: SendDetailsDto
    signingDetails*: SigningDetails

type
  RouterSentTransaction* = ref object
    fromAddress*: string
    toAddress*: string
    fromChain*: int
    toChain*: int
    fromToken*: string
    toToken*: string
    amount*: UInt256 # amount sent
    amountIn*: UInt256 # amount that is "data" of tx (important for erc20 tokens)
    amountOut*: UInt256 # amount that will be received
    hash*: string
    approvalTx*: bool

type
  RouterSentTransactionsDto* = ref object
    sendDetails*: SendDetailsDto
    sentTransactions*: seq[RouterSentTransaction]

type
  TransactionStatusChange* = ref object
    status*: string
    hash*: string
    chainId*: int
    sendDetails*: SendDetailsDto
    sentTransactions*: seq[RouterSentTransaction]

proc toErrorResponse*(jsonObj: JsonNode): ErrorResponse =
  result = ErrorResponse()
  if jsonObj.contains("details"):
    result.details = jsonObj["details"].getStr
  if jsonObj.contains("code"):
    result.code = jsonObj["code"].getStr

proc toSendDetailsDto*(jsonObj: JsonNode): SendDetailsDto =
  result = SendDetailsDto()
  discard jsonObj.getProp("uuid", result.uuid)
  discard jsonObj.getProp("sendType", result.sendType)
  discard jsonObj.getProp("fromAddress", result.fromAddress)
  discard jsonObj.getProp("toAddress", result.toAddress)
  discard jsonObj.getProp("fromToken", result.fromToken)
  discard jsonObj.getProp("toToken", result.toToken)
  discard jsonObj.getProp("ownerTokenBeingSent", result.ownerTokenBeingSent)
  var tmpObj: JsonNode
  if jsonObj.getProp("fromAmount", tmpObj):
    result.fromAmount = stint.fromHex(UInt256, tmpObj.getStr)
  if jsonObj.getProp("toAmount", tmpObj):
    result.toAmount = stint.fromHex(UInt256, tmpObj.getStr)
  if jsonObj.getProp("errorResponse", tmpObj) and tmpObj.kind == JObject:
    result.errorResponse = toErrorResponse(tmpObj)
  discard jsonObj.getProp("username", result.username)
  discard jsonObj.getProp("publicKey", result.publicKey)
  if jsonObj.getProp("packId", tmpObj):
    let packId = stint.fromHex(UInt256, tmpObj.getStr)
    result.packId = $packId

proc toSigningDetails*(jsonObj: JsonNode): SigningDetails =
  result = SigningDetails()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("addressPath", result.addressPath)
  discard jsonObj.getProp("keyUid", result.keyUid)
  discard jsonObj.getProp("signOnKeycard", result.signOnKeycard)
  var tmpObj: JsonNode
  if jsonObj.getProp("hashes", tmpObj) and tmpObj.kind == JArray:
    for tx in tmpObj:
      result.hashes.add(tx.getStr)

proc toRouterTransactionsForSigningDto*(jsonObj: JsonNode): RouterTransactionsForSigningDto =
  result = RouterTransactionsForSigningDto()
  var tmpObj: JsonNode
  if jsonObj.getProp("sendDetails", tmpObj) and tmpObj.kind == JObject:
    result.sendDetails = toSendDetailsDto(tmpObj)
  if jsonObj.getProp("signingDetails", tmpObj) and tmpObj.kind == JObject:
    result.signingDetails = toSigningDetails(tmpObj)

proc toRouterSentTransaction*(jsonObj: JsonNode): RouterSentTransaction =
  result = RouterSentTransaction()
  discard jsonObj.getProp("fromAddress", result.fromAddress)
  discard jsonObj.getProp("toAddress", result.toAddress)
  discard jsonObj.getProp("fromChain", result.fromChain)
  discard jsonObj.getProp("toChain", result.toChain)
  discard jsonObj.getProp("fromToken", result.fromToken)
  discard jsonObj.getProp("toToken", result.toToken)
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("approvalTx", result.approvalTx)
  var tmpObj: JsonNode
  if jsonObj.getProp("amount", tmpObj):
    result.amount = stint.fromHex(UInt256, tmpObj.getStr)
  if jsonObj.getProp("amountIn", tmpObj):
    result.amountIn = stint.fromHex(UInt256, tmpObj.getStr)
  if jsonObj.getProp("amountOut", tmpObj):
    result.amountOut = stint.fromHex(UInt256, tmpObj.getStr)

proc toRouterSentTransactionsDto*(jsonObj: JsonNode): RouterSentTransactionsDto =
  result = RouterSentTransactionsDto()
  var tmpObj: JsonNode
  if jsonObj.getProp("sendDetails", tmpObj) and tmpObj.kind == JObject:
    result.sendDetails = toSendDetailsDto(tmpObj)
  if jsonObj.getProp("sentTransactions", tmpObj) and tmpObj.kind == JArray:
    for tx in tmpObj:
      result.sentTransactions.add(toRouterSentTransaction(tx))

proc toTransactionStatusChange*(jsonObj: JsonNode): TransactionStatusChange =
  result = TransactionStatusChange()
  discard jsonObj.getProp("status", result.status)
  discard jsonObj.getProp("hash", result.hash)
  discard jsonObj.getProp("chainId", result.chainId)
  var tmpObj: JsonNode
  if jsonObj.getProp("sendDetails", tmpObj) and tmpObj.kind == JObject:
    result.sendDetails = toSendDetailsDto(tmpObj)
  if jsonObj.getProp("sentTransactions", tmpObj) and tmpObj.kind == JArray:
    for tx in tmpObj:
      result.sentTransactions.add(toRouterSentTransaction(tx))