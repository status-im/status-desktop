import NimQml, stint, json, sequtils, sugar

import ./io_interface, ./view, ./controller, ./item, ./utils, ./multi_transaction_item
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/common/wallet_constants
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/collectible/service as collectible_service

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool

# Forward declarations
method loadTransactions*(self: Module, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false)

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.controller = controller.newController(result, events, transactionService, walletAccountService, networkService, currencyService)
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

proc getResolvedSymbol*(self: Module, transaction: TransactionDto): string =
  if transaction.symbol != "":
    result = transaction.symbol
  else:
    let contractSymbol = self.controller.findTokenSymbolByAddress(transaction.contract)
    if contractSymbol != "":
      result = contractSymbol
    else:
      result = "ETH"

method transactionsToItems*(self: Module, transactions: seq[TransactionDto], collectibles: seq[CollectibleDto]): seq[Item] =
  let gweiFormat = self.controller.getCurrencyFormat("Gwei")
  let ethFormat = self.controller.getCurrencyFormat("ETH")

  transactions.map(t => (block:
    if t.typeValue == ERC721_TRANSACTION_TYPE:
      for c in collectibles:
        if c.tokenId == t.tokenId and c.address == t.contract:
          # Found matching collectible
          return transactionToNFTItem(t, c, ethFormat, gweiFormat)
      # Could not find matching collectible, use empty one
      return transactionToNFTItem(t, newCollectibleDto(), ethFormat, gweiFormat)
    let resolvedSymbol = self.getResolvedSymbol(t)
    return transactionToItem(t, resolvedSymbol, self.controller.getCurrencyFormat(resolvedSymbol), ethFormat, gweiFormat)
  ))

proc setPendingTx(self: Module) =
  self.view.setPendingTx(self.transactionsToItems(self.controller.watchPendingTransactions(), @[]))

method setEnabledChainIds*(self: Module) =
  let enabledChainIds = self.controller.getEnabledChainIds()
  self.view.setEnabledChainIds(enabledChainIds)

method refreshTransactions*(self: Module) =
  self.setEnabledChainIds()
  self.view.resetTrxHistory()
  self.view.setPendingTx(self.transactionsToItems(self.controller.getPendingTransactions(), @[]))
  for account in self.controller.getWalletAccounts():
    let transactions = self.controller.getAllTransactions(account.address)
    self.view.setTrxHistoryResult(self.transactionsToItems(transactions, @[]), account.address, wasFetchMore=false)

method viewDidLoad*(self: Module) =
  let accounts = self.controller.getWalletAccounts()

  self.moduleLoaded = true
  self.delegate.transactionsModuleDidLoad()
  self.setEnabledChainIds()
  self.setPendingTx()

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  let walletAccount = self.controller.getWalletAccountByAddress(addresses[0])
  self.view.switchAccount(walletAccount)

method loadTransactions*(self: Module, address: string, toBlock: string = "0x0", limit: int = 20, loadMore: bool = false) =
  let toBlockParsed = stint.fromHex(Uint256, toBlock)
  let txLimit = if toBlock == "0x0":
      limit
    else:
      limit + 1

  self.controller.loadTransactions(address, toBlockParsed, txLimit, loadMore)

method setTrxHistoryResult*(self: Module, transactions: seq[TransactionDto], collectibles: seq[CollectibleDto], address: string, wasFetchMore: bool) =
  self.view.setTrxHistoryResult(self.transactionsToItems(transactions, collectibles), address, wasFetchMore)

method setHistoryFetchState*(self: Module, addresses: seq[string], isFetching: bool) =
  self.view.setHistoryFetchStateForAccounts(addresses, isFetching)

method setHistoryFetchState*(self: Module, addresses: seq[string], isFetching: bool, hasMore: bool) =
  self.view.setHistoryFetchStateForAccounts(addresses, isFetching, hasMore)

method setHistoryFetchState*(self: Module, address: string, allTxLoaded: bool, isFetching: bool) =
  self.view.setHistoryFetchState(address, allTxLoaded, isFetching)

method setIsNonArchivalNode*(self: Module, isNonArchivalNode: bool) =
  self.view.setIsNonArchivalNode(isNonArchivalNode)

method getChainIdForChat*(self: Module): int =
  return self.controller.getChainIdForChat()

method getChainIdForBrowser*(self: Module): int =
  return self.controller.getChainIdForBrowser()

method getLatestBlockNumber*(self: Module, chainId: int): string =
  return self.controller.getLatestBlockNumber(chainId)

method transactionWasSent*(self: Module, result: string) =
  self.view.setPendingTx(self.transactionsToItems(self.controller.getPendingTransactions(), @[]))

method fetchDecodedTxData*(self: Module, txHash: string, data: string) =
  self.controller.fetchDecodedTxData(txHash, data)

method txDecoded*(self: Module, txHash: string, dataDecoded: string) =
  self.view.txDecoded(txHash, dataDecoded)
