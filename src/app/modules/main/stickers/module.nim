import NimQml, Tables, stint, sugar, sequtils, json, strutils, strformat, parseutils, chronicles
import ./io_interface, ./view, ./controller, ./item, ./models/sticker_pack_list
import ../io_interface as delegate_interface
import ../../../global/global_singleton
import ../../../core/eventemitter
import ../../../../app_service/service/stickers/service as stickers_service
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/network/service as network_service
import ../../../../app_service/common/conversion as service_conversion
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/token/service as token_service

export io_interface

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
type TmpBuyStickersTransactionDetails = object
  packId: string
  address: string
  gas: string
  gasPrice: string
  maxPriorityFeePerGas: string
  maxFeePerGas: string
  eip1559Enabled: bool


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
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, stickersService, settingsService, walletAccountService, networkService, tokenService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("stickersModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

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

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

  ##################################
  ## Do Not Delete
  ##
  ## Once we start with signing a transactions we shold check if the address we want to send a transaction from is migrated
  ## or not. In case it's not we should just authenticate logged in user, otherwise we should use one of the keycards that
  ## address (key pair) is migrated to and sign the transaction using it.
  ##
  ## The code bellow is an example how we can achieve that in future, when we start with signing transactions.
  ##
  ## let acc = self.controller.getAccountByAddress(from_addr)
  ## if acc.isNil:
  ##   echo "error: selected account to send a transaction from is not known"
  ##   return
  ## let keyPair = self.controller.getKeycardsWithSameKeyUid(acc.keyUid)
  ## if keyPair.len == 0:
  ##   self.controller.authenticateUser()
  ## else:
  ##   self.controller.authenticateUser(acc.keyUid, acc.path)
  ##
  ##################################

method onUserAuthenticated*(self: Module, password: string) =
  if password.len == 0:
    let response = %* {"success": false, "error": cancelledRequest}
    self.view.transactionWasSent($response)
  else:
    let responseTuple = self.controller.buy(
      self.tmpBuyStickersTransactionDetails.packId,
      self.tmpBuyStickersTransactionDetails.address,
      self.tmpBuyStickersTransactionDetails.gas,
      self.tmpBuyStickersTransactionDetails.gasPrice,
      self.tmpBuyStickersTransactionDetails.maxPriorityFeePerGas,
      self.tmpBuyStickersTransactionDetails.maxFeePerGas,
      password,
      self.tmpBuyStickersTransactionDetails.eip1559Enabled
    )
    let response = responseTuple.response
    let success = responseTuple.success
    if success:
      self.view.stickerPacks.updateStickerPackInList(self.tmpBuyStickersTransactionDetails.packId, false, true)
    self.view.transactionWasSent($(%*{"success": success, "result": response}))

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
  self.view.stickerPacks.updateStickerPackInList(packID, true, false)
  self.controller.installStickerPack(packID)
  self.view.emitTransactionCompletedSignal(true, transactionHash, packID, trxType)

method stickerTransactionReverted*(self: Module, trxType: string, packID: string, transactionHash: string) =
  self.view.stickerPacks.updateStickerPackInList(packID, false, false)
  self.view.emitTransactionCompletedSignal(false, transactionHash, packID, trxType)
