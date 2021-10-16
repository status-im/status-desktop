import NimQml, Tables

import controller_interface
import io_interface

import ../../../../app_service/service/local_settings/service as local_settings_service
import ../../../../app_service/service/keychain/service as keychain_service
import ../../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter
import status/[signals]

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    localSettingsService: local_settings_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.ServiceInterface
    selectedAccountKeyUid: string

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  localSettingsService: local_settings_service.Service,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.ServiceInterface): 
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.localSettingsService = localSettingsService
  result.keychainService = keychainService
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

proc getSelectedAccount(self: Controller): AccountDto =
  let openedAccounts = self.getOpenedAccounts()
  for acc in openedAccounts:
    if(acc.keyUid == self.selectedAccountKeyUid):
      return acc

method setSelectedAccountKeyUid*(self: Controller, keyUid: string) =
  self.selectedAccountKeyUid = keyUid

  let selectedAccount = self.getSelectedAccount()
  self.localSettingsService.updateAccountSettingsFilePath(selectedAccount.name)
  self.delegate.emitStoreToKeychainValueChanged()
  self.keychainService.tryToObtainPassword(selectedAccount.name)

method login*(self: Controller, password: string) =
  let selectedAccount = self.getSelectedAccount()

  let error = self.accountsService.login(selectedAccount, password)
  if(error.len > 0):
    self.delegate.loginAccountError(error)

method getStoreToKeychainValue*(self: Controller): string =
  return self.localSettingsService.getAccountValue(
  LS_KEY_STORE_TO_KEYCHAIN).stringVal