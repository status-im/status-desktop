import io_interface

import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../core/eventemitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    transactionService: transaction_service.Service
    events: EventEmitter

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.transactionService = transactionService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_CRYPTO_SERVICES_READY) do(e:Args):
    let args = CryptoServicesArgs(e)
    self.delegate.updateCryptoServices(args.data)

proc fetchCryptoServices*(self: Controller) =
  self.transactionService.fetchCryptoServices()
