import Tables, json, chronicles, strutils
import algorithm, strformat, sets, options, sequtils
import chronicles, libp2p/[multihash, multicodec, cid]
import nimcrypto, stint
import web3/conversions
import ../../common/conversion as common_conversion
import ../eth/dto/transaction as eth_transaction_dto
import ../eth/dto/coder as eth_coder_dto
import ../eth/dto/contract as eth_contract_dto
import status/statusgo_backend_new/eth as status_eth

logScope:
  topics = "ens-utils"

include ../../common/json_utils

const STATUS_DOMAIN* = ".stateofus.eth"
const ENS_REGISTRY* = "0x00000000000C2E074eC69A0dFb2997BA6C7d2e1e"
const RESOLVER_SIGNATURE* = "0x0178b8bf"
const CONTENTHASH_SIGNATURE* = "0xbc1c58d1" # contenthash(bytes32)
const PUBKEY_SIGNATURE* = "0xc8690233" # pubkey(bytes32 node)
const ADDRESS_SIGNATURE* = "0x3b3b57de" # addr(bytes32 node)
const OWNER_SIGNATURE* = "0x02571be3" # owner(bytes32 node)

export STATUS_DOMAIN
export ENS_REGISTRY
export RESOLVER_SIGNATURE
export CONTENTHASH_SIGNATURE
export PUBKEY_SIGNATURE
export ADDRESS_SIGNATURE
export OWNER_SIGNATURE

type
  ENSType* {.pure.} = enum
    IPFS,
    SWARM,
    IPNS,
    UNKNOWN

proc addDomain(username: string): string =
  if username.endsWith(".eth"):
    return username
  else:
    return username & STATUS_DOMAIN

proc namehash*(ensName:string): string =
  let name = ensName.toLower()
  var node:array[32, byte]

  node.fill(0)
  var parts = name.split(".")
  for i in countdown(parts.len - 1,0):
    let elem = keccak_256.digest(parts[i]).data
    var concatArrays: array[64, byte]
    concatArrays[0..31] = node
    concatArrays[32..63] = elem
    node = keccak_256.digest(concatArrays).data

  result = "0x" & node.toHex()

proc resolver*(usernameHash: string): string =
  let payload = %* [{
    "to": ENS_REGISTRY,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{RESOLVER_SIGNATURE}{userNameHash}"
  }, "latest"]

  var resolverAddr = status_eth.doEthCall(payload).result.getStr()
  resolverAddr.removePrefix("0x000000000000000000000000")
  result = "0x" & resolverAddr

proc contenthash(ensAddr: string): string =
  var ensHash = namehash(ensAddr)
  ensHash.removePrefix("0x")
  let ensResolver = resolver(ensHash)
  let payload = %* [{
    "to": ensResolver,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{CONTENTHASH_SIGNATURE}{ensHash}"
  }, "latest"]

  let bytesResponse =  status_eth.doEthCall(payload).result.getStr()
  if bytesResponse == "0x":
    return ""

  let size = fromHex(Stuint[256], bytesResponse[66..129]).truncate(int)
  result = bytesResponse[130..129+size*2]

proc getContentHash*(ens: string): Option[string] =
  try:
    let contentHash = contenthash(ens)
    if contentHash != "":
      return some(contentHash)
  except Exception as e:
    let errDescription = e.msg
    error "error: ", errDescription
  return none(string)

proc decodeENSContentHash*(value: string): tuple[ensType: ENSType, output: string] =
  if value == "":
    return (ENSType.UNKNOWN, "")

  if value[0..5] == "e40101":
    return (ENSType.SWARM, value.split("1b20")[1])

  if value[0..7] == "e3010170":
    try:
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
      let
        multiHash = MultiHash.init(nimcrypto.fromHex(multiHashStr)).get()
        decoded = Cid.init(CIDv0, MultiCodec.codec(codec), multiHash).get()
      return (ENSType.IPFS, $decoded)
    except Exception as e:
      error "Error decoding ENS contenthash", hash=value, exception=e.msg
      raise

  if value[0..8] == "e50101700":
    return (ENSType.IPNS, parseHexStr(value[12..value.len-1]))

  return (ENSType.UNKNOWN, "")

