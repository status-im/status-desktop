import ./controller_interface
import ../../../../../app_service/service/token/service as token_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: T
    tokenService: token_service.ServiceInterface

proc newController*[T](
  delegate: T, 
  tokenService: token_service.ServiceInterface
): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.tokenService = tokenService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method getTokens*[T](self: Controller[T]): seq[token_service.TokenDto] =
  return self.tokenService.getTokens()