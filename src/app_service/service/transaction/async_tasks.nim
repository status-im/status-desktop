#################################################
# Async load transactions
#################################################

import stint
import ../../../backend/backend as backend

type
  GetSuggestedRoutesTaskArg* = ref object of QObjectTaskArg
    accountFrom: string
    accountTo: string
    amount: Uint256
    token: string
    toToken: string # used for swap only
    disabledFromChainIDs: seq[int]
    disabledToChainIDs: seq[int]
    preferredChainIDs: seq[int]
    sendType: SendType

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
