import sequtils, strformat, sugar, macros, tables, strutils
import eth/common/eth_types, stew/byteutils

type
  FixedBytes* [N: static[int]] = distinct array[N, byte]
  DynamicBytes* [N: static[int]] = distinct array[N, byte]
  EncodeResult* = tuple[dynamic: bool, data: string]
  Bool* = distinct Int256 # TODO: implement Bool as Stint[256]?
  Encodable* = concept x
    encode(x) is EncodeResult

type
  GetPackData* = object
    packId*: Stuint[256]

  PackData* = object
    category*: DynamicBytes[32] # bytes4[]
    owner*: EthAddress # address
    mintable*: bool # bool
    timestamp*: Stuint[256] # uint256
    price*: Stuint[256] # uint256
    contentHash*: DynamicBytes[64] # bytes

  BuyToken* = object
    packId*: Stuint[256]
    address*: EthAddress
    price*: Stuint[256]

  ApproveAndCall* = object
    to*: EthAddress
    value*: Stuint[256]
    data*: DynamicBytes[100]

  Transfer* = object
    to*: EthAddress
    value*: Stuint[256]

  BalanceOf* = object
    address*: EthAddress

  TokenOfOwnerByIndex* = object
    address*: EthAddress
    index*: Stuint[256]

  TokenPackId* = object
    tokenId*: Stuint[256]

  TokenUri* = object
    tokenId*: Stuint[256]

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

func fromHex*[N](x: type DynamicBytes[N], s: string): DynamicBytes[N] {.inline.} =
  fromHexAux(s, array[N, byte](result))

func fromHex*(x: type EthAddress, s: string): EthAddress {.inline.} =
  fromHexAux(s, array[20, byte](result))

template toHex*[N](x: FixedBytes[N]): string =
  toHex(array[N, byte](x))

template toHex*[N](x: DynamicBytes[N]): string =
  toHex(array[N, byte](x))

template toHex*(x: EthAddress): string =
  toHex(array[20, byte](x))

func encode*[bits: static[int]](x: Stuint[bits]): EncodeResult =
  ## Encodes a `Stuint` to a textual representation for use in the JsonRPC
  ## `sendTransaction` call.
  (dynamic: false, data: ('0'.repeat((256 - bits) div 4) & x.dumpHex.map(c => c).join("")))

func encode*[bits: static[int]](x: Stint[bits]): EncodeResult =
  ## Encodes a `Stint` to a textual representation for use in the JsonRPC
  ## `sendTransaction` call.
  (dynamic: false,
  data:
    if x.isNegative:
      'f'.repeat((256 - bits) div 4) & x.dumpHex
    else:
      '0'.repeat((256 - bits) div 4) & x.dumpHex
  )

func fixedEncode(a: openarray[byte]): EncodeResult =
  var padding = a.len mod 32
  if padding != 0: padding = 32 - padding
  result = (dynamic: false, data: cast[string]("00".repeat(padding) & byteutils.toHex(a)))

func encode*[N](b: FixedBytes[N]): EncodeResult = fixedEncode(array[N, byte](b))
func encode*(b: EthAddress): EncodeResult = fixedEncode(array[20, byte](b))

func encodeDynamic(v: openarray[byte]): EncodeResult =
  result.dynamic = true
  result.data = toHex(v.len, 64).toLower
  for y in v:
    result.data &= y.toHex.toLower
  result.data &= "00".repeat(v.len mod 32)

func encode*[N](x: DynamicBytes[N]): EncodeResult {.inline.} =
  encodeDynamic(array[N, byte](x))

func encode*(x: Bool): EncodeResult = encode(Int256(x))

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

func decode*(input: string, offset: int, to: var EthAddress): int {.inline.} =
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