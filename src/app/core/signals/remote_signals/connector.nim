import json, tables, chronicles
import base

include  app_service/common/json_utils

type ConnectorSendRequestAccountsSignal* = ref object of Signal
  dAppUrl*: string
  dAppName*: string
  dAppIconUrl*: string

type ConnectorSendTransactionSignal* = ref object of Signal
  dAppUrl*: string
  chainID*: int
  txArgsJson: string

proc fromEvent*(T: type ConnectorSendRequestAccountsSignal, event: JsonNode): ConnectorSendRequestAccountsSignal =
  result = ConnectorSendRequestAccountsSignal()
  result.dAppUrl = event["event"]{"dAppUrl"}.getStr()
  result.dAppName = event["event"]{"dAppName"}.getStr()
  result.dAppIconUrl = event["event"]{"dAppIconUrl"}.getStr()
  echo "--------> ConnectorSendRequestAccountsSignal: ", result.dAppUrl, " ", result.dAppName, " ", result.dAppIconUrl

proc fromEvent*(T: type ConnectorSendTransactionSignal, event: JsonNode): ConnectorSendTransactionSignal =
  result = ConnectorSendTransactionSignal()
  result.dAppUrl = event["event"]{"dAppUrl"}.getStr()
  result.chainID = event["event"]{"chainID"}.getInt()
  result.txArgsJson = event["event"]{"txArgsJson"}.getStr()
  echo "--------> ConnectorSendTransactionSignal: ", result.dAppUrl, " ", result.chainID, " ", result.txArgsJson
