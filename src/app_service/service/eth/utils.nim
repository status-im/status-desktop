import 
  atomics, json, tables, sequtils, httpclient, net
import json, random, strutils, strformat, tables, chronicles, unicode, times
import 
  json_serialization, chronicles, libp2p/[multihash, multicodec, cid], stint, nimcrypto
from sugar import `=>`, `->`
import stint
from times import getTime, toUnix, nanosecond
import signing_phrases
from web3 import Address, fromHex
import web3/ethhexstrings

proc decodeContentHash*(value: string): string =
  if value == "":
    return ""

  # eg encoded sticker multihash cid:
  #  e30101701220eab9a8ef4eac6c3e5836a3768d8e04935c10c67d9a700436a0e53199e9b64d29
  #  e3017012205c531b83da9dd91529a4cf8ecd01cb62c399139e6f767e397d2f038b820c139f (testnet)
  #  e3011220c04c617170b1f5725070428c01280b4c19ae9083b7e6d71b7a0d2a1b5ae3ce30 (testnet)
  #
  # The first 4 bytes (in hex) represent:
  # e3 = codec identifier "ipfs-ns" for content-hash
  # 01 = unused - sometimes this is NOT included (ie ropsten)
  # 01 = CID version (effectively unused, as we will decode with CIDv0 regardless)
  # 70 = codec identifier "dag-pb"

  # ipfs-ns
  if value[0..1] != "e3":
    warn "Could not decode sticker. It may still be valid, but requires a different codec to be used", hash=value
    return ""

  try:
    # dag-pb
    let defaultCodec = parseHexInt("70") #dag-pb
    var codec = defaultCodec # no codec specified
    var codecStartIdx = 2 # idx of where codec would start if it was specified
    # handle the case when starts with 0xe30170 instead of 0xe3010170
    if value[2..5] == "0101":
      codecStartIdx = 6
      codec = parseHexInt(value[6..7])
    elif value[2..3] == "01" and value[4..5] != "12":
      codecStartIdx = 4
      codec = parseHexInt(value[4..5])

    # strip the info we no longer need
    var multiHashStr = value[codecStartIdx + 2..<value.len]

    # The rest of the hash identifies the multihash algo, length, and digest
    # More info: https://multiformats.io/multihash/
    # 12 = identifies sha2-256 hash
    # 20 = multihash length = 32
    # ...rest = multihash digest
    let multiHash = MultiHash.init(nimcrypto.fromHex(multiHashStr)).get()
    let resultTyped = Cid.init(CIDv0, MultiCodec.codec(codec), multiHash).get()
    result = $resultTyped
    trace "Decoded sticker hash", cid=result
  except Exception as e:
    error "Error decoding sticker", hash=value, exception=e.msg
    raise

proc getTimelineChatId*(pubKey: string = ""): string =
  if pubKey == "":
    return "@timeline70bd746ddcc12beb96b2c9d572d0784ab137ffc774f5383e50585a932080b57cca0484b259e61cecbaa33a4c98a300a"
  else:
    return "@" & pubKey

proc isWakuEnabled(): bool =
  true # TODO:

proc prefix*(methodName: string, isExt:bool = true): string =
  result = if isWakuEnabled(): "waku" else: "shh" 
  result = result & (if isExt: "ext_" else: "_")
  result = result & methodName

proc isOneToOneChat*(chatId: string): bool =
  result = chatId.startsWith("0x") # There is probably a better way to do this

proc keys*(obj: JsonNode): seq[string] =
  result = newSeq[string]()
  for k, _ in obj:
    result.add k

proc generateSigningPhrase*(count: int): string =
  let now = getTime()
  var rng = initRand(now.toUnix * 1000000000 + now.nanosecond)
  var phrases: seq[string] = @[]
  
  for i in 1..count:
    phrases.add(rng.sample(signing_phrases.phrases))

  result = phrases.join(" ")

proc handleRPCErrors*(response: string) =
  let parsedReponse = parseJson(response)
  if (parsedReponse.hasKey("error")):
    raise newException(ValueError, parsedReponse["error"]["message"].str)

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

proc first*(jArray: JsonNode, fieldName, id: string): JsonNode =
  if jArray == nil:
    return nil
  if jArray.kind != JArray:
    raise newException(ValueError, "Parameter 'jArray' is a " & $jArray.kind & ", but must be a JArray")
  for child in jArray.getElems:
    if child{fieldName}.getStr.toLower == id.toLower:
      return child

