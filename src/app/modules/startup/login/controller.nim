import Tables

import controller_interface
import io_interface

import ../../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    accountsService: accounts_service.ServiceInterface
    selectedAccountKeyUid: string

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.accountsService = accountsService
  
method delete*(self: Controller) =
  discard

method init*(self: Controller) = 
  self.events.on(SignalType.NodeLogin.event) do(e:Args):
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