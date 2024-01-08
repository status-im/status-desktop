import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/provider/service as provider_service
import ../../../../../app_service/service/wallet_account/service
import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module

const UNIQUE_BROWSER_SECTION_TRANSACTION_MODULE_IDENTIFIER* = "BrowserSection-TransactionModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    networkService: network_service.Service
    providerService: provider_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  networkService: network_service.Service,
  providerService: provider_service.Service,
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.settingsService = settingsService
  result.networkService = networkService
  result.providerService = providerService

proc delete*(self: Controller) =
  discard

proc getAppNetwork*(self: Controller): NetworkDto =
  return self.networkService.getAppNetwork()

proc init*(self: Controller) =
  self.events.on(PROVIDER_SIGNAL_ON_POST_MESSAGE) do(e:Args):
    let args = OnPostMessageArgs(e)
    self.delegate.onPostMessage(args.payloadMethod, args.result, args.chainId)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.delegate.updateNetwork(self.getAppNetwork())

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_BROWSER_SECTION_TRANSACTION_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.password)

proc getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

proc setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.saveDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

proc postMessage*(self: Controller, payloadMethod: string, requestType: string, message: string) =
  self.providerService.postMessage(payloadMethod, requestType, message)

proc ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_BROWSER_SECTION_TRANSACTION_MODULE_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)
