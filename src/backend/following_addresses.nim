import json
import ./core, ./response_type
export response_type

from gen import rpc

rpc(getFollowingAddresses, "wallet"):
  userAddress: string
  search: string
  limit: int
  offset: int

rpc(getFollowingStats, "wallet"):
  userAddress: string
