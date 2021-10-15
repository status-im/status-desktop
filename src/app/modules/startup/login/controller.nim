import Tables

import controller_interface
import io_interface

import status/[signals]
import ../../../../app_service/[main]
import ../../../../app_service/service/accounts/service_interface as accounts_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    appService: AppService
    accountsService: accounts_service.ServiceInterface
    selectedAccountKeyUid: string

proc newController*(delegate: io_interface.AccessInterface,
  appService: AppService,
  accountsService: accounts_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.appService = appService
  result.accountsService = accountsService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.appService.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    if signal.event.error != "":
      self.delegate.loginAccountError(signal.event.error)

method getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

method setSelectedAccountKeyUid*(self: Controller, keyUid: string) =
  self.selectedAccountKeyUid = keyUid

method login*(self: Controller, password: string) =
  let openedAccounts = self.getOpenedAccounts()
  var selectedAccount: AccountDto
  for acc in openedAccounts:
    if(acc.keyUid == self.selectedAccountKeyUid):
      selectedAccount = acc
      break

  let error = self.accountsService.login(selectedAccount, password)
  if(error.len > 0):
    self.delegate.loginAccountError(error)