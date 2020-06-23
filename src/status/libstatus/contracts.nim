import sequtils, strformat, sugar, macros, tables, eth/common/eth_types, stew/byteutils, nimcrypto
from eth/common/utils import parseAddress

type
  Network* {.pure.} = enum
    Mainnet,
    Testnet

type Method = object
  name: string
  signature: string
  noPadding: bool

type Contract* = ref object
  name*: string
  network*: Network
  address*: EthAddress
  methods*: Table[string, Method]

let CONTRACTS: seq[Contract] = @[
  Contract(name: "snt", network: Network.Mainnet, address: parseAddress("0x744d70fdbe2ba4cf95131626614a1763df805b9e")),
  Contract(name: "snt", network: Network.Testnet, address: parseAddress("0xc55cf4b03948d7ebc8b9e8bad92643703811d162")),
  Contract(name: "tribute-to-talk", network: Network.Testnet, address: parseAddress("0xC61aa0287247a0398589a66fCD6146EC0F295432")),
  Contract(name: "stickers", network: Network.Mainnet, address: parseAddress("0x0577215622f43a39f4bc9640806dfea9b10d2a36")),
  Contract(name: "stickers", network: Network.Testnet, address: parseAddress("0x8cc272396be7583c65bee82cd7b743c69a87287d")),
  Contract(name: "sticker-market", network: Network.Mainnet, address: parseAddress("0x12824271339304d3a9f7e096e62a2a7e73b4a7e7")),
  Contract(name: "sticker-market", network: Network.Testnet, address: parseAddress("0x6CC7274aF9cE9572d22DFD8545Fb8c9C9Bcb48AD")),
  Contract(name: "sticker-pack", network: Network.Mainnet, address: parseAddress("0x110101156e8F0743948B2A61aFcf3994A8Fb172e")),
  Contract(name: "sticker-pack", network: Network.Testnet, address: parseAddress("0xf852198d0385c4b871e0b91804ecd47c6ba97351")),
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

proc getContract*(network: Network, name: string): Contract =
  let found = CONTRACTS.filter(contract => contract.name == name and contract.network == network)
  result = if found.len > 0: found[0] else: nil

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

macro encodeAbi*(self: Method, params: varargs[untyped]): untyped =
  result = quote do:
    "0x" & encodeMethod(`self`)
  for param in params:
    result = quote do:
      `result` & encodeParam(`param`)

proc `$`*(a: EthAddress): string =
  "0x" & a.toHex()
