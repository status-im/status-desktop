import NimQml, stint

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool

# Forward declarations
method checkRecentHistory*(self: Module)
method getWalletAccounts*(self: Module): seq[WalletAccountDto]
method loadTransactions*(self: Module, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false)

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController(result, events, transactionService, walletAccountService, networkService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionTransactions", newQVariant(self.view))
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.checkRecentHistory()
  let accounts = self.getWalletAccounts()

  self.moduleLoaded = true
  self.delegate.transactionsModuleDidLoad()

  self.controller.checkPendingTransactions()

method switchAccount*(self: Module, accountIndex: int) =
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.switchAccount(walletAccount)

method checkRecentHistory*(self: Module) =
  self.controller.checkRecentHistory()

method getWalletAccounts*(self: Module): seq[WalletAccountDto] =
  self.controller.getWalletAccounts()

method getAccountByAddress*(self: Module, address: string): WalletAccountDto =
  self.controller.getAccountByAddress(address)

method loadTransactions*(self: Module, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) =
  let toBlockParsed = stint.fromHex(Uint256, toBlock)
  let txLimit = if toBlock == "0x0":
      limit
    else:
      limit + 1

  self.controller.loadTransactions(address, toBlockParsed, txLimit, loadMore)

method setTrxHistoryResult*(self: Module, transactions: seq[TransactionDto], address: string, wasFetchMore: bool) =
  self.view.setTrxHistoryResult(transactions, address, wasFetchMore)

method setHistoryFetchState*(self: Module, addresses: seq[string], isFetching: bool) =
  self.view.setHistoryFetchStateForAccounts(addresses, isFetching)

method estimateGas*(self: Module, from_addr: string, to: string, assetSymbol: string, value: string, data: string): string =
  result = self.controller.estimateGas(from_addr, to, assetSymbol, value, data)

method setIsNonArchivalNode*(self: Module, isNonArchivalNode: bool) =
  self.view.setIsNonArchivalNode(isNonArchivalNode)

method transfer*(self: Module, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,
    maxFeePerGas: string, password: string, chainId: string, uuid: string, eip1559Enabled: bool): bool =
  result = self.controller.transfer(from_addr, to_addr, tokenSymbol, value, gas, gasPrice,
    maxPriorityFeePerGas, maxFeePerGas, password, chainId, uuid, eip1559Enabled)

method transactionWasSent*(self: Module, result: string) =
  self.view.transactionWasSent(result)

method suggestedFees*(self: Module, chainId: int): string = 
  return self.controller.suggestedFees(chainId)

method suggestedRoutes*(self: Module, account: string, amount: float64, token: string, disabledChainIDs: seq[uint64]): string =
  return self.controller.suggestedRoutes(account, amount, token, disabledChainIDs)

method getChainIdForChat*(self: Module): int =
  return self.controller.getChainIdForChat()

method getChainIdForBrowser*(self: Module): int =
  return self.controller.getChainIdForBrowser()

method getEstimatedTime*(self: Module, chainId: int, maxFeePerGas: string): int = 
  return self.controller.getEstimatedTime(chainId, maxFeePerGas).int