proc any*(jArray: JsonNode, fieldName, id: string): bool =
  if jArray == nil:
    return false
  result = false
  for child in jArray.getElems:
    if child{fieldName}.getStr.toLower == id.toLower:
      return true

proc isEmpty*(a: JsonNode): bool =
  case a.kind:
  of JObject: return a.fields.len == 0
  of JArray: return a.elems.len == 0
  of JString: return a.str == ""
  of JNull: return true
  else:
    return false

proc find*[T](s: seq[T], pred: proc(x: T): bool {.closure.}): T {.inline.} =
  let results = s.filter(pred)
  if results.len == 0:
    return default(type(T))
  result = results[0]

proc find*[T](s: seq[T], pred: proc(x: T): bool {.closure.}, found: var bool): T {.inline.} =
  let results = s.filter(pred)
  if results.len == 0:
    found = false
    return default(type(T))
  result = results[0]
  found = true

proc parseAddress*(strAddress: string): Address =
  fromHex(Address, strAddress)

proc isAddress*(strAddress: string): bool =
  try:
    discard parseAddress(strAddress)
  except:
    return false
  return true

proc validateTransactionInput*(from_addr, to_addr, assetAddress, value, gas, gasPrice, data: string, isEIP1599Enabled: bool, maxPriorityFeePerGas, maxFeePerGas, uuid: string) =
  if not isAddress(from_addr): raise newException(ValueError, "from_addr is not a valid ETH address")
  if not isAddress(to_addr): raise newException(ValueError, "to_addr is not a valid ETH address")
  if parseFloat(value) < 0: raise newException(ValueError, "value should be a number >= 0")
  if parseInt(gas) <= 0: raise newException(ValueError, "gas should be a number > 0")
  if isEIP1599Enabled:
    if gasPrice != "" and (maxPriorityFeePerGas != "" or maxFeePerGas != ""): 
      raise newException(ValueError, "gasPrice can't be used with maxPriorityFeePerGas and maxFeePerGas")
    if gasPrice == "": 
      if parseFloat(maxPriorityFeePerGas) <= 0: raise newException(ValueError, "maxPriorityFeePerGas should be a number > 0")
      if parseFloat(maxFeePerGas) <= 0: raise newException(ValueError, "maxFeePerGas should be a number > 0")
  else:
    if parseFloat(gasPrice) <= 0: raise newException(ValueError, "gasPrice should be a number > 0")
  if uuid.isEmptyOrWhitespace(): raise newException(ValueError, "uuid is required")

  if assetAddress != "": # If a token is being used
    if not isAddress(assetAddress): raise newException(ValueError, "assetAddress is not a valid ETH address")
    if assetAddress == "0x0000000000000000000000000000000000000000":  raise newException(ValueError, "assetAddress requires a valid token address")

  if data != "": # If data is being used
    if not validate(HexDataStr(data)): raise newException(ValueError, "data should contain a valid hex string")

proc hex2Time*(hex: string): Time =
  # represents the time since 1970-01-01T00:00:00Z
  fromUnix(fromHex[int64](hex))

proc hex2LocalDateTime*(hex: string): DateTime =
  # Convert hex time (since 1970-01-01T00:00:00Z) into a DateTime using the
  # local timezone. 
  hex.hex2Time.local

proc isUnique*[T](key: T, existingKeys: var seq[T]): bool =
  # If the key doesn't exist in the existingKeys seq, add it and return true.
  # Otherwise, the key already existed, so return false.
  # Can be used to deduplicate sequences with `deduplicate[T]`.
  if not existingKeys.contains(key):
    existingKeys.add key
    return true
  return false

proc deduplicate*[T](txs: var seq[T], key: (T) -> string) =
  var existingKeys: seq[string] = @[]
  txs.keepIf(tx => tx.key().isUnique(existingKeys))

# TODO: make this public in nim-web3 lib
proc stripLeadingZeros*(value: string): string =
  var cidx = 0
  # ignore the last character so we retain '0' on zero value
  while cidx < value.len - 1 and value[cidx] == '0':
    cidx.inc
  value[cidx .. ^1]