import Tables, chronicles, json
import io_interface

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/ens/service as ens_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/token/dto

logScope:
  topics = "profile-section-ens-usernames-module-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    ensService: ens_service.Service
    networkService: network_service.Service
    walletAccountService: wallet_account_service.Service

proc newController*(
  delegate: io_interface.AccessInterface, events: EventEmitter,
  settingsService: settings_service.Service, ensService: ens_service.Service,
  walletAccountService: wallet_account_service.Service, networkService: network_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.settingsService = settingsService
  result.ensService = ensService
  result.walletAccountService = walletAccountService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_ENS_USERNAME_AVAILABILITY_CHECKED) do(e:Args):
    let args = EnsUsernameAvailabilityArgs(e)
    self.delegate.ensUsernameAvailabilityChecked(args.availabilityStatus)

  self.events.on(SIGNAL_ENS_USERNAME_DETAILS_FETCHED) do(e:Args):
    let args = EnsUsernameDetailsArgs(e)
    self.delegate.onDetailsForEnsUsername(args.ensUsername, args.address, args.pubkey, args.isStatus, args.expirationTime)

  self.events.on(SIGNAL_ENS_TRANSACTION_CONFIRMED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionConfirmed(args.transactionType, args.ensUsername, args.transactionHash)

  self.events.on(SIGNAL_ENS_TRANSACTION_REVERTED) do(e:Args):
    let args = EnsTransactionArgs(e)
    self.delegate.ensTransactionReverted(args.transactionType, args.ensUsername, args.transactionHash, args.revertReason)

proc checkEnsUsernameAvailability*(self: Controller, desiredEnsUsername: string, statusDomain: bool) =
  self.ensService.checkEnsUsernameAvailability(desiredEnsUsername, statusDomain)

proc getMyPendingEnsUsernames*(self: Controller): seq[string] =
  return self.ensService.getMyPendingEnsUsernames()

proc getAllMyEnsUsernames*(self: Controller, includePendingEnsUsernames: bool): seq[string] =
  return self.ensService.getAllMyEnsUsernames(includePendingEnsUsernames)

proc fetchDetailsForEnsUsername*(self: Controller, ensUsername: string) =
  self.ensService.fetchDetailsForEnsUsername(ensUsername)

proc setPubKeyGasEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.setPubKeyGasEstimate(ensUsername, address)

proc setPubKey*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): string =
  return self.ensService.setPubKey(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)

proc getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

proc saveNewEnsUsername*(self: Controller, ensUsername: string): bool =
  return self.settingsService.saveNewEnsUsername(ensUsername)

proc getPreferredEnsUsername*(self: Controller): string =
  return self.settingsService.getPreferredName()

proc releaseEnsEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.releaseEnsEstimate(ensUsername, address)

proc release*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string, password: string):
  string =
  return self.ensService.release(ensUsername, address, gas, gasPrice, password)

proc setPreferredName*(self: Controller, preferredName: string) =
  if(self.settingsService.savePreferredName(preferredName)):
    singletonInstance.userProfile.setPreferredName(preferredName)
  else:
    info "an error occurred saving prefered ens username", methodName="setPreferredName"

proc getEnsRegisteredAddress*(self: Controller): string =
  return self.ensService.getEnsRegisteredAddress()

proc registerEnsGasEstimate*(self: Controller, ensUsername: string, address: string): int =
  return self.ensService.registerEnsGasEstimate(ensUsername, address)

proc registerEns*(self: Controller, ensUsername: string, address: string, gas: string, gasPrice: string,
  maxPriorityFeePerGas: string, maxFeePerGas: string, password: string, eip1559Enabled: bool): string =
  return self.ensService.registerEns(ensUsername, address, gas, gasPrice, maxPriorityFeePerGas, maxFeePerGas, password, eip1559Enabled)

proc getSNTBalance*(self: Controller): string =
  return self.ensService.getSNTBalance()

proc getWalletDefaultAddress*(self: Controller): string =
  return self.walletAccountService.getWalletAccount(0).address

proc getCurrentCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

proc getPrice*(self: Controller, crypto: string, fiat: string): float64 =
  return self.walletAccountService.getPrice(crypto, fiat)

proc getStatusToken*(self: Controller): string =
  let token = self.ensService.getStatusToken()

  let jsonObj = %* {
    "name": token.name,
    "symbol": token.symbol,
    "address": token.addressAsString()
  }
  return $jsonObj

proc getNetwork*(self: Controller): NetworkDto =
  return self.networkService.getNetworkForEns()