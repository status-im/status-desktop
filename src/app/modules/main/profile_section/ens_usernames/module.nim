import NimQml, json, stint, strutils, strformat, parseutils, chronicles

import io_interface
import ../io_interface as delegate_interface
import view, controller, model

import ../../../../core/eventemitter
import ../../../../../app_service/common/conversion as service_conversion
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/ens/service as ens_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/ens/utils as ens_utils
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

logScope:
  topics = "profile-section-ens-usernames-module"

include ../../../../../app_service/common/json_utils

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service, ensService: ens_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, ensService, walletAccountService, networkService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()

  let signingPhrase = self.controller.getSigningPhrase()
  let link = self.controller.getNetwork().blockExplorerUrl & "/tx/"
  self.view.load(link, signingPhrase)

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  # add registered ens usernames
  let registeredEnsUsernames = self.controller.getAllMyEnsUsernames(includePendingEnsUsernames = false)
  for u in registeredEnsUsernames:
    self.view.model().addItem(Item(ensUsername: u, isPending: false))
  # add pending ens usernames
  let pendingEnsUsernames = self.controller.getMyPendingEnsUsernames()
  for u in pendingEnsUsernames:
    self.view.model().addItem(Item(ensUsername: u, isPending: true))

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

method fetchDetailsForEnsUsername*(self: Module, ensUsername: string) =
  self.controller.fetchDetailsForEnsUsername(ensUsername)

method onDetailsForEnsUsername*(self: Module, ensUsername: string, address: string, pubkey: string, isStatus: bool,
  expirationTime: int) =
  self.view.setDetailsForEnsUsername(ensUsername, address, pubkey, isStatus, expirationTime)

method setPubKeyGasEstimate*(self: Module, ensUsername: string, address: string): int =
  return self.controller.setPubKeyGasEstimate(ensUsername, address)

method setPubKey*(self: Module, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): string =
  let response = self.controller.setPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)
  if(response.len == 0):
    info "expected response is empty", methodName="setPubKey"
    return

  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    info "expected response is not a json object", methodName="setPubKey"
    return

  var success: bool
  if(not responseObj.getProp("success", success) or not success):
    info "remote call is not executed with success", methodName="setPubKey"
    return response
  
  var respResult: string
  if(responseObj.getProp("result", respResult)):
    self.view.model().addItem(Item(ensUsername: ensUsername, isPending: true))
    self.view.emitTransactionWasSentSignal(respResult)

  return response

method releaseEnsEstimate*(self: Module, ensUsername: string, address: string): int =
  return self.controller.releaseEnsEstimate(ensUsername, address)

method release*(self: Module, ensUsername: string, address: string, gas: string, gasPrice: string, password: string): string =
  let response = self.controller.release(ensUsername, address, gas, gasPrice, password)
  if(response.len == 0):
    info "expected response is empty", methodName="release"
    return

  let responseObj = response.parseJson
  if(responseObj.kind != JObject):
    info "expected response is not a json object", methodName="release"
    return

  var success: bool
  if(not responseObj.getProp("success", success) or not success):
    info "remote call is not executed with success", methodName="release"
    return

  var result: string
  if(responseObj.getProp("result", result)):
    self.controller.setPreferredName("")
    self.view.model().removeItemByEnsUsername(ensUsername)
    self.view.emitTransactionWasSentSignal(result)

  return response

proc formatUsername(self: Module, ensUsername: string, isStatus: bool): string =
  result = ensUsername
  if isStatus:
    result = ensUsername & ens_utils.STATUS_DOMAIN

method connectOwnedUsername*(self: Module, ensUsername: string, isStatus: bool) =
  var ensUsername = self.formatUsername(ensUsername, isStatus)
  if(not self.controller.saveNewEnsUsername(ensUsername)):
    info "an error occurred saving ens username", methodName="connectOwnedUsername"
    return

  self.controller.setPreferredName(ensUsername)
  self.view.model().addItem(Item(ensUsername: ensUsername, isPending: false))

method ensTransactionConfirmed*(self: Module, trxType: string, ensUsername: string, transactionHash: string) =
  if(not self.controller.saveNewEnsUsername(ensUsername)):
    info "an error occurred saving ens username", methodName="ensTransactionConfirmed"
    return

  if(self.view.model().containsEnsUsername(ensUsername)):
    self.view.model().updatePendingStatus(ensUsername, false)
  else:
    self.view.model().addItem(Item(ensUsername: ensUsername, isPending: false))
  self.view.emitTransactionCompletedSignal(true, transactionHash, ensUsername, trxType, "")

method ensTransactionReverted*(self: Module, trxType: string, ensUsername: string, transactionHash: string,
  revertReason: string) =
  self.view.model().removeItemByEnsUsername(ensUsername)
  self.view.emitTransactionCompletedSignal(false, transactionHash, ensUsername, trxType, revertReason)

method getEnsRegisteredAddress*(self: Module): string =
  return self.controller.getEnsRegisteredAddress()

method registerEnsGasEstimate*(self: Module, ensUsername: string, address: string): int =
  return self.controller.registerEnsGasEstimate(ensUsername, address)

method registerEns*(self: Module, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): string =
  let response = self.controller.registerEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)

  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    info "expected response is not a json object", methodName="registerEns"
    return

  var respResult: string
  if(responseObj.getProp("result", respResult) and responseObj{"success"}.getBool == true):
    self.view.model().addItem(Item(ensUsername: ensUsername, isPending: true))
    self.view.emitTransactionWasSentSignal(respResult)

  return response

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

method getStatusToken*(self: Module): string =
  return self.controller.getStatusToken()

method getChainIdForEns*(self: Module): int =
  return self.controller.getNetwork().chainId

method setPrefferedEnsUsername*(self: Module, ensUsername: string) =
  self.controller.setPreferredName(ensUsername)
