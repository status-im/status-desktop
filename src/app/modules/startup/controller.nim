import chronicles

import io_interface

import ../../core/signals/types
import ../../core/eventemitter
import ../../../app_service/service/accounts/service as accounts_service


logScope:
  topics = "startup-controller"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    accountsService: accounts_service.Service

proc newController*(delegate: io_interface.AccessInterface,
  events: EventEmitter,
  accountsService: accounts_service.Service):
  Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.accountsService = accountsService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SignalType.NodeLogin.event) do(e:Args):
    let signal = NodeSignal(e)
    if signal.event.error == "":
      self.delegate.userLoggedIn()
    else:
      error "error: ", methodName="init", errDesription = "login error " & signal.event.error

  self.events.on(SignalType.NodeStopped.event) do(e:Args):
    self.events.emit("nodeStopped", Args())
    self.accountsService.clear()
    self.delegate.emitLogOut()

  self.events.on(SignalType.NodeReady.event) do(e:Args):
    self.events.emit("nodeReady", Args())

proc shouldStartWithOnboardingScreen*(self: Controller): bool =
  return self.accountsService.openedAccounts().len == 0
