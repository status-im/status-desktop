import
  transactions, ../types

proc sendTransaction*(tx: var EthSend, password: string): string =
  let response = transactions.sendTransaction(tx, password)
  result = response.result

proc estimateGas*(tx: var EthSend): string =
  let response = transactions.estimateGas(tx)
  result = response.result