import NimQml, sequtils, strutils, sugar, stint

import ../../../../../app_service/service/wallet_account/service as wallet_account_service

import ./accounts_model
import ./account_item
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      accounts: AccountsModel
      accountsVariant: QVariant

      tmpAddress: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpSymbol: string # shouldn't be used anywhere except in prepare*/getPrepared* procs
      tmpChainID: int  # shouldn't be used anywhere except in prepare*/getPrepared* procs

  proc delete*(self: View) =
    self.accounts.delete
    self.accountsVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.accounts = newAccountsModel()
    result.accountsVariant = newQVariant(result.accounts)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc accountsChanged*(self: View) {.signal.}

  proc getAccounts(self: View): QVariant {.slot.} =
    return self.accountsVariant

  QtProperty[QVariant] accounts:
    read = getAccounts
    notify = accountsChanged

  proc setItems*(self: View, items: seq[AccountItem]) =
    self.accounts.setItems(items)

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
