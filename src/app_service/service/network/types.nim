const Mainnet = 1
const Ropsten = 3
const Rinkeby = 4
const Goerli = 5
const Optimism = 10
const Poa = 99
const XDai = 100

export Mainnet, Ropsten, Rinkeby, Goerli, Optimism, Poa, XDai

type
  NetworkType* {.pure.} = enum
    Mainnet = "mainnet_rpc",
    Testnet = "testnet_rpc",
    Rinkeby = "rinkeby_rpc",
    Goerli = "goerli_rpc",
    XDai = "xdai_rpc",
    Poa = "poa_rpc",
    Other = "other"

proc toNetworkType*(networkName: string): NetworkType =
  case networkName:
  of "mainnet_rpc":
    result = NetworkType.Mainnet
  of "testnet_rpc":
    result = NetworkType.Testnet
  of "rinkeby_rpc":
    result = NetworkType.Rinkeby
  of "goerli_rpc":
    result = NetworkType.Goerli
  of "xdai_rpc":
    result = NetworkType.XDai
  of "poa_rpc":
    result = NetworkType.Poa
  else:
    result = NetworkType.Other

proc toChainId*(self: NetworkType): int =
  case self:
    of NetworkType.Mainnet: result = Mainnet
    of NetworkType.Testnet: result = Ropsten
    of NetworkType.Rinkeby: result = Rinkeby
    of NetworkType.Goerli: result = Goerli
    of NetworkType.XDai: result = XDai
    of NetworkType.Poa: result = 99
    of NetworkType.Other: result = -1