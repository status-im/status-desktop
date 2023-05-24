import ../../../../../app_service/service/wallet_account/dto as WalletDto
import ../../../../../app_service/service/collectible/dto as CollectibleDto
import ../../../../../app_service/service/transaction/dto
export TransactionDto, CollectibleDto

import ./item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(self: AccessInterface, addresses: seq[string], chainIds: seq[int]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: AccessInterface): seq[WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTransactions*(self: AccessInterface, address: string, toBlock: string, limit: int, loadMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setTrxHistoryResult*(self: AccessInterface, transactions: seq[TransactionDto], collectibles: seq[CollectibleDto], address: string, wasFetchMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setHistoryFetchState*(self: AccessInterface, addresses: seq[string], isFetching: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setHistoryFetchState*(self: AccessInterface, addresses: seq[string], isFetching: bool, hasMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setHistoryFetchState*(self: AccessInterface, address: string, allTxLoaded: bool, isFetching: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setIsNonArchivalNode*(self: AccessInterface, isNonArchivalNode: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(self: AccessInterface, result: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChainIdForChat*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method getChainIdForBrowser*(self: AccessInterface): int {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshTransactions*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getLatestBlockNumber*(self: AccessInterface, chainId: int): string {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionsToItems*(self: AccessInterface, transactions: seq[TransactionDto], collectibles: seq[CollectibleDto]): seq[Item] {.base.} =
  raise newException(ValueError, "No implementation available")