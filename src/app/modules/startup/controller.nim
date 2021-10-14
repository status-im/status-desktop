import Tables

import controller_interface
import io_interface

import ../../../app_service/service/accounts/service_interface as accounts_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    accountsService: accounts_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
  accountsService: accounts_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.accountsService = accountsService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  discard

method shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0