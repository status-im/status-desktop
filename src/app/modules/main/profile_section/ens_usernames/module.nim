import NimQml, json, stint, sequtils, strutils, sugar, strformat, parseutils, chronicles

import io_interface
import ../io_interface as delegate_interface
import view, controller, model

import app/global/global_singleton
import app/core/eventemitter
import app_service/common/conversion as service_conversion
import app_service/common/utils as common_utils
import app_service/common/wallet_constants as common_wallet_constants
import app_service/service/settings/service as settings_service
import app_service/service/ens/service as ens_service
import app_service/service/network/service as network_service
import app_service/service/ens/utils as ens_utils
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/service as token_service
import app_service/service/keycard/service as keycard_service
import app_service/service/keycard/constants as keycard_constants
from app_service/service/transaction/dto import PendingTransactionTypeDto

export io_interface

logScope:
  topics = "profile-section-ens-usernames-module"

include app_service/common/json_utils

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
type TmpSendEnsTransactionDetails = object
  chainId: int
  ensUsername: string
  address: string
  addressPath: string
  gas: string
  gasPrice: string
  maxPriorityFeePerGas: string
  maxFeePerGas: string
  eip1559Enabled: bool
  txType: PendingTransactionTypeDto
  txData: JsonNode

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
  keycardService: keycard_service.Service
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, settingsService, ensService, walletAccountService,
    networkService, tokenService, keycardService)
  result.moduleLoaded = false
  result.events = events

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

proc clear(self: Module) =
  self.tmpSendEnsTransactionDetails = TmpSendEnsTransactionDetails()

proc finish(self: Module, chainId: int, txHash: string, error: string) =
  self.clear()
  self.view.emitTransactionWasSentSignal(chainId, txHash, error)

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

# At this moment we're somehow assume that we're sending from the default wallet address. Need to change that!
# This function provides a possibility to authenticate sending from any address, not only from the wallet default one.
proc authenticateKeypairThatContainsObservedAddress*(self: Module) =
  if self.tmpSendEnsTransactionDetails.address.len == 0:
    error "tehre is no set address"
    return
  let kp = self.controller.getKeypairByAccountAddress(self.tmpSendEnsTransactionDetails.address)
  if kp.migratedToKeycard():
    let accounts = kp.accounts.filter(acc => cmpIgnoreCase(acc.address, self.tmpSendEnsTransactionDetails.address) == 0)
    if accounts.len != 1:
      error "cannot resolve selected account to send from among known keypair accounts"
      return
    self.tmpSendEnsTransactionDetails.addressPath = accounts[0].path
    self.controller.authenticate(kp.keyUid)
  else:
    self.controller.authenticate()

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
  self.tmpSendEnsTransactionDetails.txType = PendingTransactionTypeDto.SetPubKey

  self.authenticateKeypairThatContainsObservedAddress()

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
  self.tmpSendEnsTransactionDetails.txType = PendingTransactionTypeDto.ReleaseENS

  self.authenticateKeypairThatContainsObservedAddress()

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
  self.tmpSendEnsTransactionDetails.txType = PendingTransactionTypeDto.RegisterENS

  self.authenticateKeypairThatContainsObservedAddress()

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

proc sendEnsTxWithSignatureAndWatch(self: Module, signature: string) =
  let response = self.controller.sendEnsTxWithSignatureAndWatch(
    self.tmpSendEnsTransactionDetails.txType,
    self.tmpSendEnsTransactionDetails.chainId,
    self.tmpSendEnsTransactionDetails.txData,
    self.tmpSendEnsTransactionDetails.ensUsername,
    signature
  )

  if not response.error.isEmptyOrWhitespace():
    error "sending ens tx failed", errMsg=response.error, methodName="sendEnsTxWithSignatureAndWatch"
    self.finish(chainId = 0, txHash =  "", error = response.error)
    return

  if self.tmpSendEnsTransactionDetails.txType == PendingTransactionTypeDto.SetPubKey:
    let item = Item(chainId: self.tmpSendEnsTransactionDetails.chainId,
                    ensUsername: self.tmpSendEnsTransactionDetails.ensUsername,
                    isPending: true)
    self.view.model().addItem(item)
  elif self.tmpSendEnsTransactionDetails.txType == PendingTransactionTypeDto.ReleaseENS:
    self.onEnsUsernameRemoved(self.tmpSendEnsTransactionDetails.chainId, self.tmpSendEnsTransactionDetails.ensUsername)
  elif self.tmpSendEnsTransactionDetails.txType == PendingTransactionTypeDto.RegisterENS:
    let ensUsername = self.formatUsername(self.tmpSendEnsTransactionDetails.ensUsername, true)
    let item = Item(chainId: self.tmpSendEnsTransactionDetails.chainId, ensUsername: ensUsername, isPending: true)
    self.controller.fixPreferredName()
    self.view.model().addItem(item)
  else:
    error "unknown ens action", methodName="sendEnsTxWithSignatureAndWatch"
    self.finish(chainId = 0, txHash =  "", error = "unknown ens action")
    return

  self.finish(response.chainId, response.txHash, response.error)

