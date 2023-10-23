import json, sequtils, stint, strutils, chronicles
import ../../../../backend/response_type
import ../../../../backend/community_tokens_types
include ../../../common/json_utils
import ../../../common/conversion
import ../../community/dto/community

export community_tokens_types

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
    deployer*: string
    privilegesLevel*: PrivilegesLevel

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
    "decimals": self.decimals,
    "deployer": self.deployer,
    "privilegesLevel": self.privilegesLevel.int,
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
  discard jsonObj.getProp("deployer", result.deployer)
  var privilegesLevelInt: int
  discard jsonObj.getProp("privilegesLevel", privilegesLevelInt)
  result.privilegesLevel = intToEnum(privilegesLevelInt, PrivilegesLevel.Community)

proc parseCommunityTokens*(response: RpcResponse[JsonNode]): seq[CommunityTokenDto] =
  result = map(response.result.getElems(),
    proc(x: JsonNode): CommunityTokenDto = x.toCommunityTokenDto())

proc parseCommunityTokens*(response: JsonNode): seq[CommunityTokenDto] =
  result = map(response.getElems(),
    proc(x: JsonNode): CommunityTokenDto = x.toCommunityTokenDto())

type
  CommunityTokenAndAmount* = object
    communityToken*: CommunityTokenDto
    amount*: Uint256 # for assets the value is converted to wei

type
  ContractTuple* = tuple
    chainId: int
    address: string

proc `%`*(self: ContractTuple): JsonNode =
  result = %* {
    "address": self.address,
    "chainId": self.chainId
  }

proc toContractTuple*(json: JsonNode): ContractTuple =
  return (json["chainId"].getInt, json["address"].getStr)

type
  ChainWalletTuple* = tuple
    chainId: int
    address: string

type
  WalletAndAmount* = object
    walletAddress*: string
    amount*: int

type
  RemoteDestroyTransactionDetails* = object
    chainId*: int
    contractAddress*: string
    addresses*: seq[string]

proc `%`*(self: RemoteDestroyTransactionDetails): JsonNode =
  result = %* {
    "contractAddress": self.contractAddress,
    "chainId": self.chainId,
    "addresses": self.addresses
  }

type
  OwnerTokenDeploymentTransactionDetails* = object
    ownerToken*: ContractTuple
    masterToken*: ContractTuple
    communityId*: string

proc `%`*(self: OwnerTokenDeploymentTransactionDetails): JsonNode =
  result = %* {
    "ownerToken": %self.ownerToken,
    "masterToken": %self.masterToken,
    "communityId": self.communityId
  }

proc toOwnerTokenDeploymentTransactionDetails*(jsonObj: JsonNode): OwnerTokenDeploymentTransactionDetails =
  result = OwnerTokenDeploymentTransactionDetails()
  try:
    result.ownerToken = (jsonObj["ownerToken"]["chainId"].getInt, jsonObj["ownerToken"]["address"].getStr)
    result.masterToken = (jsonObj["masterToken"]["chainId"].getInt, jsonObj["masterToken"]["address"].getStr)
    result.communityId = jsonObj["communityId"].getStr
  except Exception as e:
    error "Error parsing OwnerTokenDeploymentTransactionDetails json", msg=e.msg

proc toRemoteDestroyTransactionDetails*(json: JsonNode): RemoteDestroyTransactionDetails =
  return RemoteDestroyTransactionDetails(chainId: json["chainId"].getInt, contractAddress: json["contractAddress"].getStr, addresses: to(json["addresses"], seq[string]))

type
  ComputeFeeErrorCode* {.pure.} = enum
    Success,
    Infura,
    Balance,
    Other

