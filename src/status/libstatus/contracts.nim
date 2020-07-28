import sequtils, strformat, sugar, macros, tables
import eth/common/eth_types, stew/byteutils, nimcrypto
from eth/common/utils import parseAddress
import ./types, ./settings

type Method* = object
  name*: string
  signature*: string
  noPadding*: bool

type Contract* = ref object
  name*: string
  network*: Network
  address*: EthAddress
  methods*: Table[string, Method]


type
  FixedBytes* [N: static[int]] = distinct array[N, byte]
  DynamicBytes* [N: static[int]] = distinct array[N, byte]
  Address* = distinct EthAddress
  EncodeResult* = tuple[dynamic: bool, data: string]
  # Bool* = distinct Int256 # TODO: implement Bool as FixedBytes[N]?

type PackData* = object
  category*: DynamicBytes[32] # bytes4[]
  owner*: Address # address
  mintable*: bool # bool
  timestamp*: Stuint[256] # uint256
  price*: Stuint[256] # uint256
  contentHash*: DynamicBytes[64] # bytes

proc allContracts(): seq[Contract] = @[
  Contract(name: "snt", network: Network.Mainnet, address: parseAddress("0x744d70fdbe2ba4cf95131626614a1763df805b9e"),
    methods: [
      ("approveAndCall", Method(signature: "approveAndCall(address,uint256,bytes)")),
      ("transfer", Method(signature: "transfer(address,uint256)"))
    ].toTable
  ),
  Contract(name: "snt", network: Network.Testnet, address: parseAddress("0xc55cf4b03948d7ebc8b9e8bad92643703811d162"),
    methods: [
      ("approveAndCall", Method(signature: "approveAndCall(address,uint256,bytes)")),
      ("transfer", Method(signature: "transfer(address,uint256)"))
    ].toTable
  ),
  Contract(name: "tribute-to-talk", network: Network.Testnet, address: parseAddress("0xC61aa0287247a0398589a66fCD6146EC0F295432")),
  Contract(name: "stickers", network: Network.Mainnet, address: parseAddress("0x0577215622f43a39f4bc9640806dfea9b10d2a36"),
    methods: [
      ("packCount", Method(signature: "packCount()")),
      ("getPackData", Method(signature: "getPackData(uint256)", noPadding: true))
    ].toTable
  ),
  Contract(name: "stickers", network: Network.Testnet, address: parseAddress("0x8cc272396be7583c65bee82cd7b743c69a87287d"),
    methods: [
      ("packCount", Method(signature: "packCount()")),
      ("getPackData", Method(signature: "getPackData(uint256)", noPadding: true))
    ].toTable
  ),
  Contract(name: "sticker-market", network: Network.Mainnet, address: parseAddress("0x12824271339304d3a9f7e096e62a2a7e73b4a7e7"),
    methods: [
      ("buyToken", Method(signature: "buyToken(uint256,address,uint256)"))
    ].toTable
  ),
  Contract(name: "sticker-market", network: Network.Testnet, address: parseAddress("0x6CC7274aF9cE9572d22DFD8545Fb8c9C9Bcb48AD"),
    methods: [
      ("buyToken", Method(signature: "buyToken(uint256,address,uint256)"))
    ].toTable
  ),
  Contract(name: "sticker-pack", network: Network.Mainnet, address: parseAddress("0x110101156e8F0743948B2A61aFcf3994A8Fb172e"),
    methods: [
      ("balanceOf", Method(signature: "balanceOf(address)")),
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)")),
      ("tokenPackId", Method(signature: "tokenPackId(uint256)"))
    ].toTable
  ),
  Contract(name: "sticker-pack", network: Network.Testnet, address: parseAddress("0xf852198d0385c4b871e0b91804ecd47c6ba97351"),
    methods: [
      ("balanceOf", Method(signature: "balanceOf(address)")),
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)")),
      ("tokenPackId", Method(signature: "tokenPackId(uint256)"))
    ].toTable),
  # Strikers seems dead. Their website doesn't work anymore
  Contract(name: "strikers", network: Network.Mainnet, address: parseAddress("0xdcaad9fd9a74144d226dbf94ce6162ca9f09ed7e"),
    methods: [
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)"))
    ].toTable
  ),
  Contract(name: "ethermon", network: Network.Mainnet, address: parseAddress("0xb2c0782ae4a299f7358758b2d15da9bf29e1dd99"),
    methods: [
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)"))
    ].toTable
  ),
  Contract(name: "kudos", network: Network.Mainnet, address: parseAddress("0x2aea4add166ebf38b63d09a75de1a7b94aa24163"),
    methods: [
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)")),
      ("tokenURI", Method(signature: "tokenURI(uint256)", noPadding: true))
    ].toTable
  ),
  Contract(name: "crypto-kitties", network: Network.Mainnet, address: parseAddress("0x06012c8cf97bead5deae237070f9587f8e7a266d")),
]

proc getContract(network: Network, name: string): Contract =
  let found = allContracts().filter(contract => contract.name == name and contract.network == network)
  result = if found.len > 0: found[0] else: nil

proc getContract*(name: string): Contract =
  let network = settings.getCurrentNetwork()
  getContract(network, name)

