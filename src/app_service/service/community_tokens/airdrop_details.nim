import json
include ../../common/json_utils

type AirdropDetails* = object
  chainId*: int
  contractAddress*: string
  walletAddresses*: seq[string]
  amount*: int

proc toJsonNode*(self: AirdropDetails): JsonNode =
  result =
    %*{
      "chainId": self.chainId,
      "contractAddress": self.contractAddress,
      "walletAddresses": self.walletAddresses,
      "amount": self.amount,
    }

proc toAirdropDetails*(jsonObj: JsonNode): AirdropDetails =
  result = AirdropDetails()
  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("contractAddress", result.contractAddress)

  var walletsObj: JsonNode
  if (jsonObj.getProp("walletAddresses", walletsObj) and walletsObj.kind == JArray):
    for walletAddr in walletsObj:
      result.walletAddresses.add(walletAddr.getStr)

  discard jsonObj.getProp("amount", result.amount)
