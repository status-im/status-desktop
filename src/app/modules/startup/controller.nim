import Tables, chronicles

import controller_interface
import io_interface

import ../../../app_service/service/local_settings/service as local_settings_service
import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/accounts/service_interface as accounts_service

import eventemitter
import status/[signals]

export controller_interface

logScope:
  topics = "startup-controller"

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    localSettingsService: local_settings_service.Service
    keychainService: keychain_service.Service
    accountsService: accounts_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  localSettingsService: local_settings_service.Service,
  keychainService: keychain_service.Service,
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
    if signal.event.error == "":
      self.delegate.userLoggedIn()
    else:
      error "error: ", methodName="init", errDesription = "login error " & signal.event.error

  self.events.on(SignalType.NodeStopped.event) do(e:Args):
    echo "-NEW-EVENT-- NodeStopped: ", repr(e)
    #self.status.events.emit("nodeStopped", Args())
    #self.view.onLoggedOut()

  self.events.on(SignalType.NodeReady.event) do(e:Args):
    echo "-NEW-EVENT-- NodeReady: ", repr(e)
    #self.status.events.emit("nodeReady", Args())

method shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0