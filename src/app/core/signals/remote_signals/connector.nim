import json, tables, chronicles
import base

include  app_service/common/json_utils

type ConnectorSendRequestAccountsSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  requestId*: string

type ConnectorSendTransactionSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  requestId*: string
  chainId*: int
  txArgs*: string

proc fromEvent*(T: type ConnectorSendRequestAccountsSignal, jsonSignal: JsonNode): ConnectorSendRequestAccountsSignal =
  result = ConnectorSendRequestAccountsSignal()
  result.url = jsonSignal["event"]{"url"}.getStr()
  result.name = jsonSignal["event"]{"name"}.getStr()
  result.iconUrl = jsonSignal["event"]{"iconUrl"}.getStr()
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()

proc fromEvent*(T: type ConnectorSendTransactionSignal, jsonSignal: JsonNode): ConnectorSendTransactionSignal =
  result = ConnectorSendTransactionSignal()
  result.url = jsonSignal["event"]{"url"}.getStr()
  result.name = jsonSignal["event"]{"name"}.getStr()
  result.iconUrl = jsonSignal["event"]{"iconUrl"}.getStr()
  result.requestId = jsonSignal["event"]{"requestId"}.getStr()
  result.chainId = jsonSignal["event"]{"chainId"}.getInt()
  result.txArgs = jsonSignal["event"]{"txArgs"}.getStr()