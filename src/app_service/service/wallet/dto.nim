import Tables, json, stint, strutils

include  ../../common/json_utils

type CollectionTrait* = ref object
  min*, max*: float

type CollectionDto* = ref object
  name*, slug*, imageUrl*: string
  ownedAssetCount*: int
  trait*: Table[string, CollectionTrait]

type
  SavedAddressDto* = ref object of RootObj
    name*: string
    address*: string

type
  FavoriteDto* = ref object of RootObj
    name*: string
    address*: string

type
  TokenDto* = ref object of RootObj
    name*: string
    chainId*: int
    address*: Address
    symbol*: string
    decimals*: int
    hasIcon*: bool
    color*: string
    isCustom*: bool
    isVisible*: bool

type
  WalletTokenDto* = ref object of RootObj
    token*: TokenDto
    oraclePrice*: float64
    cryptoBalance*: string
    fiatBalance*: float64

type 
  AccountDto* = ref object of RootObj
    name*: string
    address*: string
    path*: string
    color*: string
    publicKey*: string
    walletType*: string
    isWallet*: bool
    isChat*: bool
    tokens*: seq[WalletTokenDto]
    emoji*: string

type
  TransactionDto* = ref object of RootObj
    id*: string
    typeValue*: string
    address*: string
    blockNumber*: string
    blockHash*: string
    contract*: string
    timestamp*: UInt256
    gasPrice*: string
    gasLimit*: string
    gasUsed*: string
    nonce*: string
    txStatus*: string
    value*: string
    fromAddress*: string
    to*: string

type
  WalletAccountDto* = ref object of RootObj
    account*: AccountDto
    collections*: Table[int, seq[CollectionDto]]
    tokens*: Table[int, seq[WalletTokenDto]]
    transactions*: Table[int, seq[TransactionDto]]
    fiatBalance*: float64

type 
  OnRampDto* = ref object of RootObj
    name*: string
    description*: string
    fees*: string
    logoUrl*: string
    siteUrl*: string
    hostname*: string
    params*: Table[string, string]

type 
  WalletDto* = ref object of RootObj
    accounts*: seq[WalletAccountDto]
    favorites: seq[FavoriteDto]
    onRamp: seq[OnRampDto]
    savedAddresses: Table[int, seq[SavedAddressDto]]
    tokens*: Table[int, seq[TokenDto]]
    customTokens*: seq[TokenDto]
    pendingTransactions*: Table[int, seq[TransactionDto]]
    
    currency*: string
    fiatBalance*: float64

proc getCollectionTraits*(jsonCollection: JsonNode): Table[string, CollectionTrait] =
    var traitList: Table[string, CollectionTrait] = initTable[string, CollectionTrait]()
    for key, value in jsonCollection{"traits"}:
      traitList[key] = CollectionTrait(min: value{"min"}.getFloat, max: value{"max"}.getFloat)
    return traitList

proc toCollectionDto*(jsonCollection: JsonNode): CollectionDto =
  return CollectionDto(
    name: jsonCollection{"name"}.getStr,
    slug: jsonCollection{"slug"}.getStr,
    imageUrl: jsonCollection{"image_url"}.getStr,
    ownedAssetCount: jsonCollection{"owned_asset_count"}.getInt,
    trait: getCollectionTraits(jsonCollection)
  )

proc toFavoriteDto*(jsonObj: JsonNode): FavoriteDto =
  result = FavoriteDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)

proc toOnRampDto*(jsonObj: JsonNode): OnRampDto =
  result = OnRampDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("fees", result.fees)
  discard jsonObj.getProp("logoUrl", result.logoUrl)
  discard jsonObj.getProp("siteUrl", result.siteUrl)
  discard jsonObj.getProp("hostname", result.hostname)

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)

proc toTokenDto*(jsonObj: JsonNode): TokenDto =
  result = TokenDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("color", result.color)

proc toTransactionDto*(jsonObj: JsonNode): TransactionDto =
  result = TransactionDto()
  result.timestamp = stint.fromHex(UInt256, jsonObj{"timestamp"}.getStr)
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("type", result.typeValue)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("contract", result.contract)
  discard jsonObj.getProp("blockNumber", result.blockNumber)
  discard jsonObj.getProp("blockHash", result.blockHash)
  discard jsonObj.getProp("gasPrice", result.gasPrice)
  discard jsonObj.getProp("gasLimit", result.gasLimit)
  discard jsonObj.getProp("gasUsed", result.gasUsed)
  discard jsonObj.getProp("nonce", result.nonce)
  discard jsonObj.getProp("txStatus", result.txStatus)
  discard jsonObj.getProp("value", result.value)
  discard jsonObj.getProp("from", result.fromAddress)
  discard jsonObj.getProp("to", result.to)

