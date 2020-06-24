import eventemitter, json_serialization
import accounts/constants

type SignalCallback* = proc(eventMessage: cstring): void {.cdecl.}

type SignalType* {.pure.} = enum
  Message = "messages.new"
  Wallet = "wallet"
  NodeReady = "node.ready"
  NodeStarted = "node.started"
  NodeStopped = "node.stopped"
  NodeLogin = "node.login"
  EnvelopeSent = "envelope.sent"
  EnvelopeExpired = "envelope.expired"
  MailserverRequestCompleted = "mailserver.request.completed"
  MailserverRequestExpired = "mailserver.request.expired"
  DiscoveryStarted = "discovery.started"
  DiscoveryStopped = "discovery.stopped"
  DiscoverySummary = "discovery.summary"
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
  Account* = ref object of RootObj
    name*: string
    keyUid* {.serializedFieldName("key-uid").}: string
    photoPath* {.serializedFieldName("photo-path").}: string

type
  NodeAccount* = ref object of Account
    timestamp*: int
    keycardPairing* {.serializedFieldName("keycard-pairing").}: string

type
  GeneratedAccount* = ref object
    publicKey*: string
    address*: string
    id*: string
    mnemonic*: string
    derived*: MultiAccounts
    # FIXME: should inherit from Account but multiAccountGenerateAndDeriveAddresses
    # response has a camel-cased properties like "publicKey" and "keyUid", so the
    # serializedFieldName pragma would need to be different
    name*: string
    keyUid*: string
    photoPath*: string

proc toAccount*(account: GeneratedAccount): Account =
  result = Account(name: account.name, photoPath: account.photoPath, keyUid: account.address)

proc toAccount*(account: NodeAccount): Account =
  result = Account(name: account.name, photoPath: account.photoPath, keyUid: account.keyUid)

type AccountArgs* = ref object of Args
    account*: Account

type
  StatusGoException* = object of CatchableError

type
  Transaction* = ref object
    typeValue*: string
    address*: string
    blockNumber*: string
    blockHash*: string
    contract*: string
    timestamp*: string
    gasPrice*: string
    gasLimit*: string
    gasUsed*: string
    nonce*: string
    txStatus*: string
    value*: string
    fromAddress*: string
    to*: string
