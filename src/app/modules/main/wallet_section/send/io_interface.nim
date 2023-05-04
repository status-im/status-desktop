import stint
import ../../../shared_models/currency_amount

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method refreshWalletAccounts*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenBalanceOnChain*(self: AccessInterface, address: string, chainId: int, symbol: string): CurrencyAmount {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutes*(self: AccessInterface, account: string, amount: UInt256, token: string, disabledFromChainIDs, disabledToChainIDs, preferredChainIDs: seq[uint64], sendType: int, lockedInAmounts: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutesReady*(self: AccessInterface, suggestedRoutes: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getEstimatedTime*(self: AccessInterface, chainId: int, maxFeePerGas: string): int {.base.} = 
  raise newException(ValueError, "No implementation available")

method suggestedFees*(self: AccessInterface, chainId: int): string {.base.} = 
  raise newException(ValueError, "No implementation available")

method authenticateAndTransfer*(self: AccessInterface, from_addr: string, to_addr: string,
    tokenSymbol: string, value: string, uuid: string, selectedRoutes: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(self: AccessInterface, result: string) {.base.} =
  raise newException(ValueError, "No implementation available")

# View Delegate Interface
# Delegate for the view must be declared here due to use of QtObject and multi
# inheritance, which is not well supported in Nim.
method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchAccount*(self: AccessInterface, accountIndex: int) =
  raise newException(ValueError, "No implementation available")

method setSelectedSenderAccountIndex*(self: AccessInterface, index: int) =
  raise newException(ValueError, "No implementation available")

method setSelectedReceiveAccountIndex*(self: AccessInterface, index: int) =
  raise newException(ValueError, "No implementation available")
