import json, chronicles
import stew/shims/strformat
include ../../../common/json_utils

type PaymentRequest* = object
  receiver*: string
  amount*: string
  symbol*: string
  chainId*: int

proc newPaymentRequest*(
    receiver: string, amount: string, symbol: string, chainId: int
): PaymentRequest =
  result =
    PaymentRequest(receiver: receiver, amount: amount, symbol: symbol, chainId: chainId)

proc toPaymentRequest*(jsonObj: JsonNode): PaymentRequest =
  result = PaymentRequest()
  discard jsonObj.getProp("receiver", result.receiver)
  discard jsonObj.getProp("amount", result.amount)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("chainId", result.chainId)

proc `%`*(self: PaymentRequest): JsonNode =
  return
    %*{
      "receiver": self.receiver,
      "amount": self.amount,
      "symbol": self.symbol,
      "chainId": self.chainId,
    }

proc `$`*(self: PaymentRequest): string =
  result =
    fmt"""PaymentRequest(
    receiver: {self.receiver},
    amount: {self.amount},
    symbol: {self.symbol},
    chainId: {self.chainId},
  )"""
