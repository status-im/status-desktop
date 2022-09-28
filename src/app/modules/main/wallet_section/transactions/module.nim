import NimQml, stint

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service

export io_interface

# Shouldn't be public ever, user only within this module.
type TmpSendTransactionDetails = object
  fromAddr: string
  toAddr: string
  tokenSymbol: string
  value: string 
  gas: string 
  gasPrice: string 
  maxPriorityFeePerGas: string
  maxFeePerGas: string
  chainId: string
  uuid: string
  eip1559Enabled: bool

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    controller: Controller
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails

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

method authenticateAndTransfer*(self: Module, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, gas: string, gasPrice: string, maxPriorityFeePerGas: string,
    maxFeePerGas: string, chainId: string, uuid: string, eip1559Enabled: bool) =

  self.tmpSendTransactionDetails.fromAddr = from_addr
  self.tmpSendTransactionDetails.toAddr = to_addr
  self.tmpSendTransactionDetails.tokenSymbol = tokenSymbol
  self.tmpSendTransactionDetails.value = value
  self.tmpSendTransactionDetails.gas = gas
  self.tmpSendTransactionDetails.gasPrice = gasPrice
  self.tmpSendTransactionDetails.maxPriorityFeePerGas = maxPriorityFeePerGas
  self.tmpSendTransactionDetails.maxFeePerGas = maxFeePerGas
  self.tmpSendTransactionDetails.chainId = chainId
  self.tmpSendTransactionDetails.uuid = uuid
  self.tmpSendTransactionDetails.eip1559Enabled = eip1559Enabled

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
  self.controller.transfer(self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr, 
    self.tmpSendTransactionDetails.tokenSymbol, self.tmpSendTransactionDetails.value, self.tmpSendTransactionDetails.gas, 
    self.tmpSendTransactionDetails.gasPrice, self.tmpSendTransactionDetails.maxPriorityFeePerGas, 
    self.tmpSendTransactionDetails.maxFeePerGas, password, self.tmpSendTransactionDetails.chainId, self.tmpSendTransactionDetails.uuid, 
    self.tmpSendTransactionDetails.eip1559Enabled)

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

method getLastTxBlockNumber*(self: Module): string =
    return self.controller.getLastTxBlockNumber()
