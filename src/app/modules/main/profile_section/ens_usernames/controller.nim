import Tables, chronicles
import controller_interface
import io_interface

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service_interface as settings_service
import ../../../../../app_service/service/ens/service as ens_service
import ../../../../../app_service/service/wallet_account/service_interface as wallet_account_service

export controller_interface

logScope:
  topics = "profile-section-ens-usernames-module-controller"

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.ServiceInterface
    ensService: ens_service.Service
    walletAccountService: wallet_account_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter, 
  settingsService: settings_service.ServiceInterface, ensService: ens_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.ensService = ensService
  result.walletAccountService = walletAccountService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED) do(e:Args):
    let args = EnsUsernameAvailabilityArgs(e)
    self.delegate.ensUsernameAvailabilityChecked(args.availabilityStatus)

  self.events.on(SIGNAL_ENS_USERNAME_DETAILS_FETCHED) do(e:Args):
    let args = EnsUsernameDetailsArgs(e)
    self.delegate.onDetailsForEnsUsername(args.ensUsername, args.address, args.pubkey, args.isStatus, args.expirationTime)

  self.events.on(SIGNAL_GAS_PRICE_FETCHED) do(e:Args):
    let args = GasPriceArgs(e)
    self.delegate.gasPriceFetched(args.gasPrice)

  self.events.on(SIGNAL_ENS_TRANSACTION_CONFIRMED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionConfirmed(args.transactionType, args.ensUsername, args.transactionHash)

  self.events.on(SIGNAL_ENS_TRANSACTION_REVERTED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionReverted(args.transactionType, args.ensUsername, args.transactionHash, args.revertReason)

method checkEnsUsernameAvailability*(self: Controller, desiredEnsUsername: string, statusDomain: bool) =
  self.ensService.checkEnsUsernameAvailability(desiredEnsUsername, statusDomain)

method getMyPendingEnsUsernames*(self: Controller): seq[string] =
  return self.ensService.getMyPendingEnsUsernames()

method getAllMyEnsUsernames*(self: Controller, includePendingEnsUsernames: bool): seq[string] =
  return self.ensService.getAllMyEnsUsernames(includePendingEnsUsernames)

method fetchDetailsForEnsUsername*(self: Controller, ensUsername: string) =
  self.ensService.fetchDetailsForEnsUsername(ensUsername)

method fetchGasPrice*(self: Controller) =
  self.ensService.fetchGasPrice()

method setPubKeyGasEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.setPubKeyGasEstimate(ensUsername, address)

method setPubKey*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string, 
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): string =
  return self.ensService.setPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method getCurrentNetworkDetails*(self: Controller): Network =
  return self.settingsService.getCurrentNetworkDetails()

method getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

method saveNewEnsUsername*(self: Controller, ensUsername: string): bool =
  return self.settingsService.saveNewEnsUsername(ensUsername)

method getPreferredEnsUsername*(self: Controller): string =
  return self.settingsService.getPreferredName()

method releaseEnsEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.releaseEnsEstimate(ensUsername, address)

method release*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string, password: string): 
  string =
  return self.ensService.release(ensUsername, address, gas, gasPrice, password)

method setPreferredName*(self: Controller, preferredName: string) =
  if(self.settingsService.savePreferredName(preferredName)):
    singletonInstance.userProfile.setPreferredName(preferredName)
  else:
    info "an error occurred saving prefered ens username", methodName="setPreferredName"

method getEnsRegisteredAddress*(self: Controller): string =
  return self.ensService.getEnsRegisteredAddress()

method registerEnsGasEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.registerEnsGasEstimate(ensUsername, address)

method registerEns*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string, 
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string): string =
  return self.ensService.registerEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password)

method getSNTBalance*(self: Controller): string =
  return self.ensService.getSNTBalance()

method getWalletDefaultAddress*(self: Controller): string =
  return self.walletAccountService.getWalletAccount(0).address

method getCurrentCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

method getPrice*(self: Controller, crypto: string, fiat: string): float64 =
  return self.walletAccountService.getPrice(crypto, fiat)

method getStatusToken*(self: Controller): string =
  return self.ensService.getStatusToken()

