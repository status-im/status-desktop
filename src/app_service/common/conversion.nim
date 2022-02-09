import strutils, strformat, stint, chronicles
from web3 import Address, fromHex

proc parseAddress*(strAddress: string): Address =
  fromHex(Address, strAddress)

proc isAddress*(strAddress: string): bool =
  try:
    discard parseAddress(strAddress)
  except:
    return false
  return true

proc toStUInt*[bits: static[int]](flt: float, T: typedesc[StUint[bits]]): T =
  var stringValue =  fmt"{flt:<.0f}"
  stringValue.removeSuffix('.')
  if (flt >= 0):
    result = parse($stringValue, StUint[bits])
  else:
    result = parse("0", StUint[bits])

proc toUInt256*(flt: float): UInt256 =
  toStUInt(flt, StUInt[256])

proc toUInt64*(flt: float): StUInt[64] =
  toStUInt(flt, StUInt[64])

proc eth2Wei*(eth: float, decimals: int = 18): UInt256 =
  let weiValue = eth * parseFloat(alignLeft("1", decimals + 1, '0'))
  weiValue.toUInt256

proc gwei2Wei*(gwei: float): UInt256 =
  eth2Wei(gwei, 9)

proc wei2Eth*(input: Stuint[256], decimals: int = 18): string =
  var one_eth = u256(10).pow(decimals) # fromHex(Stuint[256], "DE0B6B3A7640000")

  var (eth, remainder) = divmod(input, one_eth)
  let leading_zeros = "0".repeat(($one_eth).len - ($remainder).len - 1)

  fmt"{eth}.{leading_zeros}{remainder}"

proc wei2Eth*(input: string, decimals: int): string =
  try:
    var input256: Stuint[256]
    if input.contains("e+"): # we have a js string BN, ie 1e+21
      let
        inputSplit = input.split("e+")
        whole = inputSplit[0].u256
        remainder = u256(10).pow(inputSplit[1].parseInt)
      input256 = whole * remainder
    else:
      input256 = input.u256
    result = wei2Eth(input256, decimals)
  except Exception as e:
    error "Error parsing this wei value", input, msg=e.msg
    result = "0"

proc wei2Gwei*(input: string): string =
  result = wei2Eth(input, 9)
