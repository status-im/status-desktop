import NimQML, stint
import ../../../../../app_service/service/wallet_account/dto

type 
  AccessInterface* {.pure inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method init*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method checkRecentHistory*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method getWalletAccounts*(self: AccessInterface): seq[WalletAccountDto] {.base.} =
  raise newException(ValueError, "No implementation available")

method getAccountByAddress*(self: AccessInterface, address: string): WalletAccountDto {.base.} =
  raise newException(ValueError, "No implementation available")

method loadTransactions*(self: AccessInterface, address: string, toBlock: Uint256, limit: int, loadMore: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method setTrxHistoryResult*(self: AccessInterface, historyJSON: string) {.base.} =
  raise newException(ValueError, "No implementation available")

type
  ## Abstract class (concept) which must be implemented by object/s used in this 
  ## module.
  DelegateInterface* = concept c
    