proc toWalletTokenDto*(jsonObj: JsonNode): WalletTokenDto =
  result = WalletTokenDto()
  result.token = jsonObj{"token"}.toTokenDto()

proc toWalletAccountDto*(jsonObj: JsonNode): WalletAccountDto =
  result = WalletAccountDto()
  result.account = AccountDto()
  discard jsonObj{"account"}.getProp("name", result.account.name)
  discard jsonObj{"account"}.getProp("address", result.account.address)
  discard jsonObj{"account"}.getProp("path", result.account.path)
  discard jsonObj{"account"}.getProp("color", result.account.color)
  discard jsonObj{"account"}.getProp("wallet", result.account.isWallet)
  discard jsonObj{"account"}.getProp("chat", result.account.isChat)
  discard jsonObj{"account"}.getProp("public-key", result.account.publicKey)
  discard jsonObj{"account"}.getProp("type", result.account.walletType)
  discard jsonObj{"account"}.getProp("emoji", result.account.emoji)

  for chainId in jsonObj{"tokens"}.keys:
    var tokens: seq[WalletTokenDto] = @[]
    for tokenObj in jsonObj{"tokens"}{chainId}.items:
      tokens.add(tokenObj.toWalletTokenDto())

    result.tokens[parseInt(chainId)] = tokens

  for chainId in jsonObj{"transactions"}.keys:
    if jsonObj{"transactions"}{chainId} == newJNull():
      continue

    var transactions: seq[TransactionDto] = @[]
    for transactionObj in jsonObj{"transactions"}{chainId}.items:
      transactions.add(transactionObj.toTransactionDto())

    result.transactions[parseInt(chainId)] = transactions

  for chainId in jsonObj{"collections"}.keys:
    if jsonObj{"collections"}{chainId} == newJNull():
      continue

    var collections: seq[CollectionDto] = @[]
    for collectionObj in jsonObj{"collections"}{chainId}.items:
      collections.add(collectionObj.toCollectionDto())

    result.collections[parseInt(chainId)] = collections

  discard jsonObj.getProp("fiatBalance", result.fiatBalance)

proc toWalletDto*(jsonObj: JsonNode): WalletDto =
  result = WalletDto()
  var accountArr: JsonNode
  if(jsonObj.getProp("accounts", accountArr) and accountArr.kind == JArray):
    for accountObj in accountArr:
      result.accounts.add(accountObj.toWalletAccountDto())

  var favoriteArr: JsonNode
  if(jsonObj.getProp("favorites", favoriteArr) and favoriteArr.kind == JArray):
    for favoriteObj in favoriteArr:
      result.favorites.add(favoriteObj.toFavoriteDto())

  var onRampArr: JsonNode
  if(jsonObj.getProp("onRamp", onRampArr) and onRampArr.kind == JArray):
    for onRampObj in onRampArr:
      result.onRamp.add(onRampObj.toOnRampDto())

  for chainId in jsonObj{"savedAddresses"}.keys:
    if jsonObj{"savedAddresses"}{chainId} == newJNull():
      continue

    var savedAddresses: seq[SavedAddressDto] = @[]
    for savedAddressObj in jsonObj{"savedAddresses"}{chainId}.items:
      savedAddresses.add(savedAddressObj.toSavedAddressDto())

    result.savedAddresses[parseInt(chainId)] = savedAddresses

  for chainId in jsonObj{"tokens"}.keys:
    var tokens: seq[TokenDto] = @[]
    for tokenObj in jsonObj{"tokens"}{chainId}.items:
      tokens.add(tokenObj.toTokenDto())

    result.tokens[parseInt(chainId)] = tokens

  var customTokenArr: JsonNode
  if(jsonObj.getProp("customTokens", customTokenArr) and customTokenArr.kind == JArray):
    for customTokenObj in customTokenArr:
      result.customTokens.add(customTokenObj.toTokenDto())

  for chainId in jsonObj{"pendingTransactions"}.keys:
    if jsonObj{"pendingTransactions"}{chainId} == newJNull():
      continue

    var pendingTransactions: seq[TransactionDto] = @[]
    for pendingTransactionObj in jsonObj{"pendingTransactions"}{chainId}.items:
      pendingTransactions.add(pendingTransactionObj.toTransactionDto())

    result.pendingTransactions[parseInt(chainId)] = pendingTransactions

  discard jsonObj.getProp("fiatBalance", result.fiatBalance)
  discard jsonObj.getProp("currency", result.currency)