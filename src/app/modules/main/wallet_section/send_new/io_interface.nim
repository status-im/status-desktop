import Tables

import app_service/service/transaction/dto
import app_service/service/transaction/router_transactions_dto
import app_service/service/transaction/dtoV2
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

method suggestedRoutes*(self: AccessInterface,
  uuid: string,
  sendType: SendType,
  chainId: int,
  accountFrom: string,
  accountTo: string,
  token: string,
  tokenIsOwnerToken: bool,
  amountIn: string,
  toToken: string = "",
  amountOut: string = "",
  extraParamsTable: Table[string, string] = initTable[string, string]()) {.base.} =
    raise newException(ValueError, "No implementation available")

method stopUpdatesForSuggestedRoute*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateAndTransfer*(self: AccessInterface, fromAddr: string, uuid: string, slippagePercentage: float) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, password: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method suggestedRoutesReady*(self: AccessInterface, uuid: string, routes: seq[TransactionPathDtoV2], errCode: string, errDescription: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionWasSent*(self: AccessInterface, uuid: string, chainId: int = 0, approvalTx: bool = false, txHash: string = "", error: string = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method authenticateUser*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onUserAuthenticated*(self: AccessInterface, pin: string, password: string, keyUid: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method prepareSignaturesForTransactions*(self:AccessInterface, txForSigning: RouterTransactionsForSigningDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onTransactionSigned*(self: AccessInterface, keycardFlowType: string, keycardEvent: KeycardEvent) {.base.} =
  raise newException(ValueError, "No implementation available")

method transactionSendingComplete*(self: AccessInterface, txHash: string, status: string) {.base.} =
  raise newException(ValueError, "No implementation available")
