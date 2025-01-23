import NimQml, Tables, json, sequtils, strutils, stint, chronicles

import ./io_interface, ./path_model, ./path_item
import app_service/common/utils as common_utils
import app_service/service/eth/utils as eth_utils
import app_service/service/transaction/dto as transaction_dto
from backend/wallet import ExtraKeyPackId

export path_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      pathModel: PathModel

  proc delete*(self: View) =
    self.pathModel.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.pathModel = newPathModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getPathModel*(self: View): PathModel {.inline.} =
    return self.pathModel

  proc fetchSuggestedRoutes*(self: View,
    uuid: string,
    sendType: int,
    chainId: int,
    accountFrom: string,
    accountTo: string,
    amountIn: string,
    token: string,
    amountOut: string,
    toToken: string,
    extraParamsJson: string) {.slot.} =
    var extraParamsTable: Table[string, string]
    self.pathModel.setItems(@[])
    try:
      if extraParamsJson.len > 0:
        for key, value in parseJson(extraParamsJson):
          if key == ExtraKeyPackId:
            let bigPackId = common_utils.stringToUint256(value.getStr())
            let packIdHex = "0x" & eth_utils.stripLeadingZeros(bigPackId.toHex)
            extraParamsTable[key] = packIdHex
          else:
            extraParamsTable[key] = value.getStr()
    except Exception as e:
      error "Error parsing extraParamsJson: ", msg=e.msg

    self.delegate.suggestedRoutes(
        uuid,
        SendType(sendType),
        chainId,
        accountFrom,
        accountTo,
        token,
        false, #tokenIsOwnerToken
        amountIn,
        toToken,
        amountOut,
        extraParamsTable)

  proc stopUpdatesForSuggestedRoute*(self: View) {.slot.} =
    self.delegate.stopUpdatesForSuggestedRoute()

  proc authenticateAndTransfer*(self: View, uuid: string, fromAddr: string, slippagePercentageString: string) {.slot.} =
    var slippagePercentage: float
    try:
      if slippagePercentageString.len > 0:
        slippagePercentage = slippagePercentageString.parseFloat()
    except:
      error "parsing slippage failed", slippage=slippagePercentageString
    self.delegate.authenticateAndTransfer(uuid, fromAddr, slippagePercentage)

  proc suggestedRoutesReady*(self: View, uuid: string, pathModel: QVariant, errCode: string, errDescription: string) {.signal.}
  proc sendSuggestedRoutesReadySignal*(self: View, uuid: string, errCode: string, errDescription: string) =
    self.suggestedRoutesReady(uuid, newQVariant(self.pathModel), errCode, errDescription)

  proc transactionSendingComplete*(self: View, txHash: string, status: string) {.signal.}
  proc sendtransactionSendingCompleteSignal*(self: View, txHash: string, status: string) =
    self.transactionSendingComplete(txHash, status)

  proc transactionSent*(self: View, uuid: string, chainId: int, approvalTx: bool, txHash: string, error: string) {.signal.}
  proc sendTransactionSentSignal*(self: View, uuid: string, chainId: int, approvalTx: bool, txHash: string, error: string) =
    self.transactionSent(uuid, chainId, approvalTx, txHash, error)

  proc setFeeMode*(self: View, feeMode: int, routerInputParamsUuid: string, pathName: string, chainId: int,
    isApprovalTx: bool, communityId: string) {.slot.} =
      self.delegate.setFeeMode(feeMode, routerInputParamsUuid, pathName, chainId, isApprovalTx, communityId)

  proc setCustomTxDetails*(self: View, nonce: int, gasAmount: int, maxFeesPerGas: string, priorityFee: string,
    routerInputParamsUuid: string, pathName: string, chainId: int, isApprovalTx: bool, communityId: string) {.slot.} =
      self.delegate.setCustomTxDetails(nonce, gasAmount, maxFeesPerGas, priorityFee, routerInputParamsUuid, pathName,
        chainId, isApprovalTx, communityId)