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

proc init*(self: Controller) =
  discard

proc getWalletAccount*(self: Controller, accountIndex: int): wallet_account_service.WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc isKeycardAccount*(self: Controller, account: WalletAccountDto): bool =
  return self.walletAccountService.isKeycardAccount(account)

proc getIndex*(self: Controller, address: string): int =
  return self.walletAccountService.getIndex(address)

proc getChainIds*(self: Controller): seq[int] =
  return self.networkService.getCurrentNetworksChainIds()

proc getEnabledChainIds*(self: Controller): seq[int] =
  return self.networkService.getEnabledChainIds()

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, key: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(key)

proc areTestNetworksEnabled*(self: Controller): bool =
  return self.walletAccountService.areTestNetworksEnabled()

proc getTotalCurrencyBalance*(self: Controller, address: string, chainIds: seq[int]): float64 =
  return self.walletAccountService.getTotalCurrencyBalance(@[address], chainIds)

proc getTokensMarketValuesLoading*(self: Controller): bool =
  return self.walletAccountService.getTokensMarketValuesLoading()
