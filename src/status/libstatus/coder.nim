import macros
import web3/[encoding, ethtypes], stint

type
  GetPackData* = object
    packId*: Stuint[256]

  PackData* = object
    category*: DynamicBytes[32] # bytes4[]
    owner*: Address # address
    mintable*: bool # bool
    timestamp*: Stuint[256] # uint256
    price*: Stuint[256] # uint256
    contentHash*: DynamicBytes[64] # bytes

  BuyToken* = object
    packId*: Stuint[256]
    address*: Address
    price*: Stuint[256]

  Register* = object
    label*: FixedBytes[32]
    account*: Address
    x*: FixedBytes[32]
    y*: FixedBytes[32]

  SetPubkey* = object
    label*: FixedBytes[32]
    x*: FixedBytes[32]
    y*: FixedBytes[32]

  ApproveAndCall*[N: static[int]] = object
    to*: Address
    value*: Stuint[256]
    data*: DynamicBytes[N]

  Transfer* = object
    to*: Address
    value*: Stuint[256]

  BalanceOf* = object
    address*: Address

  TokenOfOwnerByIndex* = object
    address*: Address
    index*: Stuint[256]

  TokenPackId* = object
    tokenId*: Stuint[256]

  TokenUri* = object
    tokenId*: Stuint[256]

# TODO: Figure out a way to parse a bool as a Bool instead of bool, as it is
# done in nim-web3
func decode*(input: string, offset: int, to: var bool): int {.inline.} =
  let val = input[offset..offset+63].parse(Int256)
  to = val.truncate(int) == 1
  64

# TODO: This is taken directly from nim-web3 in order to be able to decode
# booleans. I could not get the type Bool, as used in nim-web3, to be decoded
# properly, and instead resorted to a standard bool type.
func decodeHere*(input: string, offset: int, obj: var object): int =
  var offset = offset
  for field in fields(obj):
    offset += decode(input, offset, field)

func decodeContractResponse*[T](input: string): T =
  result = T()
  discard decodeHere(input.strip0xPrefix, 0, result)