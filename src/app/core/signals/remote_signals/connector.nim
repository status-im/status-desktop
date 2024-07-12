import json, tables, chronicles
import base

include  app_service/common/json_utils

type ConnectorSendRequestAccountsSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  requestID*: string

type ConnectorSendTransactionSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  requestID*: string
  chainID*: int
  txArgs*: string

proc fromEvent*(T: type ConnectorSendRequestAccountsSignal, event: JsonNode): ConnectorSendRequestAccountsSignal =
  result = ConnectorSendRequestAccountsSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestID = event["event"]{"requestID"}.getStr()

proc fromEvent*(T: type ConnectorSendTransactionSignal, event: JsonNode): ConnectorSendTransactionSignal =
  result = ConnectorSendTransactionSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestID = event["event"]{"requestID"}.getStr()
  result.chainID = event["event"]{"chainID"}.getInt()
  result.txArgs = event["event"]{"txArgs"}.getStr()