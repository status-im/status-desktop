import strutils, json
import web3/eth_api_types, web3/conversions, options, stint
import ../utils

type
  TransactionDataDto* = object
    source*: Address             # the address the transaction is send from.
    to*: Option[Address]         # (optional when creating new contract) the address the transaction is directed to.
    gas*: Option[Quantity]            # (optional, default: 90000) integer of the gas provided for the transaction execution. It will return unused gas.
    gasPrice*: Option[int]       # (optional, default: To-Be-Determined) integer of the gasPrice used for each paid gas.
    maxPriorityFeePerGas*: Option[Uint256]
    maxFeePerGas*: Option[Uint256]
    value*: Option[Uint256]          # (optional) integer of the value sent with this transaction.
    data*: string                # the compiled code of a contract OR the hash of the invoked proc signature and encoded parameters. For details see Ethereum Contract ABI.
    input*: string
    nonce*: Option[Quantity]        # (optional) integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce
    txType*: string

    chainID*: Option[int]     # (optional) source chainID
    chainIDTo*: Option[int]     # (optional) destination chainID
    symbol*: Option[string]      # (optional) symbol in case of a bridge hop transaction
    recipient*: Option[Address]  # (optional) recipient in case of a bridge hop transaction
    amount*: Option[UInt256]         # (optional) amount in case of a bridge hop transaction
    amountOutMin*: Option[UInt256]   # (optional) amountOutMin in case of a bridge hop transaction
    bonderFee*: Option[UInt256]      # (optional) bonderFee in case of a bridge hop transaction

    tokenID*: Option[UInt256]     # (optional) chainID in case of a ERC721 transaction

    tokenIdFrom*: Option[string]    # (optional) source token symbol
    tokenIdTo*: Option[string]    # (optional) destination token symbol
    slippagePercentage*: Option[float]    # (optional) max slippage percentage allowed in case of a Swap transaction

proc `%`*(x: TransactionDataDto): JsonNode =
  result = newJobject()
  result["from"] = %x.source
  result["type"] = %x.txType
  if x.to.isSome:
    result["to"] = %x.to.unsafeGet
  if x.gas.isSome:
    result["gas"] = %x.gas.unsafeGet
  if x.gasPrice.isSome:
    result["gasPrice"] = %("0x" & x.gasPrice.unsafeGet.toHex.stripLeadingZeros)
  if x.maxFeePerGas.isSome:
    result["maxFeePerGas"] = %("0x" & x.maxFeePerGas.unsafeGet.toHex)
  if x.maxPriorityFeePerGas.isSome:
    result["maxPriorityFeePerGas"] = %("0x" & x.maxPriorityFeePerGas.unsafeGet.toHex)
  if x.value.isSome:
    result["value"] = %("0x" & x.value.unsafeGet.toHex)
  result["data"] = %x.data
  result["input"] = %x.input
  if x.nonce.isSome:
    result["nonce"] = %x.nonce.unsafeGet
  if x.chainID.isSome:
    result["chainId"] = %x.chainID.unsafeGet
  if x.chainIDTo.isSome:
    result["chainIdTo"] = %x.chainIDTo.unsafeGet
  if x.symbol.isSome:
    result["symbol"] = %x.symbol.unsafeGet
  if x.recipient.isSome:
    result["recipient"] = %x.recipient.unsafeGet
  if x.amount.isSome:
    result["amount"] = %x.amount.unsafeGet
  if x.amountOutMin.isSome:
    result["amountOutMin"] = %x.amountOutMin.unsafeGet
  if x.bonderFee.isSome:
    result["bonderFee"] = %x.bonderFee.unsafeGet
  if x.tokenID.isSome:
    result["tokenID"] = %x.tokenID.unsafeGet
  if x.tokenIdFrom.isSome:
    result["tokenIdFrom"] = %x.tokenIdFrom.unsafeGet
  if x.tokenIdTo.isSome:
    result["tokenIdTo"] = %x.tokenIdTo.unsafeGet
  if x.slippagePercentage.isSome:
    result["slippagePercentage"] = %x.slippagePercentage.unsafeGet
