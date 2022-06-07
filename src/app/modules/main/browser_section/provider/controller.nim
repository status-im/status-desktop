import strutils
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/provider/service as provider_service
import ../../../../../app_service/service/wallet_account/service

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

proc getNetwork*(self: Controller): NetworkDto =
  return self.networkService.getNetworkForBrowser()

proc init*(self: Controller) =
  self.events.on(PROVIDER_SIGNAL_ON_POST_MESSAGE) do(e:Args):
    let args = OnPostMessageArgs(e)
    self.delegate.onPostMessage(args.payloadMethod, args.result)

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e: Args):
    self.delegate.updateNetwork(self.getNetwork())

proc getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

proc setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.saveDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

proc postMessage*(self: Controller, payloadMethod: string, requestType: string, message: string) =
  self.providerService.postMessage(payloadMethod, requestType, message)

proc ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)
