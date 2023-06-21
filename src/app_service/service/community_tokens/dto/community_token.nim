import json, sequtils, stint, strutils, chronicles
import ../../../../backend/response_type
include ../../../common/json_utils
import ../../../common/conversion
import ../../community/dto/community

type
  DeployState* {.pure.} = enum
    Failed,
    InProgress,
    Deployed

type
  CommunityTokenDto* = object
    tokenType*: TokenType
    communityId*: string
    address*: string
    name*: string
    symbol*: string
    description*: string
    supply*: Uint256
    infiniteSupply*: bool
    transferable*: bool
    remoteSelfDestruct*: bool
    tokenUri*: string
    chainId*: int
    deployState*: DeployState
    image*: string
    decimals*: int

proc toJsonNode*(self: CommunityTokenDto): JsonNode =
  result = %* {
    "tokenType": self.tokenType.int,
    "communityId": self.communityId,
    "address": self.address,
    "name": self.name,
    "symbol": self.symbol,
    "description": self.description,
    "supply": self.supply.toString(10),
    "infiniteSupply": self.infiniteSupply,
    "transferable": self.transferable,
    "remoteSelfDestruct": self.remoteSelfDestruct,
    "tokenUri": self.tokenUri,
    "chainId": self.chainId,
    "deployState": self.deployState.int,
    "image": self.image,
    "decimals": self.decimals
  }

proc toCommunityTokenDto*(jsonObj: JsonNode): CommunityTokenDto =
  result = CommunityTokenDto()
  var tokenTypeInt: int
  discard jsonObj.getProp("tokenType", tokenTypeInt)
  result.tokenType = intToEnum(tokenTypeInt, TokenType.ERC721)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("description", result.description)
  var supplyStr: string
  discard jsonObj.getProp("supply", supplyStr)
  result.supply = stint.parse(supplyStr, Uint256)
  discard jsonObj.getProp("infiniteSupply", result.infiniteSupply)
  discard jsonObj.getProp("transferable", result.transferable)
  discard jsonObj.getProp("remoteSelfDestruct", result.remoteSelfDestruct)
  discard jsonObj.getProp("tokenUri", result.tokenUri)
  discard jsonObj.getProp("chainId", result.chainId)
  var deployStateInt: int
  discard jsonObj.getProp("deployState", deployStateInt)
  result.deployState = intToEnum(deployStateInt, DeployState.Failed)
  discard jsonObj.getProp("image", result.image)
  discard jsonObj.getProp("decimals", result.decimals)

proc parseCommunityTokens*(response: RpcResponse[JsonNode]): seq[CommunityTokenDto] =
  result = map(response.result.getElems(),
    proc(x: JsonNode): CommunityTokenDto = x.toCommunityTokenDto())

proc supplyByType*(supply: Uint256, tokenType: TokenType): float64 =
  try:
    var eths: string
    if tokenType == TokenType.ERC20:
      eths = wei2Eth(supply, 18)
    else:
      eths = supply.toString(10)
    return parseFloat(eths)
  except Exception as e:
    error "Error parsing supply by type ", msg=e.msg, supply=supply, tokenType=tokenType