method onKeypairAuthenticated*(self: Module, password: string, pin: string) =
  if password.len == 0:
    self.finish(chainId = 0, txHash =  "", error = cancelledRequest)
    return

  let txDataJson = self.controller.prepareEnsTx(
    self.tmpSendEnsTransactionDetails.txType,
    self.tmpSendEnsTransactionDetails.chainId,
    self.tmpSendEnsTransactionDetails.ensUsername,
    self.tmpSendEnsTransactionDetails.address,
    self.tmpSendEnsTransactionDetails.gas,
    self.tmpSendEnsTransactionDetails.gasPrice,
    self.tmpSendEnsTransactionDetails.maxPriorityFeePerGas,
    self.tmpSendEnsTransactionDetails.maxFeePerGas,
    self.tmpSendEnsTransactionDetails.eip1559Enabled,
  )

  if txDataJson.isNil or
    txDataJson.kind != JsonNodeKind.JObject or
    not txDataJson.hasKey("txArgs") or
    not txDataJson.hasKey("messageToSign"):
      let errMsg = "unexpected response format preparing tx ens username"
      error "error", msg=errMsg, methodName="onKeypairAuthenticated"
      self.finish(chainId = 0, txHash =  "", error = errMsg)
      return

  var txToBeSigned = txDataJson["messageToSign"].getStr
  if txToBeSigned.len != common_wallet_constants.TX_HASH_LEN_WITH_PREFIX:
    let errMsg = "unexpected tx hash length"
    error "error", msg=errMsg, methodName="onKeypairAuthenticated"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return

  self.tmpSendEnsTransactionDetails.txData = txDataJson["txArgs"]

  if txDataJson.hasKey("signOnKeycard") and txDataJson["signOnKeycard"].getBool:
    if pin.len != PINLengthForStatusApp:
      let errMsg = "cannot proceed with keycard signing, unexpected pin"
      error "error", msg=errMsg, methodName="onKeypairAuthenticated"
      self.finish(chainId = 0, txHash =  "", error = errMsg)
      return
    var txForKcFlow = txToBeSigned
    if txForKcFlow.startsWith("0x"):
      txForKcFlow = txForKcFlow[2..^1]
    self.controller.runSignFlow(pin, self.tmpSendEnsTransactionDetails.addressPath, txForKcFlow)
    return

  var finalPassword = password
  if pin.len == 0:
    finalPassword = common_utils.hashPassword(password)

  let signature = self.controller.signEnsTxLocally(txToBeSigned, self.tmpSendEnsTransactionDetails.address, finalPassword)
  if signature.len == 0:
    let errMsg = "couldn't sign tx locally"
    error "error", msg=errMsg, methodName="onKeypairAuthenticated"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return

  self.sendEnsTxWithSignatureAndWatch(signature)

method onTransactionSigned*(self: Module, keycardFlowType: string, keycardEvent: KeycardEvent) =
  if keycardFlowType != keycard_constants.ResponseTypeValueKeycardFlowResult:
    let errMsg = "unexpected error while keycard signing transaction"
    error "error", msg=errMsg, methodName="onTransactionSigned"
    self.finish(chainId = 0, txHash =  "", error = errMsg)
    return
  let signature = "0x" & keycardEvent.txSignature.r & keycardEvent.txSignature.s & keycardEvent.txSignature.v
  self.sendEnsTxWithSignatureAndWatch(signature)