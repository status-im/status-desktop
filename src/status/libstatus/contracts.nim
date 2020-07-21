import sequtils, strformat, sugar, macros, tables, strutils
import eth/common/eth_types, stew/byteutils, nimcrypto
from eth/common/utils import parseAddress
import ./types, ./settings, ./coder

export
  GetPackData, PackData, BuyToken, ApproveAndCall, Transfer, BalanceOf,
  TokenOfOwnerByIndex, TokenPackId, TokenUri, DynamicBytes, toHex, fromHex

type Method* = object
  name*: string
  signature*: string

type Contract* = ref object
  name*: string
  network*: Network
  address*: EthAddress
  methods*: Table[string, Method]

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
      ("getPackData", Method(signature: "getPackData(uint256)"))
    ].toTable
  ),
  Contract(name: "stickers", network: Network.Testnet, address: parseAddress("0x8cc272396be7583c65bee82cd7b743c69a87287d"),
    methods: [
      ("packCount", Method(signature: "packCount()")),
      ("getPackData", Method(signature: "getPackData(uint256)"))
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
      ("tokenURI", Method(signature: "tokenURI(uint256)"))
    ].toTable
  ),
  Contract(name: "kudos", network: Network.Testnet, address: parseAddress("0xcd520707fc68d153283d518b29ada466f9091ea8"),
    methods: [
      ("tokenOfOwnerByIndex", Method(signature: "tokenOfOwnerByIndex(address,uint256)")),
      ("tokenURI", Method(signature: "tokenURI(uint256)"))
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

proc encodeMethod(self: Method): string =
  ($nimcrypto.keccak256.digest(self.signature))[0..<8].toLower

proc encodeAbi*(self: Method, obj: object = RootObj()): string =
  result = "0x" & self.encodeMethod()

  # .fields is an iterator, and there's no way to get a count of an iterator
  # in nim, so we have to loop and increment a counter
  var fieldCount = 0
  for i in obj.fields:
    fieldCount += 1
  var
    offset = 32*fieldCount
    data = ""

  for field in obj.fields:
    let encoded = encode(field)
    if encoded.dynamic:
      result &= offset.toHex(64).toLower
      data &= encoded.data
      offset += encoded.data.len
    else:
      result &= encoded.data
  result &= data

func decodeContractResponse*[T](input: string): T =
  result = T()
  discard decode(input.strip0xPrefix, 0, result)
