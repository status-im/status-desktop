import io_interface

import app_service/service/ramp/service as ramp_service
import app_service/service/ramp/dto
import ../../../../core/eventemitter

type Controller* = ref object of RootObj
  delegate: io_interface.AccessInterface
  rampService: ramp_service.Service
  events: EventEmitter

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    rampService: ramp_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.rampService = rampService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_CRYPTO_RAMP_PROVIDERS_READY) do(e: Args):
    let args = CryptoRampProvidersArgs(e)
    self.delegate.updateRampProviders(args.data)

  self.events.on(SIGNAL_CRYPTO_RAMP_URL_READY) do(e: Args):
    let args = CryptoRampUrlArgs(e)
    self.delegate.onRampProviderUrlReady(args.uuid, args.url)

proc fetchCryptoRampProviders*(self: Controller) =
  self.rampService.fetchCryptoRampProviders()

proc fetchCryptoRampUrl*(
    self: Controller,
    uuid: string,
    providerID: string,
    parameters: CryptoRampParametersDto,
) =
  self.rampService.fetchCryptoRampUrl(uuid, providerID, parameters)
