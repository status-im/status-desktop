import
  web3/ethtypes

import
  transactions, ../types

proc sendTransaction*(tx: var EthSend, password: string, success: var bool): string =
  success = true
  try:
    let response = transactions.sendTransaction(tx, password)
    result = response.result
  except RpcException as e:
    success = false
    result = e.msg

proc estimateGas*(tx: var EthSend, success: var bool): string =
  success = true
  try:
    let response = transactions.estimateGas(tx)
    result = response.result
  except RpcException as e:
    success = false
    result = e.msg