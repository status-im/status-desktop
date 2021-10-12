import Tables

import controller_interface

import ../../../app_service/service/accounts/service_interface as accounts_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T
    accountsService: accounts_service.ServiceInterface

proc newController*[T](delegate: T,
  accountsService: accounts_service.ServiceInterface): 
  Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.accountsService = accountsService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  discard

method shouldStartWithOnboardingScreen*[T](self: Controller[T]): bool =
  return self.accountsService.openedAccounts().len > 0