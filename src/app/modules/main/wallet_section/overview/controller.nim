import io_interface
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/currency/service as currency_service

import backend/helpers/token

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    walletAccountService: wallet_account_service.Service
    currencyService: currency_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  walletAccountService: wallet_account_service.Service,
  currencyService: currency_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.walletAccountService = walletAccountService
  result.currencyService = currencyService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getWalletAccountsByAddresses*(self: Controller, addresses: seq[string]): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getAccountsByAddresses(addresses)

proc getWalletTokensByAddresses*(self: Controller, addresses: seq[string]): seq[WalletTokenDto] =
  return self.walletAccountService.getTokensByAddresses(addresses)

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)
