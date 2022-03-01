import controller_interface
import io_interface

import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/transaction/cryptoRampDto

export controller_interface

type
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    transactionService: transaction_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  transactionService: transaction_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.transactionService = transactionService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  discard

method fetchCryptoServices*(self: Controller): seq[CryptoRampDto] =
  return self.transactionService.fetchCryptoServices()
