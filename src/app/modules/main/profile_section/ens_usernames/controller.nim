import Tables, uuids, chronicles, json
import io_interface

import app/global/global_singleton
import app/core/eventemitter
import app_service/service/settings/service as settings_service
import app_service/service/ens/service as ens_service
import app_service/service/network/service as network_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/token/service as token_service
import app_service/service/keycard/service as keycard_service
from app_service/service/transaction/dto import PendingTransactionTypeDto
import app/modules/shared_modules/keycard_popup/io_interface as keycard_shared_module

logScope:
  topics = "profile-section-ens-usernames-module-controller"

const UNIQUE_ENS_SECTION_TRANSACTION_MODULE_IDENTIFIER* = "EnsSection-TransactionModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    ensService: ens_service.Service
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service
    tokenService: token_service.Service
    keycardService: keycard_service.Service
    connectionKeycardResponse: UUID

proc newController*(
  delegate: io_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service, ensService: ens_service.Service,
  walletAccountService: wallet_account_service.Service, networkService: network_service.Service,
  tokenService: token_service.Service,
  keycardService: keycard_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.ensService = ensService
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.tokenService = tokenService
  result.keycardService = keycardService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED) do(e:Args):
    let args = EnsUsernameAvailabilityArgs(e)
    self.delegate.ensUsernameAvailabilityChecked(args.availabilityStatus)

  self.events.on(SIGNAL_ENS_USERNAME_DETAILS_FETCHED) do(e:Args):
    let args = EnsUsernameDetailsArgs(e)
    self.delegate.onDetailsForEnsUsername(args.chainId, args.ensUsername, args.address, args.pubkey, args.isStatus, args.expirationTime)

  self.events.on(SIGNAL_ENS_TRANSACTION_CONFIRMED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionConfirmed(args.transactionType, args.ensUsername, args.transactionHash)

  self.events.on(SIGNAL_ENS_TRANSACTION_REVERTED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionReverted(args.transactionType, args.ensUsername, args.transactionHash)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_ENS_SECTION_TRANSACTION_MODULE_IDENTIFIER:
      return
    self.delegate.onKeypairAuthenticated(args.password,  args.pin)

proc getChainId*(self: Controller): int =
  return self.networkService.getChainIdForEns()

proc getNetwork*(self: Controller): NetworkDto =
  return self.networkService.getNetworkForEns()

proc checkEnsUsernameAvailability*(self: Controller, desiredEnsUsername: string, statusDomain: bool) =
  self.ensService.checkEnsUsernameAvailability(desiredEnsUsername, statusDomain)

proc getMyPendingEnsUsernames*(self: Controller): seq[EnsUsernameDto] =
  return self.ensService.getMyPendingEnsUsernames()

proc getAllMyEnsUsernames*(self: Controller, includePendingEnsUsernames: bool): seq[EnsUsernameDto] =
  return self.ensService.getAllMyEnsUsernames(includePendingEnsUsernames)

proc fetchDetailsForEnsUsername*(self: Controller, chainId: int, ensUsername: string) =
  self.ensService.fetchDetailsForEnsUsername(chainId, ensUsername)

proc setPubKeyGasEstimate*(self: Controller, chainId: int, ensUsername: string, address: string): int =
  return self.ensService.setPubKeyGasEstimate(chainId, ensUsername, address)


proc getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

proc addEnsUsername*(self: Controller, chainId: int, ensUsername: string): bool =
  return self.ensService.add(chainId, ensUsername)

proc removeEnsUsername*(self: Controller, chainId: int, ensUsername: string): bool =
  return self.ensService.remove(chainId, ensUsername)

proc getPreferredEnsUsername*(self: Controller): string =
  return self.settingsService.getPreferredName()

proc releaseEnsEstimate*(self: Controller, chainId: int, ensUsername: string, address: string): int =
  return self.ensService.releaseEnsEstimate(chainId, ensUsername, address)


proc setPreferredName*(self: Controller, preferredName: string) =
  if(self.settingsService.savePreferredName(preferredName)):
    singletonInstance.userProfile.setPreferredName(preferredName)
  else:
    info "an error occurred saving prefered ens username", methodName="setPreferredName"

proc fixPreferredName*(self: Controller, ignoreCurrentValue: bool = false) =
  # TODO: Remove this workaround and make proper prefferedName-chainId database storage
  if (not ignoreCurrentValue and singletonInstance.userProfile.getPreferredName().len > 0):
    return
  let ensUsernames = self.getAllMyEnsUsernames(false)
  let currentChainId = self.getNetwork().chainId
  var firstEnsName = ""
  for ensUsername in ensUsernames:
    if ensUsername.chainId == currentChainId:
      firstEnsName = ensUsername.username
      break
  self.setPreferredName(firstEnsName)

proc getEnsRegisteredAddress*(self: Controller): string =
  return self.ensService.getEnsRegisteredAddress()

proc registerEnsGasEstimate*(self: Controller, chainId: int, ensUsername: string, address: string): int =
  return self.ensService.registerEnsGasEstimate(chainId, ensUsername, address)


proc getSNTBalance*(self: Controller): string =
  return self.ensService.getSNTBalance()

proc getWalletDefaultAddress*(self: Controller): string =
  return self.walletAccountService.getWalletAccount(0).address

proc getKeypairByAccountAddress*(self: Controller, address: string): KeypairDto =
  return self.walletAccountService.getKeypairByAccountAddress(address)

proc getCurrentCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

proc getPrice*(self: Controller, crypto: string, fiat: string): float64 =
  return self.tokenService.getTokenPrice(crypto, fiat)

proc getStatusToken*(self: Controller): string =
  let token = self.ensService.getStatusToken()

  if token == nil:
    return $ %*{}

  let jsonObj = %* {
    "name": token.name,
    "symbol": token.symbol,
    "address": token.address
  }
  return $jsonObj

proc authenticate*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_ENS_SECTION_TRANSACTION_MODULE_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc prepareEnsTx*(self: Controller, txType: PendingTransactionTypeDto, chainId: int, ensUsername: string,  address: string,
  gas: string, gasPrice: string, maxPriorityFeePerGas: string, maxFeePerGas: string, eip1559Enabled: bool): JsonNode =
  return self.ensService.prepareEnsTx(txType, chainId, ensUsername, address, gas, gasPrice, maxPriorityFeePerGas,
    maxFeePerGas, eip1559Enabled)

proc signEnsTxLocally*(self: Controller, data, account, hashedPasssword: string): string =
  return self.ensService.signEnsTxLocally(data, account, hashedPasssword)

proc sendEnsTxWithSignatureAndWatch*(self: Controller, txType: PendingTransactionTypeDto, chainId: int,
  txData: JsonNode, ensUsername: string, signature: string): EnsTxResultArgs =
  return self.ensService.sendEnsTxWithSignatureAndWatch(txType, chainId, txData, ensUsername, signature)

proc disconnectKeycardReponseSignal(self: Controller) =
  self.events.disconnect(self.connectionKeycardResponse)

proc connectKeycardReponseSignal(self: Controller) =
  self.connectionKeycardResponse = self.events.onWithUUID(SIGNAL_KEYCARD_RESPONSE) do(e: Args):
    let args = KeycardLibArgs(e)
    self.disconnectKeycardReponseSignal()
    let currentFlow = self.keycardService.getCurrentFlow()
    if currentFlow != KCSFlowType.Sign:
      self.delegate.onTransactionSigned("", KeycardEvent())
      return
    self.delegate.onTransactionSigned(args.flowType, args.flowEvent)

proc cancelCurrentFlow*(self: Controller) =
  self.keycardService.cancelCurrentFlow()

proc runSignFlow*(self: Controller, pin, bip44Path, txHash: string) =
  self.cancelCurrentFlow()
  self.connectKeycardReponseSignal()
  self.keycardService.startSignFlow(bip44Path, txHash, pin)