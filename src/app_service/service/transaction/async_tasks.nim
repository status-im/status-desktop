#################################################
# Async load transactions
#################################################

import stint
import ../../../backend/backend as backend

type GetSuggestedRoutesTaskArg* = ref object of QObjectTaskArg
  accountFrom: string
  accountTo: string
  amount: Uint256
  token: string
  toToken: string # used for swap only
  disabledFromChainIDs: seq[int]
  disabledToChainIDs: seq[int]
  preferredChainIDs: seq[int]
  sendType: SendType
  lockedInAmounts: string

type WatchTransactionTaskArg* = ref object of QObjectTaskArg
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

proc watchTransactionTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[WatchTransactionTaskArg](argEncoded)
  try:
    let output =
      %*{
        "hash": arg.hash,
        "data": arg.data,
        "address": arg.address,
        "chainId": arg.chainId,
        "trxType": arg.trxType,
        "txType": arg.txType,
        "toAddress": arg.toAddress,
        "fromTokenKey": arg.fromTokenKey,
        "fromAmount": arg.fromAmount,
        "toTokenKey": arg.toTokenKey,
        "toAmount": arg.toAmount,
        "isSuccessfull":
          transactions.watchTransaction(arg.chainId, arg.hash).error.isNil,
      }
    arg.finish(output)
  except Exception as e:
    let output =
      %*{
        "hash": arg.hash,
        "data": arg.data,
        "address": arg.address,
        "chainId": arg.chainId,
        "trxType": arg.trxType,
        "txType": arg.txType,
        "toAddress": arg.toAddress,
        "fromTokenKey": arg.fromTokenKey,
        "fromAmount": arg.fromAmount,
        "toTokenKey": arg.toTokenKey,
        "toAmount": arg.toAmount,
        "isSuccessfull": false,
      }

type FetchDecodedTxDataTaskArg* = ref object of QObjectTaskArg
  txHash: string
  data: string

proc fetchDecodedTxDataTask*(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[FetchDecodedTxDataTaskArg](argEncoded)
  var data = %*{"txHash": arg.txHash}
  try:
    let response = backend.fetchDecodedTxData(arg.data)
    data["result"] = response.result
  except Exception as e:
    error "Error decoding tx input", message = e.msg
  arg.finish(data)
