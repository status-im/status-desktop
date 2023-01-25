import NimQml, stint, json, sequtils, sugar

import ./io_interface, ./view, ./controller, ./item, ./utils
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service

export io_interface

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, user only within this module.
type TmpSendTransactionDetails = object
  fromAddr: string
  toAddr: string
  tokenSymbol: string
  value: string
  uuid: string
  selectedRoutes: string

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails

# Forward declarations
method getWalletAccounts*(self: Module): seq[WalletAccountDto]
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

proc transactionsToItems(self: Module, transactions: seq[TransactionDto]) : seq[Item] =
  let gweiFormat = self.controller.getCurrencyFormat("Gwei")
  let ethFormat = self.controller.getCurrencyFormat("ETH")

  transactions.map(t => (block:
    let resolvedSymbol = self.getResolvedSymbol(t)
    transactionToItem(t, resolvedSymbol, self.controller.getCurrencyFormat(resolvedSymbol), ethFormat, gweiFormat)
  ))

proc setPendingTx(self: Module) =
  self.view.setPendingTx(self.transactionsToItems(self.controller.watchPendingTransactions()))

method viewDidLoad*(self: Module) =
  let accounts = self.getWalletAccounts()

  self.moduleLoaded = true
  self.delegate.transactionsModuleDidLoad()

  self.setPendingTx()

method switchAccount*(self: Module, accountIndex: int) =
  let walletAccount = self.controller.getWalletAccount(accountIndex)
  self.view.switchAccount(walletAccount)

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
  self.view.setTrxHistoryResult(self.transactionsToItems(transactions), address, wasFetchMore)

method setHistoryFetchState*(self: Module, addresses: seq[string], isFetching: bool) =
  self.view.setHistoryFetchStateForAccounts(addresses, isFetching)

method setHistoryFetchState*(self: Module, address: string, isFetching: bool) =
  self.view.setHistoryFetchState(address, isFetching)

method setIsNonArchivalNode*(self: Module, isNonArchivalNode: bool) =
  self.view.setIsNonArchivalNode(isNonArchivalNode)

method authenticateAndTransfer*(self: Module, from_addr: string, to_addr: string,
    tokenSymbol: string, value: string, uuid: string, selectedRoutes: string) =
  self.tmpSendTransactionDetails.fromAddr = from_addr
  self.tmpSendTransactionDetails.toAddr = to_addr
  self.tmpSendTransactionDetails.tokenSymbol = tokenSymbol
  self.tmpSendTransactionDetails.value = value
  self.tmpSendTransactionDetails.uuid = uuid
  self.tmpSendTransactionDetails.selectedRoutes = selectedRoutes

  if singletonInstance.userProfile.getIsKeycardUser():
    let keyUid = singletonInstance.userProfile.getKeyUid()
    self.controller.authenticateUser(keyUid)
  else:
    self.controller.authenticateUser()

  ##################################
  ## Do Not Delete
  ## 
  ## Once we start with signing a transactions we shold check if the address we want to send a transaction from is migrated
  ## or not. In case it's not we should just authenticate logged in user, otherwise we should use one of the keycards that
  ## address (key pair) is migrated to and sign the transaction using it.
  ## 
  ## The code bellow is an example how we can achieve that in future, when we start with signing transactions.
  ## 
  ## let acc = self.controller.getAccountByAddress(from_addr)
  ## if acc.isNil:
  ##   echo "error: selected account to send a transaction from is not known"
  ##   return
  ## let keyPair = self.controller.getMigratedKeyPairByKeyUid(acc.keyUid)
  ## if keyPair.len == 0:
  ##   self.controller.authenticateUser()
  ## else:
  ##   self.controller.authenticateUser(acc.keyUid, acc.path)
  ## 
  ##################################

method onUserAuthenticated*(self: Module, password: string) =
  if password.len == 0:
    let response = %* {"uuid": self.tmpSendTransactionDetails.uuid, "success": false, "error": cancelledRequest}
    self.view.transactionWasSent($response)
  else:
    self.controller.transfer(self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr,
      self.tmpSendTransactionDetails.tokenSymbol, self.tmpSendTransactionDetails.value, self.tmpSendTransactionDetails.uuid, 
      self.tmpSendTransactionDetails.selectedRoutes, password)

method transactionWasSent*(self: Module, result: string) =
  self.view.transactionWasSent(result)
  self.view.setPendingTx(self.transactionsToItems(self.controller.getPendingTransactions()))

method suggestedFees*(self: Module, chainId: int): string = 
  return self.controller.suggestedFees(chainId)

method suggestedRoutes*(self: Module, account: string, amount: UInt256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): string =
  return self.controller.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)

method getChainIdForChat*(self: Module): int =
  return self.controller.getChainIdForChat()

method getChainIdForBrowser*(self: Module): int =
  return self.controller.getChainIdForBrowser()

method getEstimatedTime*(self: Module, chainId: int, maxFeePerGas: string): int = 
  return self.controller.getEstimatedTime(chainId, maxFeePerGas).int

method getLastTxBlockNumber*(self: Module): string =
    return self.controller.getLastTxBlockNumber()

method suggestedRoutesReady*(self: Module, suggestedRoutes: string) =
  self.view.suggestedRoutesReady(suggestedRoutes)
