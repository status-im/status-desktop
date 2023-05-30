import tables, NimQml, sequtils, sugar, json, stint

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import ../../../../global/global_singleton
import ../../../../core/eventemitter
import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../../../app_service/service/network/service as network_service
import ../../../../../app_service/service/currency/service as currency_service
import ../../../../../app_service/service/transaction/service as transaction_service
import ../../../shared/wallet_utils

export io_interface

const cancelledRequest* = "cancelled"

# Shouldn't be public ever, use only within this module.
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
    events: EventEmitter
    view: View
    controller: Controller
    moduleLoaded: bool
    tmpSendTransactionDetails: TmpSendTransactionDetails
    senderCurrentAccountIndex: int
    # To-do we should create a dedicated module Receive
    receiveCurrentAccountIndex: int

proc newModule*(
  delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  walletAccountService: wallet_account_service.Service,
  networkService: network_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.events = events
  result.view = newView(result)
  result.controller = controller.newController(result, events, walletAccountService, networkService, currencyService, transactionService)
  result.moduleLoaded = false
  result.senderCurrentAccountIndex = 0
  result.receiveCurrentAccountIndex = 0

method delete*(self: Module) =
  self.view.delete
  self.controller.delete

method refreshWalletAccounts*(self: Module) =
  let walletAccounts = self.controller.getWalletAccounts()
  let currency = self.controller.getCurrentCurrency()
  let enabledChainIds = self.controller.getEnabledChainIds()
  let currencyFormat = self.controller.getCurrencyFormat(currency)
  let chainIds = self.controller.getChainIds()

  let items = walletAccounts.map(w => (block:
    let tokenFormats = collect(initTable()):
      for t in w.tokens: {t.symbol: self.controller.getCurrencyFormat(t.symbol)}

    walletAccountToWalletSendAccountItem(
      w,
      chainIds,
      enabledChainIds,
      currency,
      currencyFormat,
      tokenFormats,
    )
  ))

  self.view.setItems(items)
  self.view.switchSenderAccount(self.senderCurrentAccountIndex)
  self.view.switchReceiveAccount(self.receiveCurrentAccountIndex)

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("walletSectionSend", newQVariant(self.view))

  # these connections should be part of the controller's init method
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_NETWORK_ENABLED_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_WALLET_ACCOUNT_TOKENS_REBUILT) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_CURRENCY_FORMATS_UPDATED) do(e:Args):
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_NEW_KEYCARD_SET) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.events.on(SIGNAL_KEYCARDS_SYNCHRONIZED) do(e: Args):
    let args = KeycardActivityArgs(e)
    if not args.success:
      return
    self.refreshWalletAccounts()

  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.refreshWalletAccounts()
  self.moduleLoaded = true
  self.delegate.sendModuleDidLoad()

method getTokenBalanceOnChain*(self: Module, address: string, chainId: int, symbol: string): CurrencyAmount =
  return self.controller.getTokenBalanceOnChain(address, chainId, symbol)

method authenticateAndTransfer*(
  self: Module, from_addr: string, to_addr: string, tokenSymbol: string, value: string, uuid: string, selectedRoutes: string
) =
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
  ## let keyPair = self.controller.getKeycardByKeyUid(acc.keyUid)
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
    self.controller.transfer(
      self.tmpSendTransactionDetails.fromAddr, self.tmpSendTransactionDetails.toAddr,
      self.tmpSendTransactionDetails.tokenSymbol, self.tmpSendTransactionDetails.value, self.tmpSendTransactionDetails.uuid,
      self.tmpSendTransactionDetails.selectedRoutes, password
    )

method transactionWasSent*(self: Module, result: string) =
  self.view.transactionWasSent(result)

method suggestedFees*(self: Module, chainId: int): string =
  return self.controller.suggestedFees(chainId)

method suggestedRoutes*(self: Module, account: string, amount: UInt256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): string =
  return self.controller.suggestedRoutes(account, amount, token, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs, sendType, lockedInAmounts)

method suggestedRoutesReady*(self: Module, suggestedRoutes: string) =
  self.view.suggestedRoutesReady(suggestedRoutes)

method getEstimatedTime*(self: Module, chainId: int, maxFeePerGas: string): int =
  return self.controller.getEstimatedTime(chainId, maxFeePerGas).int

method filterChanged*(self: Module, addresses: seq[string], chainIds: seq[int]) =
  if addresses.len == 0:
    return
  self.view.switchSenderAccountByAddress(addresses[0])
  self.view.switchReceiveAccountByAddress(addresses[0])

method setSelectedSenderAccountIndex*(self: Module, index: int) =
  self.senderCurrentAccountIndex = index

method setSelectedReceiveAccountIndex*(self: Module, index: int) =
  self.receiveCurrentAccountIndex = index
