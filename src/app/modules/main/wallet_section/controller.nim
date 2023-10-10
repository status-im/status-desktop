import sequtils, sugar
import io_interface
import ../../../../app_service/service/settings/service as settings_service
import ../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../app_service/service/currency/service as currency_service
import ../../../../app_service/service/network/service as network_service

import ../../shared/wallet_utils
import ../../shared_models/currency_amount

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    settingsService: settings_service.Service
    walletAccountService: wallet_account_service.Service
    currencyService: currency_service.Service
    networkService: network_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  settingsService: settings_service.Service,
  walletAccountService: wallet_account_service.Service,
  currencyService: currency_service.Service,
  networkService: network_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.settingsService = settingsService
  result.walletAccountService = walletAccountService
  result.currencyService = currencyService
  result.networkService = networkService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  discard

proc getCurrency*(self: Controller): string =
  return self.settingsService.getCurrency()

proc getSigningPhrase*(self: Controller): string =
  return self.settingsService.getSigningPhrase()

proc isMnemonicBackedUp*(self: Controller): bool =
  return self.settingsService.getMnemonic().len > 0

proc getCurrencyBalance*(self: Controller, addresses: seq[string]): CurrencyAmount =
  return currencyAmountToItem(self.walletAccountService.getTotalCurrencyBalance(addresses), self.currencyService.getCurrencyFormat(self.getCurrency()))

proc getCurrencyAmount*(self: Controller, amount: float64, symbol: string): CurrencyAmount =
  return currencyAmountToItem(amount, self.currencyService.getCurrencyFormat(symbol))

proc updateCurrency*(self: Controller, currency: string) =
  self.walletAccountService.updateCurrency(currency)

proc getNetworks*(self: Controller): seq[NetworkDto] =
  return self.networkService.getNetworks()

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc getEnabledChainIds*(self: Controller): seq[int] =
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getKeypairByAccountAddress*(self: Controller, address: string): KeypairDto =
  return self.walletAccountService.getKeypairByAccountAddress(address)

proc hasPairedDevices*(self: Controller): bool =
  return self.walletAccountService.hasPairedDevices()
