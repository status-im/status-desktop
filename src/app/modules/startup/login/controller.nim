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

method getOpenedAccounts*(self: Controller): seq[AccountDto] =
  return self.accountsService.openedAccounts()

method init*(self: Controller) = 
  self.appService.status.events.on(SignalType.NodeStopped.event) do(e:Args):
    echo "-NEW-LOGIN-- NodeStopped: ", repr(e)
    #self.status.events.emit("nodeStopped", Args())
    #self.view.onLoggedOut()

  self.appService.status.events.on(SignalType.NodeReady.event) do(e:Args):
    echo "-NEW-LOGIN-- NodeReady: ", repr(e)
    #self.status.events.emit("nodeReady", Args())

  self.appService.status.events.on(SignalType.NodeLogin.event) do(e:Args):
    echo "-NEW-LOGIN-- NodeLogin: ", repr(e)
    #self.handleNodeLogin(NodeSignal(e))