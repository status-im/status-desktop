#################################################
# Async load transactions
#################################################

import stint
import ../../../backend/backend as backend

type
  WatchTransactionTaskArg* = ref object of QObjectTaskArg
    data: string
    hash: string
    chainId: int
    address: string
    trxType: string
    txType: int
    toAddress: string
    fromTokenKey: string
    fromAmount: string
    toTokenKey: string
    toAmount: string


type
  FetchDecodedTxDataTaskArg* = ref object of QObjectTaskArg
    txHash: string
    data: string

proc fetchDecodedTxDataTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDecodedTxDataTaskArg](argEncoded)
  var data = %* {
    "txHash": arg.txHash
  }
  try:
    let response = backend.fetchDecodedTxData(arg.data)
    data["result"] = response.result
  except Exception as e:
    error "Error decoding tx input", message = e.msg
  arg.finish(data)

type
  ReevaluateRouterPathTaskArg* = ref object of QObjectTaskArg
    uuid: string
    pathName: string
    chainId: int
    isApprovalTx: bool

proc reevaluateRouterPathTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[ReevaluateRouterPathTaskArg](argEncoded)
  try:
    let err = wallet.reevaluateRouterPath(arg.uuid, arg.pathName, arg.chainId, arg.isApprovalTx)
    if err.len > 0:
      raise newException(CatchableError, err)
  except CatchableError as e:
    error "reevaluateRouterPath", exception=e.msg
