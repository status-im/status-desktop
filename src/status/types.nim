import json
import eventemitter

type SignalCallback* = proc(eventMessage: cstring): void {.cdecl.}

type SignalType* {.pure.} = enum
  Message = "messages.new"
  Wallet = "wallet"
  NodeStarted = "node.started"
  NodeLogin = "node.login"
  EnvelopeSent = "envelope.sent"
  EnvelopeExpired = "envelope.expired"
  MailserverRequestCompleted = "mailserver.request.completed"
  MailserverRequestExpired = "mailserver.request.expired"
  DiscoverSummary = "discover.summary"
  SubscriptionsData = "subscriptions.data"
  SubscriptionsError = "subscriptions.error"
  WhisperFilterAdded = "whisper.filter.added"
  Unknown

type
  GoString* = object
    str*: cstring
    length*: cint

type
  Account* = object of RootObj
    name*: string
    keyUid*: string
    photoPath*: string

type
  NodeAccount* = ref object of Account
    timestamp*: int
    keycardPairing*: string

type
  GeneratedAccount* = ref object of Account
    publicKey*: string
    address*: string
    id*: string
    mnemonic*: string
    derived*: JsonNode

proc toNodeAccount*(nodeAccount: JsonNode): NodeAccount =
  result = NodeAccount(
    name: nodeAccount["name"].getStr, 
    timestamp: nodeAccount["timestamp"].getInt,
    photoPath: nodeAccount["photo-path"].getStr,
    keycardPairing: nodeAccount["keycard-pairing"].getStr,
    keyUid: nodeAccount["key-uid"].getStr)

proc toNodeAccounts*(nodeAccounts: JsonNode): seq[NodeAccount] =
  result = newSeq[NodeAccount]()
  for v in nodeAccounts:
    result.add v.toNodeAccount

proc toGeneratedAccount*(generatedAccount: JsonNode): GeneratedAccount =
  generatedAccount["name"] = %*""
  generatedAccount["photoPath"] = %*""
  result = generatedAccount.to(GeneratedAccount)

proc toAccount*(generatedAccount: JsonNode): Account =
  result = Account(
    name: generatedAccount["name"].getStr,
    keyUid: generatedAccount{"key-uid"}.getStr,
    photoPath: generatedAccount["photo-path"].getStr)

proc toAccount*(generatedAccount: GeneratedAccount): Account =
  result = Account(
    name: generatedAccount.name,
    keyUid: generatedAccount.keyUid,
    photoPath: generatedAccount.photoPath)

type AccountArgs* = ref object of Args
    account*: Account