func encode*[bits: static[int]](x: Stuint[bits]): EncodeResult =
  ## Encodes a `Stuint` to a textual representation for use in the JsonRPC
  ## `sendTransaction` call.
  (dynamic: false, data: ('0'.repeat((256 - bits) div 4) & x.dumpHex.map(c => c)).join(""))

proc encodeMethod(self: Method): string =
  let hash = $nimcrypto.keccak256.digest(self.signature)
  result = hash[0 .. ^(hash.high - 6)]
  if (not self.noPadding):
    result = &"{result:0<32}"

proc encodeParam[T](value: T): string =
  # Could possibly simplify this by passing a string value, like so:
  # https://github.com/status-im/nimbus/blob/4ade5797ee04dc778641372177e4b3e1851cdb6c/nimbus/config.nim#L304-L324
  when T is int:
    result = toHex(value, 64)
  elif T is EthAddress:
    result = value.toHex()
  elif T is Stuint:
    result = value.encode().data
  else:
    result = align(value, 64, '0')

macro encodeAbi*(self: Method, params: varargs[untyped]): untyped =
  result = quote do:
    "0x" & encodeMethod(`self`)
  for param in params:
    result = quote do:
      `result` & encodeParam(`param`)

proc skip0xPrefix*(s: string): int =
  if s.len > 1 and s[0] == '0' and s[1] in {'x', 'X'}: 2
  else: 0

proc strip0xPrefix*(s: string): string =
  let prefixLen = skip0xPrefix(s)
  if prefixLen != 0:
    s[prefixLen .. ^1]
  else:
    s

proc fromHexAux*(s: string, result: var openarray[byte]) =
  let prefixLen = skip0xPrefix(s)
  let meaningfulLen = s.len - prefixLen
  let requiredChars = result.len * 2
  if meaningfulLen > requiredChars:
    let start = s.len - requiredChars
    hexToByteArray(s[start .. s.len - 1], result)
  elif meaningfulLen == requiredChars:
    hexToByteArray(s, result)
  else:
    raise newException(ValueError, "Short hex string (" & $meaningfulLen & ") for Bytes[" & $result.len & "]")

func fromHex*[N](x: type FixedBytes[N], s: string): FixedBytes[N] {.inline.} =
  fromHexAux(s, array[N, byte](result))

func fromHex*(x: type Address, s: string): Address {.inline.} =
  fromHexAux(s, array[20, byte](result))

template toHex*[N](x: FixedBytes[N]): string =
  toHex(array[N, byte](x))

template toHex*[N](x: DynamicBytes[N]): string =
  toHex(array[N, byte](x))

template toHex*(x: Address): string =
  toHex(array[20, byte](x))

func decode*(input: string, offset: int, to: var Stuint): int =
  let meaningfulLen = to.bits div 8 * 2
  to = type(to).fromHex(input[offset .. offset + meaningfulLen - 1])
  meaningfulLen

func decode*[N](input: string, offset: int, to: var Stint[N]): int =
  let meaningfulLen = N div 8 * 2
  fromHex(input[offset .. offset + meaningfulLen], to)
  meaningfulLen
  
func decodeFixed(input: string, offset: int, to: var openarray[byte]): int =
  let meaningfulLen = to.len * 2
  var padding = to.len mod 32
  if padding != 0: padding = (32 - padding) * 2
  let offset = offset + padding
  fromHexAux(input[offset .. offset + meaningfulLen - 1], to)
  meaningfulLen + padding

func decode*[N](input: string, offset: int, to: var FixedBytes[N]): int {.inline.} =
  decodeFixed(input, offset, array[N, byte](to))

func decode*(input: string, offset: int, to: var Address): int {.inline.} =
  decodeFixed(input, offset, array[20, byte](to))

func decodeDynamic(input: string, offset: int, to: var openarray[byte]): int =
  var dataOffset, dataLen: UInt256
  result = decode(input, offset, dataOffset)
  discard decode(input, dataOffset.truncate(int) * 2, dataLen)
  # TODO: Check data len, and raise?
  let meaningfulLen = to.len * 2
  let actualDataOffset = (dataOffset.truncate(int) + 32) * 2
  fromHexAux(input[actualDataOffset .. actualDataOffset + meaningfulLen - 1], to)

func decode*[N](input: string, offset: int, to: var DynamicBytes[N]): int {.inline.} =
  decodeDynamic(input, offset, array[N, byte](to))

# TODO: Figure out a way to parse a bool as a FixedBytes[N], so that we can allow
# variance in the number of bytes. The current implementation is a very forceful
# way of parsing a bool because it assumes the bool is 32 bytes (64 chars).
func decode*(input: string, offset: int, to: var bool): int {.inline.} =
  let val = input[offset..offset+63].parse(Int256)
  to = val.truncate(int) == 1
  64

func decode*(input: string, offset: int, obj: var object): int =
  var offset = offset
  for field in fields(obj):
    offset += decode(input, offset, field)

func decode*[T](input: string, to: seq[T]): seq[T] =
  var count = input[0..64].decode(Stuint)
  result = newSeq[T](count)
  for i in 0..count:
    result[i] = input[i*64 .. (i+1)*64].decode(T)

func decode*[T; I: static int](input: string, to: array[0..I, T]): array[0..I, T] =
  for i in 0..I:
    result[i] = input[i*64 .. (i+1)*64].decode(T)

func decodeContractResponse*[T](input: string): T =
  result = T()
  discard decode(input.strip0xPrefix, 0, result)
