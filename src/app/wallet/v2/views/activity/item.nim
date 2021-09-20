import strformat

type WalletActivityItem* = object
  id: string
  sectionName: string
  networkId: int
  networkName: string
  tokenSymbol: string
  tokenName: string
  tokenIcon: string
  `type`: string
  transactionHash: string
  transactionStatus: string
  blockNumber: string
  blockHash: string
  contract: string
  nonce: string
  amount: string
  fromAddress: string
  toAddress: string
  forAmount: string
  gasLimit: string
  gasUsed: string
  gasPrice: string
  total: string
  inputData: string
  timestamp: int64

proc initWalletActivityItem*(id, sectionName: string, networkId: int, networkName, tokenSymbol, 
  tokenName, tokenIcon, `type`, transactionHash, transactionStatus, blockNumber, 
  blockHash, contract, nonce, amount, fromAddress, toAddress, forAmount, gasLimit, 
  gasUsed, gasPrice, total, inputData: string, timestamp: int64): WalletActivityItem =

  result.id = id
  result.sectionName = sectionName
  result.networkId = networkId
  result.networkName = networkName
  result.tokenSymbol = tokenSymbol
  result.tokenName = tokenName
  result.tokenIcon = tokenIcon
  result.`type` = `type`
  result.transactionHash = transactionHash
  result.transactionStatus = transactionStatus
  result.blockNumber = blockNumber
  result.blockHash = blockHash
  result.contract = contract
  result.nonce = nonce
  result.amount = amount
  result.fromAddress = fromAddress
  result.toAddress = toAddress
  result.forAmount = forAmount
  result.gasLimit = gasLimit
  result.gasUsed = gasUsed
  result.gasPrice = gasPrice
  result.total = total
  result.inputData = inputData
  result.timestamp = timestamp

proc `$`*(self: WalletActivityItem): string =
  result = "WalletActivityItem("
  result &= fmt"id:{self.id}, "
  result &= fmt"sectionName:{self.sectionName}, "
  result &= fmt"networkId:{self.networkId}, "
  result &= fmt"networkName:{self.networkName}, "
  result &= fmt"tokenSymbol:{self.tokenSymbol}, "
  result &= fmt"tokenName:{self.tokenName}, "
  result &= fmt"tokenIcon:{self.tokenIcon}, "
  result &= fmt"type:{self.`type`}, "
  result &= fmt"transactionHash:{self.transactionHash}, "
  result &= fmt"transactionStatus:{self.transactionStatus}, "  
  result &= fmt"blockNumber:{self.blockNumber}, "
  result &= fmt"blockHash:{self.blockHash}, "
  result &= fmt"contract:{self.contract}, "
  result &= fmt"nonce:{self.nonce}, "
  result &= fmt"amount:{self.amount}, "
  result &= fmt"fromAddress:{self.fromAddress}, "
  result &= fmt"toAddress:{self.toAddress}, "
  result &= fmt"forAmount:{self.forAmount}, "
  result &= fmt"gasLimit:{self.gasLimit}, "
  result &= fmt"gasUsed:{self.gasUsed}, "
  result &= fmt"gasPrice:{self.gasPrice}, "
  result &= fmt"total:{self.total}, "
  result &= fmt"inputData:{self.inputData}, "
  result &= fmt"timestamp:{self.timestamp}"
  result &= ")"

method getId*(self: WalletActivityItem): string {.base.} =
  return self.id

method getSectionName*(self: WalletActivityItem): string {.base.} =
  return self.sectionName

method getNetworkId*(self: WalletActivityItem): int {.base.} =
  return self.networkId

method getNetworkName*(self: WalletActivityItem): string {.base.} =
  return self.networkName

method getTokenSymbol*(self: WalletActivityItem): string {.base.} =
  return self.tokenSymbol

method getTokenName*(self: WalletActivityItem): string {.base.} =
  return self.tokenName

method getTokenIcon*(self: WalletActivityItem): string {.base.} =
  return self.tokenIcon

method getType*(self: WalletActivityItem): string {.base.} =
  return self.`type`

method getTransactionHash*(self: WalletActivityItem): string {.base.} =
  return self.transactionHash

method getTransactionStatus*(self: WalletActivityItem): string {.base.} =
  return self.transactionStatus

method getBlockNumber*(self: WalletActivityItem): string {.base.} =
  return self.blockNumber

method getBlockHash*(self: WalletActivityItem): string {.base.} =
  return self.blockHash

method getContract*(self: WalletActivityItem): string {.base.} =
  return self.contract

method getNonce*(self: WalletActivityItem): string {.base.} =
  return self.nonce

method getAmount*(self: WalletActivityItem): string {.base.} =
  return self.amount

method getFromAddress*(self: WalletActivityItem): string {.base.} =
  return self.fromAddress

method getToAddress*(self: WalletActivityItem): string {.base.} =
  return self.toAddress

method getForAmount*(self: WalletActivityItem): string {.base.} =
  return self.forAmount

method getGasLimit*(self: WalletActivityItem): string {.base.} =
  return self.gasLimit

method getGasUsed*(self: WalletActivityItem): string {.base.} =
  return self.gasUsed

method getGasPrice*(self: WalletActivityItem): string {.base.} =
  return self.gasPrice

method getTotal*(self: WalletActivityItem): string {.base.} =
  return self.total

method getInputData*(self: WalletActivityItem): string {.base.} =
  return self.inputData

method getTimestamp*(self: WalletActivityItem): int64 {.base.} =
  return self.timestamp