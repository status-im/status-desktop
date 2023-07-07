import NimQml, json, stint, strutils, strformat, parseutils, chronicles

import io_interface
import ../io_interface as delegate_interface
import view, controller, model

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/common/conversion as service_conversion
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/ens/service as ens_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/ens/utils as ens_utils
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/token/service as token_service

export io_interface

logScope:
  topics = "profile-section-ens-usernames-module"

include ../../../../../app_service/common/json_utils

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
type TmpSendEnsTransactionDetails = object
  chainId: int
  ensUsername: string
  address: string
  gas: string
  gasPrice: string
  maxPriorityFeePerGas: string
  maxFeePerGas: string
  eip1559Enabled: bool
  isRegistration: bool
  isRelease: bool
  isSetPubKey: bool

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    tmpSendEnsTransactionDetails: TmpSendEnsTransactionDetails
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
  result.controller = controller.newController(result, events, settingsService, ensService, walletAccountService, networkService, tokenService)
  result.moduleLoaded = false
  result.events = events

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()

  let signingPhrase = self.controller.getSigningPhrase()
  let link = self.controller.getNetwork().blockExplorerUrl & "/tx/"
  self.view.load(link, signingPhrase)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.view.emitChainIdChanged()
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

method setPubKeyGasEstimate*(self: Module, chainId: int, ensUsername: string, address: string): int =
  return self.controller.setPubKeyGasEstimate(chainId, ensUsername, address)

method authenticateAndSetPubKey*(self: Module, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) =

  self.tmpSendEnsTransactionDetails.chainId = chainId
  self.tmpSendEnsTransactionDetails.ensUsername = ensUsername
  self.tmpSendEnsTransactionDetails.address = address
  self.tmpSendEnsTransactionDetails.gas = gas
  self.tmpSendEnsTransactionDetails.gasPrice = gasPrice
  self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas = maxPriorityFeePerGas
  self.tmpSendEnsTransactionDetails.maxFeePerGas = maxFeePerGas
  self.tmpSendEnsTransactionDetails.eip1559Enabled = eip1559Enabled
  self.tmpSendEnsTransactionDetails.isRegistration = false
  self.tmpSendEnsTransactionDetails.isRelease = false
  self.tmpSendEnsTransactionDetails.isSetPubKey = true

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

proc setPubKey*(self: Module, password: string) =
  let response = self.controller.setPubKey(
    self.tmpSendEnsTransactionDetails.chainId,
    self.tmpSendEnsTransactionDetails.ensUsername,
    self.tmpSendEnsTransactionDetails.address,
    self.tmpSendEnsTransactionDetails.gas,
    self.tmpSendEnsTransactionDetails.gasPrice,
    self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas,
    self.tmpSendEnsTransactionDetails.maxFeePerGas,
    password,
    self.tmpSendEnsTransactionDetails.eip1559Enabled
  )
  if(response.len == 0):
    info "expected response is empty", methodName="setPubKey"
    return

  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    info "expected response is not a json object", methodName="setPubKey"
    return

  var success: bool
  if(not responseObj.getProp("success", success)):
    info "remote call is not executed with success", methodName="setPubKey"

  var respResult: string
  if(responseObj.getProp("result", respResult)):
    let item = Item(chainId: self.tmpSendEnsTransactionDetails.chainId,
                    ensUsername: self.tmpSendEnsTransactionDetails.ensUsername,
                    isPending: true)
    self.view.model().addItem(item)
    self.view.emitTransactionWasSentSignal(response)

method releaseEnsEstimate*(self: Module, chainId: int, ensUsername: string, address: string): int =
  return self.controller.releaseEnsEstimate(chainId, ensUsername, address)

