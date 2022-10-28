import NimQml, sequtils, sugar

import ./io_interface, ./view, ./controller, ./item
import ../io_interface as delegate_interface

import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/token/service as token_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/token/dto

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  tokenService: token_service.Service,
  walletAccountService: wallet_account_service.Service,
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
      t.isVisible,
      t.chainId,
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

method addCustomToken*(self: Module, chainId: int, address: string, name: string, symbol: string, decimals: int): string =
  return self.controller.addCustomToken(chainId, address, name, symbol, decimals)
        
method toggleVisible*(self: Module, chainId: int, address: string) =
  self.controller.toggleVisible(chainId, address)

method removeCustomToken*(self: Module, chainId: int, address: string) =
  self.controller.removeCustomToken(chainId, address)

method getTokenDetails*(self: Module, address: string) =
  self.controller.getTokenDetails(address)

method tokenDetailsWereResolved*(self: Module, tokenDetails: string) =
  self.view.tokenDetailsWereResolved(tokenDetails)

method findTokenSymbolByAddress*(self: Module, address: string): string =
  return self.controller.findTokenSymbolByAddress(address)

method getHistoricalDataForToken*(self: Module, symbol: string, currency: string) =
  self.controller.getHistoricalDataForToken(symbol, currency, WEEKLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, MONTHLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, HALF_YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, YEARLY_TIME_RANGE)
  self.controller.getHistoricalDataForToken(symbol, currency, ALL_TIME_RANGE)

method tokenHistoricalDataResolved*(self: Module, tokenDetails: string) =
  self.view.tokenHistoricalDataReady(tokenDetails)


method fetchHistoricalBalanceForTokenAsJson*(self: Module, address: string, symbol: string, timeIntervalEnum: int) =
  self.controller.fetchHistoricalBalanceForTokenAsJson(address, symbol, timeIntervalEnum)

method tokenBalanceHistoryDataResolved*(self: Module, balanceHistoryJson: string) =
  self.view.tokenBalanceHistoryDataReady(balanceHistoryJson)
