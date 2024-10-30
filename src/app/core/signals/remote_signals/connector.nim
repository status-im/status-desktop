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

type ConnectorGrantDAppPermissionSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  chains*: string
  sharedAccount*: string

type ConnectorRevokeDAppPermissionSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string

proc fromEvent*(T: type ConnectorSendRequestAccountsSignal, event: JsonNode): ConnectorSendRequestAccountsSignal =
  result = ConnectorSendRequestAccountsSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestId = event["event"]{"requestId"}.getStr()

proc fromEvent*(T: type ConnectorSendTransactionSignal, event: JsonNode): ConnectorSendTransactionSignal =
  result = ConnectorSendTransactionSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestId = event["event"]{"requestId"}.getStr()
  result.chainId = event["event"]{"chainId"}.getInt()
  result.txArgs = event["event"]{"txArgs"}.getStr()

proc fromEvent*(T: type ConnectorGrantDAppPermissionSignal, event: JsonNode): ConnectorGrantDAppPermissionSignal =
  result = ConnectorGrantDAppPermissionSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.chains = $(event["event"]{"chains"})
  result.sharedAccount = event["event"]{"sharedAccount"}.getStr()

proc fromEvent*(T: type ConnectorRevokeDAppPermissionSignal, event: JsonNode): ConnectorRevokeDAppPermissionSignal =
  result = ConnectorRevokeDAppPermissionSignal()
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
