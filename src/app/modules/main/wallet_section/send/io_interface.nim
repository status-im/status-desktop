import Tables
import app/modules/shared_models/currency_amount
import app_service/service/transaction/dto
import app_service/service/transaction/router_transactions_dto
import app_service/service/network/network_item
import app/modules/shared_models/collectibles_model as collectibles
from app_service/service/keycard/service import KeycardEvent

type AccessInterface* {.pure, inheritable.} = ref object of RootObj
  ## Abstract class for any input/interaction with this module.

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method isLoaded*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method getTokenBalance*(
    self: AccessInterface, address: string, chainId: int, tokensKey: string
): CurrencyAmount {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutes*(
    self: AccessInterface,
    uuid: string,
    sendType: SendType,
    accountFrom: string,
    accountTo: string,
    token: string,
    tokenIsOwnerToken: bool,
    amountIn: string,
    toToken: string = "",
    amountOut: string = "",
    disabledFromChainIDs: seq[int] = @[],
    disabledToChainIDs: seq[int] = @[],
    lockedInAmounts: Table[string, string] = initTable[string, string](),
    extraParamsTable: Table[string, string] = initTable[string, string](),
) {.base.} =
  raise newException(ValueError, "No implementation available")

method stopUpdatesForSuggestedRoute*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutesReady*(
    self: AccessInterface,
    uuid: string,
    suggestedRoutes: SuggestedRoutesDto,
    errCode: string,
    errDescription: string,
) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndTransfer*(
    self: AccessInterface, fromAddr: string, uuid: string, slippagePercentage: float
) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(
    self: AccessInterface, password: string, pin: string
) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(
    self: AccessInterface,
    uuid: string,
    chainId: int = 0,
    approvalTx: bool = false,
    txHash: string = "",
    error: string = "",
) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(
    self: AccessInterface, pin: string, password: string, keyUid: string
) {.base.} =
  raise newException(ValueError, "No implementation available")

method setSelectedReceiveAccountIndex*(self: AccessInterface, index: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method filterChanged*(
    self: AccessInterface, addresses: seq[string], chainIds: seq[int], isDirty: bool
) {.base.} =
  raise newException(ValueError, "No implementation available")

method getCollectiblesModel*(self: AccessInterface): collectibles.Model {.base.} =
  raise newException(ValueError, "No implementation available")

method splitAndFormatAddressPrefix*(
    self: AccessInterface, text: string, updateInStore: bool
): string {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareSignaturesForTransactions*(
    self: AccessInterface, txForSigning: RouterTransactionsForSigningDto
) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTransactionSigned*(
    self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent
) {.base.} =
  raise newException(ValueError, "No implementation available")

method hasGas*(
    self: AccessInterface,
    accountAddress: string,
    chainId: int,
    nativeGasSymbol: string,
    requiredGas: float,
): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionSendingComplete*(
    self: AccessInterface, txHash: string, status: string
) {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworkItem*(self: AccessInterface, chainId: int): NetworkItem {.base.} =
  raise newException(ValueError, "No implementation available")

method getNetworkChainId*(self: AccessInterface, shortName: string): int {.base.} =
  raise newException(ValueError, "No implementation available")
