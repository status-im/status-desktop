import eventemitter
import json_serialization
import accounts/constants

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

type DerivedAccount* = object
  publicKey*: string
  address*: string

type MultiAccounts* = object
  whisper* {.serializedFieldName(PATH_WHISPER).}: DerivedAccount
  walletRoot* {.serializedFieldName(PATH_WALLET_ROOT).}: DerivedAccount
  defaultWallet* {.serializedFieldName(PATH_DEFAULT_WALLET).}: DerivedAccount
  eip1581* {.serializedFieldName(PATH_EIP_1581).}: DerivedAccount


type
  Account* = object of RootObj
    name*: string
    keyUid* {.serializedFieldName("key-uid").}: string
    photoPath* {.serializedFieldName("photo-path").}: string

type
  NodeAccount* = object
    timestamp*: int
    keycardPairing* {.serializedFieldName("keycard-pairing").}: string
    # deserialisation does not handle base classes, so flatten
    name*: string
    keyUid* {.serializedFieldName("key-uid").}: string
    photoPath* {.serializedFieldName("photo-path").}: string

type
  GeneratedAccount* = object
    publicKey*: string
    address*: string
    id*: string
    mnemonic*: string
    derived*: MultiAccounts
    # deserialisation does not handle base classes, so flatten
    name*: string
    keyUid*: string
    photoPath*: string

type AccountArgs* = ref object of Args
    account*: Account
