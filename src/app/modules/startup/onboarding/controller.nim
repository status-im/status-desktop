import Tables, chronicles

import controller_interface
import io_interface

import ../../../../app_service/service/accounts/service_interface as accounts_service

import ../../../core/signals/types
import eventemitter

export controller_interface

logScope:
  topics = "onboarding-controller"

type 
  Controller* = 
    ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    accountsService: accounts_service.ServiceInterface
    selectedAccountId: string

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
      self.delegate.setupAccountError()

method getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

method getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

method setSelectedAccountByIndex*(self: Controller, index: int) =
  let accounts = self.getGeneratedAccounts()
  self.selectedAccountId = accounts[index].id

method storeSelectedAccountAndLogin*(self: Controller, password: string) =
  if(not self.accountsService.setupAccount(self.selectedAccountId, password)):
    self.delegate.setupAccountError()

method validateMnemonic*(self: Controller, mnemonic: string): string =
  return self.accountsService.validateMnemonic(mnemonic)

method importMnemonic*(self: Controller, mnemonic: string) =
  if(self.accountsService.importMnemonic(mnemonic)):
    self.selectedAccountId = self.getImportedAccount().id
    self.delegate.importAccountSuccess()
  else:
    self.delegate.importAccountError()
  
  