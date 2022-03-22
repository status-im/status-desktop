import io_interface

import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/transaction/cryptoRampDto


type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    transactionService: transaction_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  transactionService: transaction_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.transactionService = transactionService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc fetchCryptoServices*(self: Controller): seq[CryptoRampDto] =
  return self.transactionService.fetchCryptoServices()
