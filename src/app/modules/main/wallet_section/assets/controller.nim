import io_interface
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/token/service as token_service
import app_service/service/currency/service as currency_service

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    tokenService: token_service.Service
    currencyService: currency_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.tokenService = tokenService
  result.currencyService = currencyService

proc delete*(self: Controller) =
  discard

proc buildAllTokens*(self: Controller, addresses: seq[string]) =
  self.walletAccountService.buildAllTokens(addresses, store = true)

proc init*(self: Controller) =
  let walletAddresses = self.walletAccountService.getWalletAddresses()
  self.buildAllTokens(walletAddresses)
  discard

proc getChainIds*(self: Controller): seq[int] =
  return self.networkService.getCurrentNetworksChainIds()

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc getGroupedAccountsAssetsList*(self: Controller): var seq[GroupedTokenItem] =
  return self.walletAccountService.getGroupedAccountsAssetsList()

proc getHasBalanceCache*(self: Controller): bool =
  return self.walletAccountService.getHasBalanceCache()

proc getHasMarketValuesCache*(self: Controller): bool =
  return self.tokenService.getHasMarketValuesCache()
