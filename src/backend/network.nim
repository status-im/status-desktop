import json
import ./core, ./response_type
from ./gen import rpc

import backend/network_types

export response_type, network_types

rpc(getFlatEthereumChains, "wallet"):
  discard

rpc(addEthereumChain, "wallet"):
  network: NetworkDto

rpc(deleteEthereumChain, "wallet"):
  chainId: int

rpc(setChainActive, "wallet"):
  chainId: int
  active: bool

rpc(fetchChainIDForURL, "wallet"):
  url: string

rpc(setChainEnabled, "wallet"):
  chainId: int
  enabled: bool

rpc(setChainUserRpcProviders, "wallet"):
  chainId: int
  rpcProviders: seq[RpcProviderDto]