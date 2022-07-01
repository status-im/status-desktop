import stint
import ../../../../../app_service/service/wallet_account/dto as WalletDto
import ../../../../../app_service/service/transaction/dto
export TransactionDto

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRecentHistory*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchAccount*(self: AccessInterface, accountIndex: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: AccessInterface): seq[WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getAccountByAddress*(self: AccessInterface, address: string): WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTransactions*(self: AccessInterface, address: string, toBlock: string, limit: int, loadMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setTrxHistoryResult*(self: AccessInterface, transactions: seq[TransactionDto], address: string, wasFetchMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setHistoryFetchState*(self: AccessInterface, addresses: seq[string], isFetching: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setIsNonArchivalNode*(self: AccessInterface, isNonArchivalNode: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method estimateGas*(self: AccessInterface, from_addr: string, to: string, assetSymbol: string, value: string, data: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method transfer*(self: AccessInterface, from_addr: string, to_addr: string,
    tokenSymbol: string, value: string, gas: string, gasPrice: string,
    maxPriorityFeePerGas: string, maxFeePerGas: string, password: string,
    chainId: string, uuid: string, eip1559Enabled: bool): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(self: AccessInterface, result: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedFees*(self: AccessInterface, chainId: int): string {.base.} = 
  raise newException(ValueError, "No implementation available")

method suggestedRoutes*(self: AccessInterface, account: string, amount: float64, token: string, disabledChainIDs: seq[uint64]): string {.base.} =
  raise newException(ValueError, "No implementation available")

method getChainIdForChat*(self: AccessInterface): int =
  raise newException(ValueError, "No implementation available")

method getChainIdForBrowser*(self: AccessInterface): int =
  raise newException(ValueError, "No implementation available")

method getEstimatedTime*(self: AccessInterface, chainId: int, maxFeePerGas: string): int {.base.} = 
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")
