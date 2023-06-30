import NimQml, sequtils, strutils, stint, sugar

import ../../../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../shared_models/token_model

import ./accounts_model
import ./account_item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      accounts: AccountsModel
      # this one doesn't include watch accounts and its what the user switches when using the sendModal
      senderAccounts: AccountsModel
      # for send modal
      selectedSenderAccount: AccountItem
      # for receive modal
      selectedReceiveAccount: AccountItem

      tmpAddress: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpSymbol: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpChainID: int  # shouldn't be used anywhere except in prepare*/getPrepared* procs

  proc delete*(self: View) =
    self.accounts.delete
    self.senderAccounts.delete
    self.selectedSenderAccount.delete
    self.selectedReceiveAccount.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.accounts = newAccountsModel()
    result.senderAccounts = newAccountsModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc accountsChanged*(self: View) {.signal.}
  proc getAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.accounts)
  QtProperty[QVariant] accounts:
    read = getAccounts
    notify = accountsChanged

  proc senderAccountsChanged*(self: View) {.signal.}
  proc getSenderAccounts(self: View): QVariant {.slot.} =
    return newQVariant(self.senderAccounts)
  QtProperty[QVariant] senderAccounts:
    read = getSenderAccounts
    notify = senderAccountsChanged

  proc selectedSenderAccountChanged*(self: View) {.signal.}
  proc getSelectedSenderAccount(self: View): QVariant {.slot.} =
    return newQVariant(self.selectedSenderAccount)
  proc setSelectedSenderAccount*(self: View, account: AccountItem) =
    self.selectedSenderAccount = account
    self.selectedSenderAccountChanged()
  QtProperty[QVariant] selectedSenderAccount:
    read = getSelectedSenderAccount
    notify = selectedSenderAccountChanged

  proc selectedReceiveAccountChanged*(self: View) {.signal.}
  proc getSelectedReceiveAccount(self: View): QVariant {.slot.} =
    return newQVariant(self.selectedReceiveAccount)
  proc setSelectetReceiveAccount*(self: View, account: AccountItem) =
    self.selectedReceiveAccount = account
    self.selectedReceiveAccountChanged()
  QtProperty[QVariant] selectedReceiveAccount:
    read = getSelectedReceiveAccount
    notify = selectedReceiveAccountChanged

  proc setItems*(self: View, items: seq[AccountItem]) =
    self.accounts.setItems(items)
    self.accountsChanged()

    # need to remove watch only accounts as a user cant send a tx with a watch only account
    self.senderAccounts.setItems(items.filter(a => a.walletType() != WalletTypeWatch))
    self.senderAccountsChanged()

  proc prepareTokenBalanceOnChain*(self: View, address: string, chainId: int, tokenSymbol: string) {.slot.} =
    self.tmpAddress = address
    self.tmpChainId = chainId
    self.tmpSymbol = tokenSymbol

  proc getPreparedTokenBalanceOnChain*(self: View): QVariant {.slot.} =
    let currencyAmount = self.delegate.getTokenBalanceOnChain(self.tmpAddress, self.tmpChainId, self.tmpSymbol)
    self.tmpAddress = ""
    self.tmpChainId = 0
    self.tmpSymbol = "ERROR"
    return newQVariant(currencyAmount)

  proc transactionSent*(self: View, txResult: string) {.signal.}

  proc transactionWasSent*(self: View,txResult: string) {.slot} =
    self.transactionSent(txResult)

  proc authenticateAndTransfer*(self: View, from_addr: string, to_addr: string, tokenSymbol: string,
    value: string, uuid: string, selectedRoutes: string) {.slot.} =
      self.delegate.authenticateAndTransfer(from_addr, to_addr, tokenSymbol, value, uuid, selectedRoutes)

  proc suggestedFees*(self: View, chainId: int): string {.slot.} =
    return self.delegate.suggestedFees(chainId)

  proc suggestedRoutes*(self: View, account: string, amount: string, token: string, disabledFromChainIDs: string, disabledToChainIDs: string, preferredChainIDs: string, sendType: int, lockedInAmounts: string): string {.slot.} =
    var parsedAmount = stint.u256("0")
    var seqPreferredChainIDs = seq[uint64] : @[]
    var seqDisabledFromChainIDs = seq[uint64] : @[]
    var seqDisabledToChainIDs = seq[uint64] : @[]

    try:
      for chainID in disabledFromChainIDs.split(','):
        seqDisabledFromChainIDs.add(parseUInt(chainID))
    except:
      discard

    try:
      for chainID in disabledToChainIDs.split(','):
        seqDisabledToChainIDs.add(parseUInt(chainID))
    except:
      discard

    try:
      for chainID in preferredChainIDs.split(','):
        seqPreferredChainIDs.add(parseUInt(chainID))
    except:
      discard

    try:
      parsedAmount = fromHex(Stuint[256], amount)
    except Exception as e:
      discard

    return self.delegate.suggestedRoutes(account, parsedAmount, token, seqDisabledFromChainIDs, seqDisabledToChainIDs, seqPreferredChainIDs, sendType, lockedInAmounts)

  proc getEstimatedTime*(self: View, chainId: int, maxFeePerGas: string): int {.slot.} =
    return self.delegate.getEstimatedTime(chainId, maxFeePerGas)

  proc suggestedRoutesReady*(self: View, suggestedRoutes: string) {.signal.}

  proc hasGas*(self: View, address: string, chainId: int, nativeGasSymbol: string, requiredGas: float): bool {.slot.} =
    for account in self.accounts.items:
      if account.address() == address:
        return account.getAssets().hasGas(chainId, nativeGasSymbol, requiredGas)

    return false

  proc switchSenderAccountByAddress*(self: View, address: string) =
    let (account, index) = self.senderAccounts.getItemByAddress(address)
    self.setSelectedSenderAccount(account)
    self.delegate.setSelectedSenderAccountIndex(index)

  proc switchReceiveAccountByAddress*(self: View, address: string) =
    let (account, index) = self.accounts.getItemByAddress(address)
    self.setSelectetReceiveAccount(account)
    self.delegate.setSelectedReceiveAccountIndex(index)

  proc switchSenderAccount*(self: View, index: int) {.slot.} =
    var account = self.senderAccounts.getItemByIndex(index)
    var idx = index
    if account.isNil:
      account = self.senderAccounts.getItemByIndex(0)
      idx = 0

    self.setSelectedSenderAccount(account)
    self.delegate.setSelectedSenderAccountIndex(idx)

  proc switchReceiveAccount*(self: View, index: int) {.slot.} =
    var account = self.accounts.getItemByIndex(index)
    var idx = index
    if account.isNil:
      account = self.accounts.getItemByIndex(0)
      idx = 0

    self.setSelectetReceiveAccount(account)
    self.delegate.setSelectedReceiveAccountIndex(idx)
