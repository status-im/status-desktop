import NimQml, json, stint, strutils, stew/shims/strformat, parseutils, chronicles

import io_interface
import ../io_interface as delegate_interface
import view, controller, model

import app/core/eventemitter
import app_service/common/conversion as service_conversion
import app_service/service/settings/service as settings_service
import app_service/service/ens/service as ens_service
import app_service/service/network/service as network_service
import app_service/service/ens/utils as ens_utils
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/service as token_service
from app_service/service/transaction/dto import PendingTransactionTypeDto

export io_interface

logScope:
  topics = "profile-section-ens-usernames-module"

include app_service/common/json_utils

const cancelledRequest* = "cancelled"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    events: EventEmitter

proc newModule*(
  delegate: delegate_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service, ensService: ens_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, ensService, walletAccountService,
    networkService, tokenService)
  result.moduleLoaded = false
  result.events = events

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()

  let txLink = self.controller.getAppNetwork().blockExplorerUrl & EXPLORER_TX_PATH
  let addressLink = self.controller.getAppNetwork().blockExplorerUrl & EXPLORER_ADDRESS_PATH
  self.view.load(txLink, addressLink)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.controller.fixPreferredName(true)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  # add registered ens usernames
  let registeredEnsUsernames = self.controller.getAllMyEnsUsernames(includePendingEnsUsernames = false)
  for dto in registeredEnsUsernames:
    let item = Item(chainId: dto.chainId,
                    ensUsername: dto.username,
                    isPending: false)
    self.view.model().addItem(item)
  # add pending ens usernames
  let pendingEnsUsernames = self.controller.getMyPendingEnsUsernames()
  for dto in pendingEnsUsernames:
    let item = Item(chainId: dto.chainId,
                    ensUsername: dto.username,
                    isPending: true)
    self.view.model().addItem(item)

  self.moduleLoaded = true
  self.delegate.ensUsernamesModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method checkEnsUsernameAvailability*(self: Module, desiredEnsUsername: string, statusDomain: bool) =
  self.controller.checkEnsUsernameAvailability(desiredEnsUsername, statusDomain)

method ensUsernameAvailabilityChecked*(self: Module, availabilityStatus: string) =
  self.view.sendUsernameAvailabilityCheckedSignal(availabilityStatus)

method numOfPendingEnsUsernames*(self: Module): int =
  return self.controller.getMyPendingEnsUsernames().len

method fetchDetailsForEnsUsername*(self: Module, chainId: int, ensUsername: string) =
  self.controller.fetchDetailsForEnsUsername(chainId, ensUsername)

method onDetailsForEnsUsername*(self: Module, chainId: int, ensUsername: string, address: string, pubkey: string, isStatus: bool,
  expirationTime: int) =
  self.view.processObtainedEnsUsermesDetails(chainId, ensUsername, address, pubkey, isStatus, expirationTime)

proc onEnsUsernameRemoved(self: Module, chainId: int, ensUsername: string) =
  if (self.controller.getPreferredEnsUsername() == ensUsername):
    self.controller.fixPreferredName(true)
  self.view.model().removeItemByEnsUsername(chainId, ensUsername)

method removeEnsUsername*(self: Module, chainId: int, ensUsername: string): bool =
  if (not self.controller.removeEnsUsername(chainId, ensUsername)):
    info "an error occurred removing ens username", methodName="removeEnsUsername", ensUsername, chainId
    return false
  self.onEnsUsernameRemoved(chainId, ensUsername)
  return true

method connectOwnedUsername*(self: Module, ensUsername: string, isStatus: bool) =
  let chainId = self.controller.getAppNetwork().chainId
  let finalEnsUsername = ens_utils.addDomain(ensUsername)
  if(not self.controller.addEnsUsername(chainId, finalEnsUsername)):
    info "an error occurred saving ens username", methodName="connectOwnedUsername"
    return
  self.controller.fixPreferredName()
  self.view.model().addItem(Item(chainId: chainId, ensUsername: finalEnsUsername, isPending: false))

