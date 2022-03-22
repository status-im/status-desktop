import strutils, json
import web3/ethtypes, web3/conversions, options, stint
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
    nonce*: Option[Nonce]        # (optional) integer of a nonce. This allows to overwrite your own pending transactions that use the same nonce
    txType*: string

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
  if x.nonce.isSome:
    result["nonce"] = %x.nonce.unsafeGet
