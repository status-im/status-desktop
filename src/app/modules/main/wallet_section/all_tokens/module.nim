import NimQml, sequtils, sugar

import eventemitter

import ./io_interface, ./view, ./controller, ./item
import ../../../../core/global_singleton
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service

export io_interface

type
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    events: EventEmitter
    view: View
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.ServiceInterface,
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController[Module[T]](result, events, tokenService, walletAccountService)
  result.moduleLoaded = false

method delete*[T](self: Module[T]) =
  self.view.delete
  self.controller.delete

method refreshTokens*[T](self: Module[T]) =
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

method load*[T](self: Module[T]) =
  self.controller.init()
  singletonInstance.engine.setRootContextProperty("walletSectionAllTokens", newQVariant(self.view))
  self.refreshTokens()

  self.events.on("token/customTokenAdded") do(e:Args):
    self.refreshTokens()

  self.events.on("token/visibilityToggled") do(e:Args):
    self.refreshTokens()

  self.events.on("token/customTokenRemoved") do(e:Args):
    self.refreshTokens()

  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method addCustomToken*[T](self: Module[T], address: string, name: string, symbol: string, decimals: int) =
  self.controller.addCustomToken(address, name, symbol, decimals)
        
method toggleVisible*[T](self: Module[T], symbol: string) =
  self.controller.toggleVisible(symbol)

method removeCustomToken*[T](self: Module[T], address: string) =
  self.controller.removeCustomToken(address)

method getTokenDetails*[T](self: Module[T], address: string) =
  self.controller.getTokenDetails(address)

method tokenDetailsWereResolved*[T](self: Module[T], tokenDetails: string) =
  self.view.tokenDetailsWereResolved(tokenDetails)