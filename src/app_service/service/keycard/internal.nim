type
  KeyDetails* = object
    address*: string
    publicKey*: string
    privateKey*: string 

  ApplicationInfo* = object
    initialized*: bool
    instanceUID*: string
    version*: int
    availableSlots*: int
    keyUID*: string

  WalletAccount* = object
    path*: string
    address*: string

  CardMetadata* = object
    name*: string
    walletAccounts*: seq[WalletAccount]

  TransactionSignature* = object
    r*: string
    s*: string
    v*: string

  KeycardEvent* = object
    error*: string
    instanceUID*: string
    applicationInfo*: ApplicationInfo
    seedPhraseIndexes*: seq[int]
    freePairingSlots*: int
    keyUid*: string
    pinRetries*: int
    pukRetries*: int
    cardMetadata*: CardMetadata
    txSignature*: TransactionSignature
    eip1581Key*: KeyDetails
    encryptionKey*: KeyDetails
    masterKey*: KeyDetails
    walletKey*: KeyDetails
    walletRootKey*: KeyDetails
    whisperKey*: KeyDetails

proc toKeyDetails(jsonObj: JsonNode): KeyDetails =
  discard jsonObj.getProp(ResponseParamAddress, result.address)
  discard jsonObj.getProp(ResponseParamPrivateKey, result.privateKey)
  if jsonObj.getProp(ResponseParamPublicKey, result.publicKey):
    result.publicKey = "0x" & result.publicKey

proc toApplicationInfo(jsonObj: JsonNode): ApplicationInfo =
  discard jsonObj.getProp(ResponseParamInitialized, result.initialized)
  discard jsonObj.getProp(ResponseParamAppInfoInstanceUID, result.instanceUID)
  discard jsonObj.getProp(ResponseParamVersion, result.version)
  discard jsonObj.getProp(ResponseParamAvailableSlots, result.availableSlots)
  discard jsonObj.getProp(ResponseParamAppInfoKeyUID, result.keyUID)

proc toWalletAccount(jsonObj: JsonNode): WalletAccount =
  discard jsonObj.getProp(ResponseParamPath, result.path)
  discard jsonObj.getProp(ResponseParamAddress, result.address)

proc toCardMetadata(jsonObj: JsonNode): CardMetadata =
  discard jsonObj.getProp(ResponseParamName, result.name)
  var accountsArr: JsonNode
  if jsonObj.getProp(ResponseParamWallets, accountsArr) and accountsArr.kind == JArray:
    for acc in accountsArr:
      result.walletAccounts.add(acc.toWalletAccount())

proc toTransactionSignature(jsonObj: JsonNode): TransactionSignature =
  discard jsonObj.getProp(ResponseParamTxSignatureR, result.r)
  discard jsonObj.getProp(ResponseParamTxSignatureS, result.s)
  discard jsonObj.getProp(ResponseParamTxSignatureV, result.v)

proc toKeycardEvent(jsonObj: JsonNode): KeycardEvent =
  discard jsonObj.getProp(ResponseParamErrorKey, result.error)
  discard jsonObj.getProp(ResponseParamInstanceUID, result.instanceUID)
  discard jsonObj.getProp(ResponseParamFreeSlots, result.freePairingSlots)
  discard jsonObj.getProp(ResponseParamPINRetries, result.pinRetries)
  discard jsonObj.getProp(ResponseParamPUKRetries, result.pukRetries)
  if jsonObj.getProp(ResponseParamKeyUID, result.keyUid):
    result.keyUid = "0x" & result.keyUid

  var obj: JsonNode
  if(jsonObj.getProp(ResponseParamAppInfo, obj)):
    result.applicationInfo = toApplicationInfo(obj)

  if(jsonObj.getProp(ResponseParamEIP1581Key, obj)):
    result.eip1581Key = toKeyDetails(obj)

  if(jsonObj.getProp(ResponseParamEncKey, obj)):
    result.encryptionKey = toKeyDetails(obj)

  if(jsonObj.getProp(ResponseParamMasterKey, obj)):
    result.masterKey = toKeyDetails(obj)

  if(jsonObj.getProp(ResponseParamWalletKey, obj)):
    result.walletKey = toKeyDetails(obj)

  if(jsonObj.getProp(ResponseParamWalleRootKey, obj)):
    result.walletRootKey = toKeyDetails(obj)

  if(jsonObj.getProp(ResponseParamWhisperKey, obj)):
    result.whisperKey = toKeyDetails(obj)

  var indexesArr: JsonNode
  if jsonObj.getProp(ResponseParamMnemonicIdxs, indexesArr) and indexesArr.kind == JArray:
    for ind in indexesArr:
      result.seedPhraseIndexes.add(ind.getInt)

  if(jsonObj.getProp(ResponseParamCardMeta, obj)):
    result.cardMetadata = toCardMetadata(obj)

  if(jsonObj.getProp(ResponseParamTXSignature, obj)):
    result.txSignature = toTransactionSignature(obj)