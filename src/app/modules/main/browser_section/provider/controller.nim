import strutils
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/settings/service as settings_service
import ../../../../../app_service/service/provider/service as provider_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    settingsService: settings_service.Service
    providerService: provider_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  providerService: provider_service.Service
): Controller =
  result = Controller()
  result.events = events
  result.delegate = delegate
  result.settingsService = settingsService
  result.providerService = providerService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(PROVIDER_SIGNAL_ON_POST_MESSAGE) do(e:Args):
    let args = OnPostMessageArgs(e)
    self.delegate.onPostMessage(args.payloadMethod, args.result)

proc getDappsAddress*(self: Controller): string =
  return self.settingsService.getDappsAddress()

proc setDappsAddress*(self: Controller, address: string) =
  if self.settingsService.saveDappsAddress(address):
    self.delegate.onDappAddressChanged(address)

proc getCurrentNetworkId*(self: Controller): int =
  return self.settingsService.getCurrentNetworkId()

proc getCurrentNetwork*(self: Controller): string =
  return self.settingsService.getCurrentNetwork()

proc postMessage*(self: Controller, payloadMethod: string, requestType: string, message: string) =
  self.providerService.postMessage(payloadMethod, requestType, message)

proc ensResourceURL*(self: Controller, ens: string, url: string): (string, string, string, string, bool) =
  return self.providerService.ensResourceURL(ens, url)
