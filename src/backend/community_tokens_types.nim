import json
include app_service/common/json_utils
import app_service/common/conversion
import web3/conversions
import web3/eth_api_types as eth

type
  # see protocol/communities/token/community_token.go PrivilegesLevel
  PrivilegesLevel* {.pure.} = enum
    Owner, Master, Community

  CommunityTokenReceivedPayload* = object
    address*: eth.Address
    name*: string
    symbol*: string
    image*: string
    chainId*: int
    decimals*: int
    verified*: bool
    tokenListID*: string
    communityId*: string
    communityName*: string
    communityColor*: string
    communityImage*: string
    amount*: float
    txHash*: string
    isFirst*: bool

proc fromJson*(t: JsonNode, T: typedesc[CommunityTokenReceivedPayload]): CommunityTokenReceivedPayload {.inline.}=
  let addressField = "address"
  discard t.getProp("name", result.name)
  discard t.getProp("symbol", result.symbol)
  discard t.getProp("image", result.image)
  discard t.getProp("chainId", result.chainId)
  discard t.getProp("decimals", result.decimals)
  discard t.getProp("verified", result.verified)
  discard t.getProp("tokenListID", result.tokenListID)
  discard t.getProp("txHash", result.txHash)
  discard t.getProp("isFirst", result.isFirst)
  discard t.getProp("amount", result.amount)

  fromJson(t[addressField], addressField, result.address)

  var communityDataObj: JsonNode
  if(t.getProp("community_data", communityDataObj)):
    discard communityDataObj.getProp("id", result.communityId)
    discard communityDataObj.getProp("name", result.communityName)
    discard communityDataObj.getProp("color", result.communityColor)
    discard communityDataObj.getProp("image", result.communityImage)