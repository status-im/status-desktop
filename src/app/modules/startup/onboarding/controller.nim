import Tables, chronicles

import io_interface

import ../../../core/signals/types
import ../../../core/eventemitter
import ../../../../app_service/service/accounts/service as accounts_service
import ../../../../app_service/service/general/service as general_service

logScope:
  topics = "onboarding-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    accountsService: accounts_service.Service
    generalService: general_service.Service
    selectedAccountId: string
    displayName: string

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.Service,
  generalService: general_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.accountsService = accountsService
  result.generalService = generalService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    if signal.event.error != "":
      self.delegate.setupAccountError(signal.event.error)

proc getGeneratedAccounts*(self: Controller): seq[GeneratedAccountDto] =
  return self.accountsService.generatedAccounts()

proc getImportedAccount*(self: Controller): GeneratedAccountDto =
  return self.accountsService.getImportedAccount()

proc setSelectedAccountByIndex*(self: Controller, index: int) =
  let accounts = self.getGeneratedAccounts()
  self.selectedAccountId = accounts[index].id

proc setDisplayName*(self: Controller, displayName: string) =
  self.displayName = displayName

proc storeSelectedAccountAndLogin*(self: Controller, password: string) =
  let error = self.accountsService.setupAccount(self.selectedAccountId, password, self.displayName)
  if error != "":
    self.delegate.setupAccountError(error)

proc validateMnemonic*(self: Controller, mnemonic: string): string =
  return self.accountsService.validateMnemonic(mnemonic)

proc importMnemonic*(self: Controller, mnemonic: string) =
  let error = self.accountsService.importMnemonic(mnemonic)
  if(error == ""):
    self.selectedAccountId = self.getImportedAccount().id
    self.delegate.importAccountSuccess()
  else:
    self.delegate.importAccountError(error)

method getPasswordStrengthScore*(self: Controller, password, userName: string): int = 
  return self.generalService.getPasswordStrengthScore(password, userName)

