import strformat, stint
import ../../../shared_models/currency_amount

type
  Item* = object
    id: string
    txType: string
    address: string
    blockNumber: string
    blockHash: string
    timestamp: int
    gasPrice: CurrencyAmount
    gasLimit: int
    gasUsed: int
    nonce: string
    txStatus: string
    fro: string
    to: string
    contract: string
    chainId: int
    maxFeePerGas: CurrencyAmount
    maxPriorityFeePerGas: CurrencyAmount
    input: string
    txHash: string
    multiTransactionID: int
    isTimeStamp: bool
    isNFT: bool
    baseGasFees: CurrencyAmount
    totalFees: CurrencyAmount
    maxTotalFees: CurrencyAmount
    loadingTransaction: bool
    # Applies only to isNFT == false
    value: CurrencyAmount
    symbol: string
    # Applies only to isNFT == true
    tokenID: UInt256
    nftName: string
    nftImageUrl: string

proc initItem*(
  id: string,
  txType: string,
  address: string,
  blockNumber: string,
  blockHash: string,
  timestamp: int,
  gasPrice: CurrencyAmount,
  gasLimit: int,
  gasUsed: int,
  nonce: string,
  txStatus: string,
  value: CurrencyAmount,
  fro: string,
  to: string,
  contract: string,
  chainId: int,
  maxFeePerGas: CurrencyAmount,
  maxPriorityFeePerGas: CurrencyAmount,
  input: string,
  txHash: string,
  multiTransactionID: int,
  isTimeStamp: bool,
  baseGasFees: CurrencyAmount,
  totalFees: CurrencyAmount,
  maxTotalFees: CurrencyAmount,
  symbol: string,
  loadingTransaction: bool = false
): Item =
  result.id = id
  result.txType = txType
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
  result.isNFT = false
  result.baseGasFees = baseGasFees
  result.totalFees = totalFees
  result.maxTotalFees = maxTotalFees
  result.symbol = symbol
  result.loadingTransaction = loadingTransaction

proc initNFTItem*(
  id: string,
  txType: string,
  address: string,
  blockNumber: string,
  blockHash: string,
  timestamp: int,
  gasPrice: CurrencyAmount,
  gasLimit: int,
  gasUsed: int,
  nonce: string,
  txStatus: string,
  fro: string,
  to: string,
  contract: string,
  chainId: int,
  maxFeePerGas: CurrencyAmount,
  maxPriorityFeePerGas: CurrencyAmount,
  input: string,
  txHash: string,
  multiTransactionID: int,
  baseGasFees: CurrencyAmount,
  totalFees: CurrencyAmount,
  maxTotalFees: CurrencyAmount,
  tokenID: UInt256,
  nftName: string,
  nftImageUrl: string,
  loadingTransaction: bool = false
): Item =
  result.id = id
  result.txType = txType
  result.address = address
  result.blockNumber = blockNumber
  result.blockHash = blockHash
  result.timestamp = timestamp
  result.gasPrice = gasPrice
  result.gasLimit = gasLimit
  result.gasUsed = gasUsed
  result.nonce = nonce
  result.txStatus = txStatus
  result.value = newCurrencyAmount()
  result.fro = fro
  result.to = to
  result.contract = contract
  result.chainId = chainId
  result.maxFeePerGas = maxFeePerGas
  result.maxPriorityFeePerGas = maxPriorityFeePerGas
  result.input = input
  result.txHash = txHash
  result.multiTransactionID = multiTransactionID
  result.isTimeStamp = false
  result.isNFT = true
  result.baseGasFees = baseGasFees
  result.totalFees = totalFees
  result.maxTotalFees = maxTotalFees
  result.loadingTransaction = loadingTransaction
  result.tokenID = tokenID
  result.nftName = nftName
  result.nftImageUrl = nftImageUrl

proc initLoadingItem*(): Item =
  result.timestamp = 0
  result.gasPrice = newCurrencyAmount()
  result.value = newCurrencyAmount()
  result.chainId = 0
  result.maxFeePerGas = newCurrencyAmount()
  result.maxPriorityFeePerGas = newCurrencyAmount()
  result.multiTransactionID = 0
  result.isTimeStamp = false
  result.baseGasFees = newCurrencyAmount()
  result.totalFees = newCurrencyAmount()
  result.maxTotalFees = newCurrencyAmount()
  result.loadingTransaction = true

proc `$`*(self: Item): string =
  result = fmt"""TransactionsItem(
    id: {self.id},
    txType: {self.txType},
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
    isNFT: {self.isNFT},
    baseGasFees: {self.baseGasFees},
    totalFees: {self.totalFees},
    maxTotalFees: {self.maxTotalFees},
    symbol: {self.symbol},
    loadingTransaction: {self.loadingTransaction},
    tokenID: {self.tokenID},
    nftName: {self.nftName},
    nftImageUrl: {self.nftImageUrl},
    ]"""

proc getId*(self: Item): string =
  return self.id

proc getType*(self: Item): string =
  return self.txType

proc getAddress*(self: Item): string =
  return self.address

proc getBlockNumber*(self: Item): string =
  return self.blockNumber

proc getBlockHash*(self: Item): string =
  return self.blockHash

proc getTimestamp*(self: Item): int =
  return self.timestamp

proc getGasPrice*(self: Item): CurrencyAmount =
  return self.gasPrice

proc getGasLimit*(self: Item): int =
  return self.gasLimit

proc getGasUsed*(self: Item): int =
  return self.gasUsed

proc getNonce*(self: Item): string =
  return self.nonce

proc getTxStatus*(self: Item): string =
  return self.txStatus

proc getValue*(self: Item): CurrencyAmount =
  return self.value

# TODO: fix naming
proc getfrom*(self: Item): string =
  return self.fro

proc getTo*(self: Item): string =
  return self.to

proc getContract*(self: Item): string =
  return self.contract

proc getChainId*(self: Item): int =
  return self.chainId

proc getMaxFeePerGas*(self: Item): CurrencyAmount =
  return self.maxFeePerGas

proc getMaxPriorityFeePerGas*(self: Item): CurrencyAmount =
  return self.maxPriorityFeePerGas

proc getInput*(self: Item): string =
  return self.input

proc getTxHash*(self: Item): string =
  return self.txHash

proc getMultiTransactionID*(self: Item): int =
  return self.multiTransactionID

proc getIsTimeStamp*(self: Item): bool =
  return self.isTimeStamp

proc getIsNFT*(self: Item): bool =
  return self.isNFT

proc getBaseGasFees*(self: Item): CurrencyAmount =
  return self.baseGasFees

proc getTotalFees*(self: Item): CurrencyAmount =
  return self.totalFees

proc getMaxTotalFees*(self: Item): CurrencyAmount =
  return self.maxTotalFees  

proc getSymbol*(self: Item): string =
  return self.symbol

proc getLoadingTransaction*(self: Item): bool =
  return self.loadingTransaction

proc  getTokenID*(self: Item): UInt256 =
  return self.tokenID

proc  getNFTName*(self: Item): string =
  return self.nftName

proc  getNFTImageURL*(self: Item): string =
  return self.nftImageUrl
