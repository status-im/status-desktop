import NimQml, sequtils, sugar

import ./io_interface, ./view, ./controller
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

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionAllTokens", newQVariant(self.view))

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.allTokensModuleDidLoad()

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
