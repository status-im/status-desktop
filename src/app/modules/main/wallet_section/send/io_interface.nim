import stint
import app/modules/shared_models/currency_amount
import app_service/service/transaction/dto
import app/modules/shared_models/collectibles_model as collectibles
import app/modules/shared_models/collectibles_nested_model as nested_collectibles
from app_service/service/keycard/service import KeycardEvent

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

method suggestedRoutes*(self: AccessInterface, accountFrom: string, accountTo: string, amount: UInt256, token: string, disabledFromChainIDs,
  disabledToChainIDs, preferredChainIDs: seq[int], sendType: SendType, lockedInAmounts: string): string {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutesReady*(self: AccessInterface, suggestedRoutes: SuggestedRoutesDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndTransfer*(self: AccessInterface, from_addr: string, to_addr: string,
    tokenSymbol: string, value: string, uuid: string, sendType: SendType, selectedTokenName: string, selectedTokenIsOwnerToken: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(self: AccessInterface, chainId: int = 0, txHash, uuid, error: string = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedSenderAccountIndex*(self: AccessInterface, index: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedReceiveAccountIndex*(self: AccessInterface, index: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(self: AccessInterface, addresses: seq[string], chainIds: seq[int]) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectiblesModel*(self: AccessInterface): collectibles.Model {.base.} =
  raise newException(ValueError, "No implementation available")

method getNestedCollectiblesModel*(self: AccessInterface): nested_collectibles.Model {.base.} =
  raise newException(ValueError, "No implementation available")

method splitAndFormatAddressPrefix*(self: AccessInterface, text : string, updateInStore: bool): string {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareSignaturesForTransactions*(self: AccessInterface, txHashes: seq[string]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTransactionSigned*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")
