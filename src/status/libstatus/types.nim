import eventemitter, json
import eth/common/eth_types, stew/byteutils, json_serialization, stint
import accounts/constants

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

type GasPricePrediction* = object
  safeLow*: string
  standard*: string
  fast*: string
  fastest*: string

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

type RpcError* = ref object
  code*: int
  message*: string

type
  RpcResponse* = ref object
    jsonrpc*: string
    result*: string
    id*: int
    error*: RpcError

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

type
  RpcException* = object of CatchableError

type Sticker* = object
  hash*: string
  packId*: int

type StickerPack* = object
  author*: string
  id*: int
  name*: string
  price*: Stuint[256]
  preview*: string
  stickers*: seq[Sticker]
  thumbnail*: string

proc `%`*(stuint256: Stuint[256]): JsonNode =
  newJString($stuint256)

proc `$`*(a: EthAddress): string =
  "0x" & a.toHex()

proc readValue*(reader: var JsonReader, value: var Stuint[256])
               {.raises: [IOError, SerializationError, Defect].} =
  try:
    let strVal = reader.readValue(string)
    value = strVal.parse(Stuint[256])
  except:
    try:
      let intVal = reader.readValue(int)
      value = intVal.stuint(256)
    except:
      raise newException(SerializationError, "Expected string or int representation of Stuint[256]")

type
  Network* {.pure.} = enum
    Mainnet,
    Testnet

  Setting* {.pure.} = enum
    Appearance = "appearance",
    Currency = "currency"
    EtherscanLink = "etherscan-link"
    InstallationId = "installation-id"
    Mnemonic = "mnemonic"
    Networks_Networks = "networks/networks"
    Networks_CurrentNetwork = "networks/current-network"
    NodeConfig = "node-config"
    PublicKey = "public-key"
    Stickers_PacksInstalled = "stickers/packs-installed"
    Stickers_Recent = "stickers/recent-stickers"
    WalletRootAddress = "wallet-root-address"
    LatestDerivedPath = "latest-derived-path"
    PreferredUsername = "preferred-name"
    Usernames = "usernames"

  UpstreamConfig* = ref object
    enabled* {.serializedFieldName("Enabled").}: bool
    url* {.serializedFieldName("URL").}: string

  NodeConfig* = ref object
    networkId* {.serializedFieldName("NetworkId").}: int
    dataDir* {.serializedFieldName("DataDir").}: string
    upstreamConfig* {.serializedFieldName("UpstreamConfig").}: UpstreamConfig

  NetworkDetails* = ref object
    id*: string
    name*: string
    etherscanLink* {.serializedFieldName("etherscan-link").}: string
    config*: NodeConfig
