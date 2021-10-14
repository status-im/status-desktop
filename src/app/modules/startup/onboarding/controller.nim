import Tables, chronicles

import controller_interface
import io_interface

import status/[signals]
import ../../../../app_service/[main]
import ../../../../app_service/service/accounts/service_interface as accounts_service

export controller_interface

logScope:
  topics = "onboarding-controller"

type 
  Controller* = 
    ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    appService: AppService
    accountsService: accounts_service.ServiceInterface
    selectedAccountId: string

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
    echo "-NEW-ONBOARDING-- OnNodeLoginEvent: ", repr(signal)
    if signal.event.error == "":
      echo "-NEW-ONBOARDING-- OnNodeLoginEventA: ", repr(signal.event.error)
      self.delegate.accountCreated()
    else:
      error "error: ", methodName="init", errDesription = "onboarding login error " & signal.event.error

method getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

method getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

method setSelectedAccountByIndex*(self: Controller, index: int) =
  let accounts = self.getGeneratedAccounts()
  self.selectedAccountId = accounts[index].id

method storeSelectedAccountAndLogin*(self: Controller, password: string) =
  if(not self.accountsService.setupAccount(self.appService.status.fleet.config, 
  self.selectedAccountId, password)):
    self.delegate.setupAccountError()

method validateMnemonic*(self: Controller, mnemonic: string): string =
  return self.accountsService.validateMnemonic(mnemonic)

method importMnemonic*(self: Controller, mnemonic: string) =
  if(self.accountsService.importMnemonic(mnemonic)):
    self.selectedAccountId = self.getImportedAccount().id
    self.delegate.importAccountSuccess()
  else:
    self.delegate.importAccountError()
  
  