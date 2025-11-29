import json, chronicles
import stew/shims/strformat
include app_service/common/json_utils

type PaymentRequest* = object
    receiver*: string
    amount*: string
    tokenKey*: string
    symbol*: string

proc newPaymentRequest*(receiver: string, amount: string, tokenKey: string, symbol: string): PaymentRequest =
  result = PaymentRequest(receiver: receiver, amount: amount, tokenKey: tokenKey, symbol: symbol)

proc toPaymentRequest*(jsonObj: JsonNode): PaymentRequest =
  result = PaymentRequest()
  discard jsonObj.getProp("receiver", result.receiver)
  discard jsonObj.getProp("amount", result.amount)
  discard jsonObj.getProp("tokenKey", result.tokenKey)
  discard jsonObj.getProp("symbol", result.symbol)

proc `%`*(self: PaymentRequest): JsonNode =
  return %*{
    "receiver": self.receiver,
    "amount": self.amount,
    "tokenKey": self.tokenKey,
    "symbol": self.symbol
  }

proc `$`*(self: PaymentRequest): string =
  result = fmt"""PaymentRequest(
    receiver: {self.receiver},
    amount: {self.amount},
    tokenKey: {self.tokenKey},
    symbol: {self.symbol}
  )"""