method authenticateAndReleaseEns*(self: Module, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) =

  self.tmpSendEnsTransactionDetails.chainId = chainId
  self.tmpSendEnsTransactionDetails.ensUsername = ensUsername
  self.tmpSendEnsTransactionDetails.address = address
  self.tmpSendEnsTransactionDetails.gas = gas
  self.tmpSendEnsTransactionDetails.gasPrice = gasPrice
  self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas = maxPriorityFeePerGas
  self.tmpSendEnsTransactionDetails.maxFeePerGas = maxFeePerGas
  self.tmpSendEnsTransactionDetails.eip1559Enabled = eip1559Enabled
  self.tmpSendEnsTransactionDetails.isRegistration = false
  self.tmpSendEnsTransactionDetails.isRelease = true
  self.tmpSendEnsTransactionDetails.isSetPubKey = false

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

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

proc releaseEns*(self: Module, password: string) =
  let response = self.controller.release(
    self.tmpSendEnsTransactionDetails.chainId,
    self.tmpSendEnsTransactionDetails.ensUsername,
    self.tmpSendEnsTransactionDetails.address,
    self.tmpSendEnsTransactionDetails.gas,
    self.tmpSendEnsTransactionDetails.gasPrice,
    self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas,
    self.tmpSendEnsTransactionDetails.maxFeePerGas,
    password,
    self.tmpSendEnsTransactionDetails.eip1559Enabled
  )

  if(response.len == 0):
    info "expected response is empty", methodName="release"
    return

  let responseObj = response.parseJson
  if(responseObj.kind != JObject):
    info "expected response is not a json object", methodName="release"
    return

  var success: bool
  if(not responseObj.getProp("success", success)):
    info "remote call is not executed with success", methodName="release"
    return

  var result: string
  if(responseObj.getProp("result", result)):
    self.onEnsUsernameRemoved(self.tmpSendEnsTransactionDetails.chainId, self.tmpSendEnsTransactionDetails.ensUsername)
    self.view.emitTransactionWasSentSignal(response)

proc formatUsername(self: Module, ensUsername: string, isStatus: bool): string =
  result = ensUsername
  if isStatus:
    result = ensUsername & ens_utils.STATUS_DOMAIN

method connectOwnedUsername*(self: Module, ensUsername: string, isStatus: bool) =
  let chainId = self.getChainIdForEns()
  var ensUsername = self.formatUsername(ensUsername, isStatus)
  if(not self.controller.addEnsUsername(chainId, ensUsername)):
    info "an error occurred saving ens username", methodName="connectOwnedUsername"
    return

  self.controller.fixPreferredName()
  self.view.model().addItem(Item(chainId: chainId, ensUsername: ensUsername, isPending: false))

method ensTransactionConfirmed*(self: Module, trxType: string, ensUsername: string, transactionHash: string) =
  let chainId = self.getChainIdForEns()
  self.controller.fixPreferredName()
  if(self.view.model().containsEnsUsername(chainId, ensUsername)):
    self.view.model().updatePendingStatus(chainId, ensUsername, false)
  else:
    self.view.model().addItem(Item(chainId: chainId, ensUsername: ensUsername, isPending: false))
  self.view.emitTransactionCompletedSignal(true, transactionHash, ensUsername, trxType)

method ensTransactionReverted*(self: Module, trxType: string, ensUsername: string, transactionHash: string) =
  let chainId = self.getChainIdForEns()
  self.view.model().removeItemByEnsUsername(chainId, ensUsername)
  self.view.emitTransactionCompletedSignal(false, transactionHash, ensUsername, trxType)

method getEnsRegisteredAddress*(self: Module): string =
  return self.controller.getEnsRegisteredAddress()

method registerEnsGasEstimate*(self: Module, chainId: int, ensUsername: string, address: string): int =
  return self.controller.registerEnsGasEstimate(chainId, ensUsername, address)

