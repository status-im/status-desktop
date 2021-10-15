import ./controller_interface
import ../../../../../app_service/service/transaction/service as transaction_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    transactionService: transaction_service.ServiceInterface

proc newController*[T](
  delegate: T, 
  transactionService: transaction_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.transactionService = transactionService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard