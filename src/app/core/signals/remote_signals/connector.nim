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

type ConnectorSignSignal* = ref object of Signal
  url*: string
  name*: string
  iconUrl*: string
  requestId*: string
  challenge*: string
  address*: string
  signMethod*: string

type ConnectorDAppChainIdSwitchedSignal* = ref object of Signal
  url*: string
  chainId*: string

type ConnectorAccountChangedSignal* = ref object of Signal
  url*: string
  clientId*: string
  sharedAccount*: string

proc fromEvent*(T: type ConnectorSendRequestAccountsSignal, event: JsonNode): ConnectorSendRequestAccountsSignal =
  result = ConnectorSendRequestAccountsSignal()
  result.signalType = SignalType.ConnectorSendRequestAccounts
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestId = event["event"]{"requestId"}.getStr()

proc fromEvent*(T: type ConnectorSendTransactionSignal, event: JsonNode): ConnectorSendTransactionSignal =
  result = ConnectorSendTransactionSignal()
  result.signalType = SignalType.ConnectorSendTransaction
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestId = event["event"]{"requestId"}.getStr()
  result.chainId = event["event"]{"chainId"}.getInt()
  result.txArgs = event["event"]{"txArgs"}.getStr()

proc fromEvent*(T: type ConnectorGrantDAppPermissionSignal, event: JsonNode): ConnectorGrantDAppPermissionSignal =
  result = ConnectorGrantDAppPermissionSignal()
  result.signalType = SignalType.ConnectorGrantDAppPermission
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.chains = $(event["event"]{"chains"})
  result.sharedAccount = event["event"]{"sharedAccount"}.getStr()

proc fromEvent*(T: type ConnectorRevokeDAppPermissionSignal, event: JsonNode): ConnectorRevokeDAppPermissionSignal =
  result = ConnectorRevokeDAppPermissionSignal()
  result.signalType = SignalType.ConnectorRevokeDAppPermission
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()

proc fromEvent*(T: type ConnectorSignSignal, event: JsonNode): ConnectorSignSignal =
  result = ConnectorSignSignal()
  result.signalType = SignalType.ConnectorSign
  result.url = event["event"]{"url"}.getStr()
  result.name = event["event"]{"name"}.getStr()
  result.iconUrl = event["event"]{"iconUrl"}.getStr()
  result.requestId = event["event"]{"requestId"}.getStr()
  result.challenge = event["event"]{"challenge"}.getStr()
  result.address = event["event"]{"address"}.getStr()
  result.signMethod = event["event"]{"method"}.getStr()

proc fromEvent*(T: type ConnectorDAppChainIdSwitchedSignal, event: JsonNode): ConnectorDAppChainIdSwitchedSignal =
  result = ConnectorDAppChainIdSwitchedSignal()
  result.signalType = SignalType.ConnectorDAppChainIdSwitched
  result.url = event["event"]{"url"}.getStr()
  result.chainId = event["event"]{"chainId"}.getStr()

proc fromEvent*(T: type ConnectorAccountChangedSignal, event: JsonNode): ConnectorAccountChangedSignal =
  result = ConnectorAccountChangedSignal()
  result.signalType = SignalType.ConnectorAccountChanged
  result.url = event["event"]{"url"}.getStr()
  result.clientId = event["event"]{"clientId"}.getStr()
  result.sharedAccount = event["event"]{"sharedAccount"}.getStr()