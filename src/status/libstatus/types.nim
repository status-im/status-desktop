import eventemitter, json, options, typetraits, strutils
import eth/common/eth_types, stew/byteutils, json_serialization, stint, faststreams/textio
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
    SigningPhrase = "signing-phrase"

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

  # TODO: Remove this when nim-web3 is added as a dependency
  Quantity* = distinct uint64

  # TODO: Remove this when nim-web3 is added as a dependency
  EthSend* = object
    source*: EthAddress             # the address the transaction is send from.
    to*: Option[EthAddress]         # (optional when creating new contract) the address the transaction is directed to.
    gas*: Option[Quantity]            # (optional, default: 90000) integer of the gas provided for the transaction execution. It will return unused gas.
    gasPrice*: Option[int]       # (optional, default: To-Be-Determined) integer of the gasPrice used for each paid gas.
    value*: Option[Uint256]          # (optional) integer of the value sent with this transaction.
    data*: string                # the compiled code of a contract OR the hash of the invoked method signature and encoded parameters. For details see Ethereum Contract ABI.
    nonce*: Option[int]        # (optional) integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce

# TODO: Remove this when nim-web3 is added as a dependency
template stripLeadingZeros(value: string): string =
  var cidx = 0
  # ignore the last character so we retain '0' on zero value
  while cidx < value.len - 1 and value[cidx] == '0':
    cidx.inc
  value[cidx .. ^1]

# TODO: Remove this when nim-web3 is added as a dependency
proc encodeQuantity*(value: SomeUnsignedInt): string =
  var hValue = value.toHex.stripLeadingZeros
  result = "0x" & hValue

# TODO: Remove this when nim-web3 is added as a dependency
proc `%`*(v: EthAddress): JsonNode =
  result = %("0x" & array[20, byte](v).toHex)

# TODO: Remove this when nim-web3 is added as a dependency
proc `%`*(v: Quantity): JsonNode =
  result = %encodeQuantity(v.uint64)

# TODO: Remove this when nim-web3 is added as a dependency
proc `%`*(n: Int256|UInt256): JsonNode = %("0x" & n.toHex)

# TODO: Remove this when nim-web3 is added as a dependency
proc `%`*(x: EthSend): JsonNode =
  result = newJobject()
  result["from"] = %x.source
  if x.to.isSome:
    result["to"] = %x.to.unsafeGet
  if x.gas.isSome:
    result["gas"] = %x.gas.unsafeGet
  if x.gasPrice.isSome:
    result["gasPrice"] = %("0x" & x.gasPrice.unsafeGet.toHex.stripLeadingZeros)
  if x.value.isSome:
    result["value"] = %("0x" & x.value.unsafeGet.toHex)
  result["data"] = %x.data
  if x.nonce.isSome:
    result["nonce"] = %x.nonce.unsafeGet