proc pubkey*(username: string): string =
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let ensResolver = resolver(userNameHash)
  let payload = %* [{
    "to": ensResolver,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{PUBKEY_SIGNATURE}{userNameHash}"
  }, "latest"]
  let response = status_eth.doEthCall(payload)
  # TODO: error handling
  var pubkey = response.result.getStr()
  if pubkey == "0x" or pubkey == "0x00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000":
    result = ""
  else:
    pubkey.removePrefix("0x")
    result = "0x04" & pubkey

proc address*(username: string): string =
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let ensResolver = resolver(userNameHash)
  let payload = %* [{
    "to": ensResolver,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{ADDRESS_SIGNATURE}{userNameHash}"
  }, "latest"]
  let response = status_eth.doEthCall(payload)
  # TODO: error handling
  let address = response.result.getStr()
  if address == "0x0000000000000000000000000000000000000000000000000000000000000000":
    return ""
  result = "0x" & address.substr(26)

proc owner*(username: string): string =
  var userNameHash = namehash(addDomain(username))
  userNameHash.removePrefix("0x")
  let payload = %* [{
    "to": ENS_REGISTRY,
    "from": "0x0000000000000000000000000000000000000000",
    "data": fmt"{OWNER_SIGNATURE}{userNameHash}"
  }, "latest"]
  let response = status_eth.doEthCall(payload)
  # TODO: error handling
  let ownerAddr = response.result.getStr()
  if ownerAddr == "0x0000000000000000000000000000000000000000000000000000000000000000":
    return ""
  result = "0x" & ownerAddr.substr(26)

proc buildTransaction*(source: Address, value: Uint256, gas = "", gasPrice = "", isEIP1559Enabled = false, 
  maxPriorityFeePerGas = "", maxFeePerGas = "", data = ""): TransactionDataDto =
  result = TransactionDataDto(
    source: source,
    value: value.some,
    gas: (if gas.isEmptyOrWhitespace: Quantity.none else: Quantity(cast[uint64](parseFloat(gas).toUInt64)).some),
    gasPrice: (if gasPrice.isEmptyOrWhitespace: int.none else: gwei2Wei(parseFloat(gasPrice)).truncate(int).some),
    data: data
  )
  if isEIP1559Enabled:
    result.txType = "0x02"
    result.maxPriorityFeePerGas = if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxPriorityFeePerGas)).some
    result.maxFeePerGas = (if maxFeePerGas.isEmptyOrWhitespace: Uint256.none else: gwei2Wei(parseFloat(maxFeePerGas)).some)
  else:
    result.txType = "0x00"

proc buildTokenTransaction*(source, contractAddress: Address, gas = "", gasPrice = "", isEIP1559Enabled = false, 
  maxPriorityFeePerGas = "", maxFeePerGas = ""): TransactionDataDto =
  result = buildTransaction(source, 0.u256, gas, gasPrice, isEIP1559Enabled, maxPriorityFeePerGas, maxFeePerGas)
  result.to = contractAddress.some

proc label*(username:string): string =
  var node:array[32, byte] = keccak_256.digest(username.toLower()).data
  result = "0x" & node.toHex()

proc getExpirationTime*(toAddress: Address, data: string): int =
  try:
    var tx = buildTransaction(parseAddress("0x0000000000000000000000000000000000000000"), 0.u256)
    tx.to = toAddress.some
    tx.data = data
  
    let payload = %*[%tx, "latest"]
    let response = status_eth.doEthCall(payload)
    result = fromHex[int](response.result.getStr)
  except RpcException as e:
    error "Error obtaining expiration time", err=e.msg

proc getPrice*(ensUsernamesContract: ContractDto): Stuint[256] =
  try:
    let payload = %* [{
        "to": $ensUsernamesContract.address,
        "data": ensUsernamesContract.methods["getPrice"].encodeAbi()
      }, "latest"]

    let response = status_eth.doEthCall(payload)
    if not response.error.isNil:
      error "Error getting ens username price, ", errDescription=response.error.message
    if response.result.getStr == "0x":
      error "Error getting ens username price: 0x"
  
    result = fromHex(Stuint[256], response.result.getStr)
  except RpcException as e:
    error "Error obtaining expiration time", err=e.msg

proc hex2Token*(input: string, decimals: int): string =
  var value = fromHex(Stuint[256], input)

  if decimals == 0:
    return fmt"{value}"
  
  var p = u256(10).pow(decimals)
  var i = value.div(p)
  var r = value.mod(p)
  var leading_zeros = "0".repeat(decimals - ($r).len)
  var d = fmt"{leading_zeros}{$r}"
  result = $i
  if(r > 0): result = fmt"{result}.{d}"