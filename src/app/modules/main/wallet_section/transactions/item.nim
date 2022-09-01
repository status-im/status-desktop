import strformat

type
  Item* = object
    id: string
    typ: string
    address: string
    blockNumber: string
    blockHash: string
    timestamp: int
    gasPrice: string
    gasLimit: string
    gasUsed: string
    nonce: string
    txStatus: string
    value: string
    fro: string
    to: string
    contract: string
    chainId: int
    maxFeePerGas: string
    maxPriorityFeePerGas: string
    input: string
    txHash: string
    multiTransactionID: int
    isTimeStamp: bool

proc initItem*(
  id: string,
  typ: string,
  address: string,
  blockNumber: string,
  blockHash: string,
  timestamp: int,
  gasPrice: string,
  gasLimit: string,
  gasUsed: string,
  nonce: string,
  txStatus: string,
  value: string,
  fro: string,
  to: string,
  contract: string,
  chainId: int,
  maxFeePerGas: string,
  maxPriorityFeePerGas: string,
  input: string,
  txHash: string,
  multiTransactionID: int,
  isTimeStamp: bool
): Item =
  result.id = id
  result.typ = typ
  result.address = address
  result.blockNumber = blockNumber
  result.blockHash = blockHash
  result.timestamp = timestamp
  result.gasPrice = gasPrice
  result.gasLimit = gasLimit
  result.gasUsed = gasUsed
  result.nonce = nonce
  result.txStatus = txStatus
  result.value = value
  result.fro = fro
  result.to = to
  result.contract = contract
  result.chainId = chainId
  result.maxFeePerGas = maxFeePerGas
  result.maxPriorityFeePerGas = maxPriorityFeePerGas
  result.input = input
  result.txHash = txHash
  result.multiTransactionID = multiTransactionID
  result.isTimeStamp = isTimeStamp

proc `$`*(self: Item): string =
  result = fmt"""AllTokensItem(
    id: {self.id},
    type: {self.typ},
    address: {self.address},
    blockNumber: {self.blockNumber},
    blockHash: {self.blockHash},
    timestamp: {self.timestamp},
    gasPrice: {self.gasPrice},
    gasLimit: {self.gasLimit},
    gasUsed: {self.gasUsed},
    nonce: {self.nonce},
    txStatus: {self.txStatus},
    value: {self.value},
    fro: {self.fro},
    to: {self.to},
    contract: {self.contract},
    chainId: {self.chainId},
    maxFeePerGas: {self.maxFeePerGas},
    maxPriorityFeePerGas: {self.maxPriorityFeePerGas},
    input: {self.input},
    txHash: {self.txHash},
    multiTransactionID: {self.multiTransactionID},
    isTimeStamp: {self.isTimeStamp},
    ]"""

proc getId*(self: Item): string =
  return self.id

proc getType*(self: Item): string =
  return self.typ

proc getAddress*(self: Item): string =
  return self.address

proc getBlockNumber*(self: Item): string =
  return self.blockNumber

proc getBlockHash*(self: Item): string =
  return self.blockHash

proc getTimestamp*(self: Item): int =
  return self.timestamp

proc getGasPrice*(self: Item): string =
  return self.gasPrice

proc getGasLimit*(self: Item): string =
  return self.gasLimit

proc getGasUsed*(self: Item): string =
  return self.gasUsed

proc getNonce*(self: Item): string =
  return self.nonce

proc getTxStatus*(self: Item): string =
  return self.txStatus

proc getValue*(self: Item): string =
  return self.value

proc getfrom*(self: Item): string =
  return self.fro

proc getTo*(self: Item): string =
  return self.to

proc getContract*(self: Item): string =
  return self.contract

proc getChainId*(self: Item): int =
  return self.chainId

proc getMaxFeePerGas*(self: Item): string =
  return self.maxFeePerGas

proc getMaxPriorityFeePerGas*(self: Item): string =
  return self.maxPriorityFeePerGas

proc  getInput*(self: Item): string =
  return self.input

proc  getTxHash*(self: Item): string =
  return self.txHash

proc  getMultiTransactionID*(self: Item): int =
  return self.multiTransactionID

proc  getIsTimeStamp*(self: Item): bool =
  return self.isTimeStamp
