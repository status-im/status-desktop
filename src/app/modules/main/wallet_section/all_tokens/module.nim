import NimQml, sequtils, sugar

import ./io_interface, ./view, ./controller, ./item
import ../io_interface as delegate_interface

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, events, tokenService, walletAccountService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method refreshTokens*(self: Module) =
  let tokens = self.controller.getTokens()
  self.view.setItems(
    tokens.map(t => initItem(
      t.name,
      t.symbol,
      t.hasIcon,
      t.addressAsString(),
      t.decimals,
      t.isCustom,
      t.isVisible
    ))
  )

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAllTokens", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on("token/customTokenAdded") do(e:Args):
    self.refreshTokens()

  self.events.on("token/visibilityToggled") do(e:Args):
    self.refreshTokens()

  self.events.on("token/customTokenRemoved") do(e:Args):
    self.refreshTokens()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshTokens()
  self.moduleLoaded = true
  self.delegate.allTokensModuleDidLoad()

method addCustomToken*(self: Module, address: string, name: string, symbol: string, decimals: int) =
  self.controller.addCustomToken(address, name, symbol, decimals)
        
method toggleVisible*(self: Module, symbol: string) =
  self.controller.toggleVisible(symbol)

method removeCustomToken*(self: Module, address: string) =
  self.controller.removeCustomToken(address)

method getTokenDetails*(self: Module, address: string) =
  self.controller.getTokenDetails(address)

method tokenDetailsWereResolved*(self: Module, tokenDetails: string) =
  self.view.tokenDetailsWereResolved(tokenDetails)