method ensTransactionSent*(self: Module, trxType: string, chainId: int, ensUsername: string, txHash: string, err: string) =
  var finalError = err
  defer:
    self.view.emitTransactionWasSentSignal(trxType, chainId, txHash, ensUsername, finalError)
  if (err.len != 0):
    error "sending ens tx failed", errMsg=err, methodName="ensTransactionSent"
    return
  let finalEnsUsername = ens_utils.addDomain(ensUsername)
  case trxType:
  of $SetPubKey:
    let item = Item(chainId: chainId, ensUsername: finalEnsUsername, isPending: true)
    self.view.model().addItem(item)
  of $ReleaseENS:
    self.onEnsUsernameRemoved(chainId, finalEnsUsername)
  of $RegisterENS:
    let item = Item(chainId: chainId, ensUsername: finalEnsUsername, isPending: true)
    self.controller.fixPreferredName()
    self.view.model().addItem(item)
  else:
    finalError = "unknown ens action"
    error "sending ens tx failed", errMsg=err, methodName="ensTransactionSent"

method ensTransactionConfirmed*(self: Module, trxType: string, ensUsername: string, transactionHash: string) =
  let chainId = self.controller.getAppNetwork().chainId
  self.controller.fixPreferredName()
  let finalEnsUsername = ens_utils.addDomain(ensUsername)
  if(self.view.model().containsEnsUsername(chainId, finalEnsUsername)):
    self.view.model().updatePendingStatus(chainId, finalEnsUsername, false)
  else:
    self.view.model().addItem(Item(chainId: chainId, ensUsername: finalEnsUsername, isPending: false))
  self.view.emitTransactionCompletedSignal(true, transactionHash, finalEnsUsername, trxType)

method ensTransactionReverted*(self: Module, trxType: string, ensUsername: string, transactionHash: string) =
  let chainId = self.controller.getAppNetwork().chainId
  let finalEnsUsername = ens_utils.addDomain(ensUsername)
  self.view.model().removeItemByEnsUsername(chainId, finalEnsUsername)
  self.view.emitTransactionCompletedSignal(false, transactionHash, finalEnsUsername, trxType)

method getEnsRegisteredAddress*(self: Module): string =
  return self.controller.getEnsRegisteredAddress()

method getWalletDefaultAddress*(self: Module): string =
  return self.controller.getWalletDefaultAddress()

method getCurrentCurrency*(self: Module): string =
  return self.controller.getCurrentCurrency()

method getFiatValue*(self: Module, cryptoBalance: string, cryptoSymbol: string): string =
  var floatCryptoBalance: float = 0
  try:
    floatCryptoBalance = parseFloat(cryptoBalance)
  except ValueError:
    return "0.00"

  if (cryptoBalance == "" or cryptoSymbol == ""):
    return "0.00"

  let price = self.controller.getPriceBySymbol(cryptoSymbol)
  let value = floatCryptoBalance * price
  return fmt"{value}"

method getCryptoValue*(self: Module, fiatAmount: string, cryptoSymbol: string): string =
  var fiatAmountBalance: float = 0
  try:
    fiatAmountBalance = parseFloat(fiatAmount)
  except ValueError:
    return "0.00"

  if (fiatAmount == "" or cryptoSymbol == ""):
    return "0.00"

  let price = self.controller.getPriceBySymbol(cryptoSymbol)
  let value = fiatAmountBalance / price
  return fmt"{value}"

method getGasEthValue*(self: Module, gweiValue: string, gasLimit: string): string {.slot.} =
  var gasLimitInt:int

  if(gasLimit.parseInt(gasLimitInt) == 0):
    info "an error occurred parsing gas limit", methodName="getGasEthValue"
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

method getStatusTokenKey*(self: Module): string =
  return self.controller.getStatusTokenKey()

method setPrefferedEnsUsername*(self: Module, ensUsername: string) =
  self.controller.setPreferredName(ensUsername)