method authenticateAndRegisterEns*(self: Module, chainId: int, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool) =

  self.tmpSendEnsTransactionDetails.chainId = chainId
  self.tmpSendEnsTransactionDetails.ensUsername = ensUsername
  self.tmpSendEnsTransactionDetails.address = address
  self.tmpSendEnsTransactionDetails.gas = gas
  self.tmpSendEnsTransactionDetails.gasPrice = gasPrice
  self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas = maxPriorityFeePerGas
  self.tmpSendEnsTransactionDetails.maxFeePerGas = maxFeePerGas
  self.tmpSendEnsTransactionDetails.eip1559Enabled = eip1559Enabled
  self.tmpSendEnsTransactionDetails.isRegistration = true
  self.tmpSendEnsTransactionDetails.isRelease = false
  self.tmpSendEnsTransactionDetails.isSetPubKey = false

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

proc registerEns(self: Module, password: string) =
  let response = self.controller.registerEns(
    self.tmpSendEnsTransactionDetails.chainId,
    self.tmpSendEnsTransactionDetails.ensUsername,
    self.tmpSendEnsTransactionDetails.address,
    self.tmpSendEnsTransactionDetails.gas,
    self.tmpSendEnsTransactionDetails.gasPrice,
    self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas,
    self.tmpSendEnsTransactionDetails.maxFeePerGas,
    password,
    self.tmpSendEnsTransactionDetails.eip1559Enabled
  )

  let responseObj = response.parseJson
  if (responseObj.kind != JObject):
    info "expected response is not a json object", methodName="registerEns"
    return

  var respResult: string
  if(responseObj.getProp("result", respResult) and responseObj{"success"}.getBool == true):
    let ensUsername = self.formatUsername(self.tmpSendEnsTransactionDetails.ensUsername, true)
    let item = Item(chainId: self.tmpSendEnsTransactionDetails.chainId, ensUsername: ensUsername, isPending: true)
    self.controller.fixPreferredName()
    self.view.model().addItem(item)
  self.view.emitTransactionWasSentSignal(response)

method getSNTBalance*(self: Module): string =
  return self.controller.getSNTBalance()

method getWalletDefaultAddress*(self: Module): string =
  return self.controller.getWalletDefaultAddress()

method getCurrentCurrency*(self: Module): string =
  return self.controller.getCurrentCurrency()

method getFiatValue*(self: Module, cryptoBalance: string, cryptoSymbol: string, fiatSymbol: string): string =
  var floatCryptoBalance: float = 0
  try:
    floatCryptoBalance = parseFloat(cryptoBalance)
  except ValueError:
    return "0.00"

  if (cryptoBalance == "" or cryptoSymbol == "" or fiatSymbol == ""):
    return "0.00"

  let price = self.controller.getPrice(cryptoSymbol, fiatSymbol)
  let value = floatCryptoBalance * price
  return fmt"{value}"

method getCryptoValue*(self: Module, fiatAmount: string, cryptoSymbol: string, fiatSymbol: string): string =
  var fiatAmountBalance: float = 0
  try:
    fiatAmountBalance = parseFloat(fiatAmount)
  except ValueError:
    return "0.00"

  if (fiatAmount == "" or cryptoSymbol == "" or fiatSymbol == ""):
    return "0.00"

  let price = self.controller.getPrice(cryptoSymbol, fiatSymbol)
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

method getStatusToken*(self: Module): string =
  return self.controller.getStatusToken()

method getChainIdForEns*(self: Module): int =
  return self.controller.getChainId()

method setPrefferedEnsUsername*(self: Module, ensUsername: string) =
  self.controller.setPreferredName(ensUsername)

method onUserAuthenticated*(self: Module, password: string) =
  if password.len == 0:
    let response = %* {"success": false, "result": cancelledRequest}
    self.view.emitTransactionWasSentSignal($response)
  else:
    if self.tmpSendEnsTransactionDetails.isRegistration:
      self.registerEns(password)
    elif self.tmpSendEnsTransactionDetails.isRelease:
      self.releaseEns(password)
    elif self.tmpSendEnsTransactionDetails.isSetPubKey:
     self.setPubKey(password)

