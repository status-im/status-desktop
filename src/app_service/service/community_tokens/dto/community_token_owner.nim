import json

type CommunityTokenOwner* = object
  walletAddress*: string
  amount*: int

proc `%`*(x: CommunityTokenOwner): JsonNode =
  result = newJobject()
  result["walletAddress"] = %x.walletAddress
  result["amount"] = %x.amount
