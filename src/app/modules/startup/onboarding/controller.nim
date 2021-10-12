import Tables

import controller_interface

import status/[signals]
import ../../../../app_service/[main]
import ../../../../app_service/service/accounts/service_interface as accounts_service

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = 
    ref object of controller_interface.AccessInterface
    delegate: T
    appService: AppService
    accountsService: accounts_service.ServiceInterface
    selectedAccountId: string

proc newController*[T](delegate: T,
  appService: AppService,
  accountsService: accounts_service.ServiceInterface): 
  Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.appService = appService
  result.accountsService = accountsService
  
method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) = 
  self.appService.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    echo "-NEW-ONBOARDING-- OnNodeLoginEvent: ", repr(e)
    #self.handleNodeLogin(NodeSignal(e))

method getGeneratedAccounts*[T](self: Controller[T]): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

method setSelectedAccountId*[T](self: Controller[T], id: string) =
  self.selectedAccountId = id

method storeSelectedAccountAndLogin*[T](self: Controller[T], password: string) =
  let account = self.accountsService.setupAccount(self.appService.status.fleet.config, 
  self.selectedAccountId, password)

  echo "RECEIVED ACCOUNT: ", repr(account)