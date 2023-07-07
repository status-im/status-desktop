import sugar, sequtils, stint, json, json_serialization
import io_interface
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/currency/dto as currency_dto

import ../../../shared_modules/keycard_popup/io_interface as keycard_shared_module
import ../../../shared/wallet_utils
import ../../../shared_models/currency_amount

import ../../../../core/eventemitter

const UNIQUE_WALLET_SECTION_SEND_MODULE_IDENTIFIER* = "WalletSection-SendModule"

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    walletAccountService: wallet_account_service.Service
    networkService: network_service.Service
    currencyService: currency_service.Service
    transactionService: transaction_service.Service

proc newController*(
  delegate: io_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.walletAccountService = walletAccountService
  result.networkService = networkService
  result.currencyService = currencyService
  result.transactionService = transactionService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
    self.delegate.transactionWasSent(TransactionSentArgs(e).result)

  self.events.on(SIGNAL_SHARED_KEYCARD_MODULE_USER_AUTHENTICATED) do(e: Args):
    let args = SharedKeycarModuleArgs(e)
    if args.uniqueIdentifier != UNIQUE_WALLET_SECTION_SEND_MODULE_IDENTIFIER:
      return
    self.delegate.onUserAuthenticated(args.password)

  self.events.on(SIGNAL_SUGGESTED_ROUTES_READY) do(e:Args):
    self.delegate.suggestedRoutesReady(SuggestedRoutesArgs(e).suggestedRoutes)

proc getWalletAccounts*(self: Controller): seq[wallet_account_service.WalletAccountDto] =
  return self.walletAccountService.getWalletAccounts()

proc getChainIds*(self: Controller): seq[int] =
  return self.networkService.getNetworks().map(n => n.chainId)

proc getEnabledChainIds*(self: Controller): seq[int] =
  return self.networkService.getNetworks().filter(n => n.enabled).map(n => n.chainId)

proc getCurrentCurrency*(self: Controller): string =
  return self.walletAccountService.getCurrency()

proc getCurrencyFormat*(self: Controller, symbol: string): CurrencyFormatDto =
  return self.currencyService.getCurrencyFormat(symbol)

proc getKeycardsWithSameKeyUid*(self: Controller, keyUid: string): seq[KeycardDto] =
  return self.walletAccountService.getKeycardsWithSameKeyUid(keyUid)

proc getAccountByAddress*(self: Controller, address: string): WalletAccountDto =
  return self.walletAccountService.getAccountByAddress(address)

proc getWalletAccountByIndex*(self: Controller, accountIndex: int): WalletAccountDto =
  return self.walletAccountService.getWalletAccount(accountIndex)

proc getTokenBalanceOnChain*(self: Controller, address: string, chainId: int, symbol: string): CurrencyAmount =
  return currencyAmountToItem(self.walletAccountService.getTokenBalanceOnChain(address, chainId, symbol), self.currencyService.getCurrencyFormat(symbol))

proc authenticateUser*(self: Controller, keyUid = "") =
  let data = SharedKeycarModuleAuthenticationArgs(uniqueIdentifier: UNIQUE_WALLET_SECTION_SEND_MODULE_IDENTIFIER,
    keyUid: keyUid)
  self.events.emit(SIGNAL_SHARED_KEYCARD_MODULE_AUTHENTICATE_USER, data)

proc getEstimatedTime*(self: Controller, chainId: int, maxFeePerGas: string): EstimatedTime =
  return self.transactionService.getEstimatedTime(chainId, maxFeePerGas)

proc suggestedRoutes*(self: Controller, account: string, amount: Uint256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): string =
  let suggestedRoutes = self.transactionService.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)
  return suggestedRoutes.toJson()

proc transfer*(self: Controller, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, uuid: string, selectedRoutes: string, password: string) =
  self.transactionService.transfer(from_addr, to_addr, tokenSymbol, value, uuid, selectedRoutes, password)

proc suggestedFees*(self: Controller, chainId: int): string =
  let suggestedFees = self.transactionService.suggestedFees(chainId)
  return suggestedFees.toJson()
