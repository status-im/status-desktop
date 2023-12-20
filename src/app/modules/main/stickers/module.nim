import NimQml, Tables, stint, sugar, sequtils, json, strutils, strformat, parseutils, chronicles
import ./io_interface, ./view, ./controller, ./item, ./models/sticker_pack_list
import ../io_interface as delegate_interface
import app/global/global_singleton
import app/core/eventemitter
import app_service/service/stickers/service as stickers_service
import app_service/service/settings/service as settings_service
import app_service/service/network/service as network_service
import app_service/common/conversion as service_conversion
import app_service/common/utils as common_utils
import app_service/common/wallet_constants as common_wallet_constants
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/service as token_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycard/constants as keycard_constants

export io_interface

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
type TmpBuyStickersTransactionDetails = object
  packId: string
  address: string
  addressPath: string
  gas: string
  gasPrice: string
  maxPriorityFeePerGas: string
  maxFeePerGas: string
  eip1559Enabled: bool
  txData: JsonNode

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    tmpBuyStickersTransactionDetails: TmpBuyStickersTransactionDetails

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  stickersService: stickers_service.Service,
  settingsService: settings_Service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
  keycardService: keycard_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, stickersService, settingsService, walletAccountService,
    networkService, tokenService, keycardService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("stickersModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

proc clear(self: Module) =
  self.tmpBuyStickersTransactionDetails = TmpBuyStickersTransactionDetails()

proc finish(self: Module, chainId: int, txHash: string, error: string) =
  self.clear()
  self.view.transactionWasSent(chainId, txHash, error)

method load*(self: Module) =
  self.controller.init()
  let signingPhrase = self.controller.getSigningPhrase()
  let stickerMarketAddress = self.controller.getStickerMarketAddress()
  self.view.load(signingphrase, stickerMarketAddress)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.stickersDidLoad()

method authenticateAndBuy*(self: Module, packId: string, address: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) =
  self.tmpBuyStickersTransactionDetails.packId = packId
  self.tmpBuyStickersTransactionDetails.address = address
  self.tmpBuyStickersTransactionDetails.gas = gas
  self.tmpBuyStickersTransactionDetails.gasPrice = gasPrice
  self.tmpBuyStickersTransactionDetails.maxPriorityFeePerGas = maxPriorityFeePerGas
  self.tmpBuyStickersTransactionDetails.maxFeePerGas = maxFeePerGas
  self.tmpBuyStickersTransactionDetails.eip1559Enabled = eip1559Enabled
  self.tmpBuyStickersTransactionDetails.txData = nil

  let kp = self.controller.getKeypairByAccountAddress(address)
  if kp.migratedToKeycard():
    let accounts = kp.accounts.filter(acc => cmpIgnoreCase(acc.address, address) == 0)
    if accounts.len != 1:
      error "cannot resolve selected account to send from among known keypair accounts"
      return
    self.tmpBuyStickersTransactionDetails.addressPath = accounts[0].path
    self.controller.authenticate(kp.keyUid)
  else:
    self.controller.authenticate()

proc sendBuyingStickersTxWithSignatureAndWatch(self: Module, signature: string) =
  if self.tmpBuyStickersTransactionDetails.txData.isNil:
    let errMsg = "unexpected error while sending buying stickers tx"
    error "error", msg=errMsg, methodName="sendBuyingStickersTxWithSignatureAndWatch"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return

  let response = self.controller.sendBuyingStickersTxWithSignatureAndWatch(
    self.getChainIdForStickers(),
    self.tmpBuyStickersTransactionDetails.txData,
    self.tmpBuyStickersTransactionDetails.packId,
    signature
  )

  if not response.error.isEmptyOrWhitespace():
    error "sending buying stickers tx failed", errMsg=response.error, methodName="sendBuyingStickersTxWithSignatureAndWatch"
    self.finish(chainId = 0, txHash =  "", error = response.error)
    return

  self.view.stickerPacks.updateStickerPackInList(self.tmpBuyStickersTransactionDetails.packId, installed = false, pending = true)
  self.finish(response.chainId, response.txHash, response.error)

method onKeypairAuthenticated*(self: Module, password: string, pin: string) =
  if password.len == 0:
    self.finish(chainId = 0, txHash =  "", error = cancelledRequest)
    return

  let chainId = self.getChainIdForStickers()
  let txDataJson = self.controller.prepareTxForBuyingStickers(
    chainId,
    self.tmpBuyStickersTransactionDetails.packId,
    self.tmpBuyStickersTransactionDetails.address,
    self.tmpBuyStickersTransactionDetails.gas,
    self.tmpBuyStickersTransactionDetails.gasPrice,
    self.tmpBuyStickersTransactionDetails.maxPriorityFeePerGas,
    self.tmpBuyStickersTransactionDetails.maxFeePerGas,
    self.tmpBuyStickersTransactionDetails.eip1559Enabled
  )

  if txDataJson.isNil or
    txDataJson.kind != JsonNodeKind.JObject or
    not txDataJson.hasKey("txArgs") or
    not txDataJson.hasKey("messageToSign"):
      let errMsg = "unexpected response format preparing tx for buying stickers"
      error "error", msg=errMsg, methodName="onKeypairAuthenticated"
      self.finish(chainId = 0, txHash =  "", error = errMsg)
      return

  var txToBeSigned = txDataJson["messageToSign"].getStr
  if txToBeSigned.len != common_wallet_constants.TX_HASH_LEN_WITH_PREFIX:
    let errMsg = "unexpected tx hash length"
    error "error", msg=errMsg, methodName="onKeypairAuthenticated"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return

  self.tmpBuyStickersTransactionDetails.txData = txDataJson["txArgs"]

  if txDataJson.hasKey("signOnKeycard") and txDataJson["signOnKeycard"].getBool:
    if pin.len != PINLengthForStatusApp:
      let errMsg = "cannot proceed with keycard signing, unexpected pin"
      error "error", msg=errMsg, methodName="onKeypairAuthenticated"
      self.finish(chainId = 0, txHash =  "", error = errMsg)
      return
    var txForKcFlow = txToBeSigned
    if txForKcFlow.startsWith("0x"):
      txForKcFlow = txForKcFlow[2..^1]
    self.controller.runSignFlow(pin, self.tmpBuyStickersTransactionDetails.addressPath, txForKcFlow)
    return

  var finalPassword = password
  if pin.len == 0:
    finalPassword = common_utils.hashPassword(password)

  let signature = self.controller.signBuyingStickersTxLocally(txToBeSigned, self.tmpBuyStickersTransactionDetails.address, finalPassword)
  if signature.len == 0:
    let errMsg = "couldn't sign tx locally"
    error "error", msg=errMsg, methodName="onKeypairAuthenticated"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return

  self.sendBuyingStickersTxWithSignatureAndWatch(signature)

method obtainMarketStickerPacks*(self: Module) =
  self.controller.obtainMarketStickerPacks()

method getNumInstalledStickerPacks*(self: Module): int =
  self.controller.getNumInstalledStickerPacks()

method installStickerPack*(self: Module, packId: string) =
  self.controller.installStickerPack(packId)

method onStickerPackInstalled*(self: Module, packId: string) =
  self.view.onStickerPackInstalled(packId)

method installedStickerPacksLoaded*(self: Module) =
  self.view.setInstalledStickerPacksLoaded(true)

method uninstallStickerPack*(self: Module, packId: string) =
  self.controller.uninstallStickerPack(packId)

method removeRecentStickers*(self: Module, packId: string) =
  self.controller.removeRecentStickers(packId)

method wei2Eth*(self: Module, price: Stuint[256]): string =
  self.controller.wei2Eth(price)

method sendSticker*(self: Module, channelId: string, replyTo: string, sticker: Item) =
  let stickerDto = StickerDto(hash: sticker.getHash, packId: sticker.getPackId)
  self.controller.sendSticker(
    channelId,
    replyTo,
    stickerDto,
    singletonInstance.userProfile.getPreferredName())

method estimate*(self: Module, packId: string, address: string, price: string, uuid: string) =
  self.controller.estimate(packId, address, price, uuid)

method addRecentStickerToList*(self: Module, sticker: StickerDto) =
  self.view.addRecentStickerToList(initItem(sticker.hash, sticker.packId, sticker.url))

method getRecentStickers*(self: Module) =
  self.controller.loadRecentStickers()

method getInstalledStickerPacks*(self: Module) =
  self.controller.loadInstalledStickerPacks()

method clearStickerPacks*(self: Module) =
  self.view.clearStickerPacks()

method clearStickers*(self: Module) =
  self.view.clearStickers()

method allPacksLoaded*(self: Module) =
  self.view.allPacksLoaded()

method allPacksLoadFailed*(self: Module) =
  self.view.allPacksLoadFailed()

method populateInstalledStickerPacks*(self: Module, stickers: Table[string, StickerPackDto]) =
  var stickerPackItems: seq[PackItem] = @[]
  for stickerPack in stickers.values:
    stickerPackItems.add(initPackItem(
      stickerPack.id,
      stickerPack.name,
      stickerPack.author,
      stickerPack.price,
      stickerPack.preview,
      stickerPack.stickers.map(s => initItem(s.hash, s.packId, s.url)),
      stickerPack.thumbnail
    ))
  self.view.populateInstalledStickerPacks(stickerPackItems)

method gasEstimateReturned*(self: Module, estimate: int, uuid: string) =
  self.view.gasEstimateReturned(estimate, uuid)

method addStickerPackToList*(self: Module, stickerPack: StickerPackDto, isInstalled: bool, isBought: bool, isPending: bool) =
  let stickerPackItem = initPackItem(
          stickerPack.id,
          stickerPack.name,
          stickerPack.author,
          stickerPack.price,
          stickerPack.preview,
          stickerPack.stickers.map(s => initItem(s.hash, s.packId, s.url)),
          stickerPack.thumbnail
        )
  self.view.addStickerPackToList(stickerPackItem, isInstalled, isBought, isPending)

method getSNTBalance*(self: Module): string =
  return self.controller.getSNTBalance()

method getWalletDefaultAddress*(self: Module): string =
  return self.controller.getWalletDefaultAddress()

method getCurrentCurrency*(self: Module): string =
  return self.controller.getCurrentCurrency()

method getFiatValue*(self: Module, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string =
  if (cryptoBalance == "" or cryptoSymbol == "" or fiatSymbol == ""):
    return "0.00"

  let price = self.controller.getPrice(cryptoSymbol, fiatSymbol)
  let value = parseFloat(cryptoBalance) * price
  return fmt"{value:.2f}"

method getGasEthValue*(self: Module, gweiValue: string, gasLimit: string): string {.slot.} =
  var gasLimitInt:int

  if(gasLimit.parseInt(gasLimitInt) == 0):
    echo "an error occurred parsing gas limit, methodName=getGasEthValue"
    return ""

  # The following check prevents app crash, cause we're trying to promote
  # gasLimitInt to unsigned 256 int, and this number must be a positive number,
  # because of overflow.
  var gwei = gweiValue.parseFloat()
  if (gwei < 0):
    gwei = 0

  if (gasLimitInt < 0):
    gasLimitInt = 0

  let weiValue = service_conversion.gwei2Wei(gwei) * gasLimitInt.u256
  let ethValue = service_conversion.wei2Eth(weiValue)
  return fmt"{ethValue}"

method getStatusToken*(self: Module): string =
  return self.controller.getStatusToken()

method getChainIdForStickers*(self: Module): int =
  return self.controller.getChainIdForStickers()

method stickerTransactionConfirmed*(self: Module, trxType: string, packID: string, transactionHash: string) =
  self.view.stickerPacks.updateStickerPackInList(packID, installed = true, pending = false)
  self.controller.installStickerPack(packID)
  self.view.emitTransactionCompletedSignal(true, transactionHash, packID, trxType)

method stickerTransactionReverted*(self: Module, trxType: string, packID: string, transactionHash: string) =
  self.view.stickerPacks.updateStickerPackInList(packID, installed = false, pending = false)
  self.view.emitTransactionCompletedSignal(false, transactionHash, packID, trxType)

method onTransactionSigned*(self: Module, keycardFlowType: string, keycardEvent: KeycardEvent) =
  if keycardFlowType != keycard_constants.ResponseTypeValueKeycardFlowResult:
    let errMsg = "unexpected error while keycard signing transaction"
    error "error", msg=errMsg, methodName="onTransactionSigned"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return
  let signature = "0x" & keycardEvent.txSignature.r & keycardEvent.txSignature.s & keycardEvent.txSignature.v
  self.sendBuyingStickersTxWithSignatureAndWatch(signature)