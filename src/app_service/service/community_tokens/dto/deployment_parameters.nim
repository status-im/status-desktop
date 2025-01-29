import json, stint
import backend/interpret/cropped_image
import app_service/common/types

include  app_service/common/json_utils
from app_service/common/account_constants import ZERO_ADDRESS

type
  DeploymentParameters* = object
    name*: string
    symbol*: string
    supply*: Uint256
    infiniteSupply*: bool
    transferable*: bool
    remoteSelfDestruct*: bool
    tokenUri*: string
    ownerTokenAddress*: string
    masterTokenAddress*: string
    description*: string
    communityId*: string
    croppedImageJson*: string
    base64image*: string
    tokenType*: TokenType
    decimals*: int

proc `%`*(x: DeploymentParameters): JsonNode =
  result = newJobject()
  result["name"] = %x.name
  result["symbol"] = %x.symbol
  result["supply"] = %x.supply.toString(10)
  result["infiniteSupply"] = %x.infiniteSupply
  result["transferable"] = %x.transferable
  result["remoteSelfDestruct"] = %x.remoteSelfDestruct
  result["tokenUri"] = %x.tokenUri
  result["decimals"] = %x.decimals
  var address = ZERO_ADDRESS
  if x.ownerTokenAddress.len > 0:
    address = x.ownerTokenAddress
  result["ownerTokenAddress"] = %address
  address = ZERO_ADDRESS
  if x.masterTokenAddress.len > 0:
    address = x.masterTokenAddress
  result["masterTokenAddress"] = %address
  result["description"] = %x.description
  result["communityId"] = %x.communityId
  if x.croppedImageJson != "":
    result["croppedImage"] = %newCroppedImage(x.croppedImageJson)
  result["base64image"] = %x.base64image
  result["tokenType"] = %x.tokenType

proc toDeploymentParameters*(jsonObj: JsonNode): DeploymentParameters =
  result = DeploymentParameters()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("symbol", result.symbol)
  discard jsonObj.getProp("infiniteSupply", result.infiniteSupply)
  discard jsonObj.getProp("transferable", result.transferable)
  discard jsonObj.getProp("remoteSelfDestruct", result.remoteSelfDestruct)
  discard jsonObj.getProp("tokenUri", result.tokenUri)
  discard jsonObj.getProp("decimals", result.decimals)
  discard jsonObj.getProp("ownerTokenAddress", result.ownerTokenAddress)
  discard jsonObj.getProp("masterTokenAddress", result.masterTokenAddress)
  discard jsonObj.getProp("description", result.description)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("base64image", result.base64image)
  var tmpObj: JsonNode
  if jsonObj.getProp("supply", tmpObj):
    result.supply = stint.fromHex(UInt256, tmpObj.getStr)
  if jsonObj.getProp("croppedImage", tmpObj):
    result.croppedImageJson = tmpObj.getStr
  if jsonObj.getProp("tokenType", tmpObj):
    let txType = tmpObj.getInt
    if txType < ord(low(TokenType)) or txType >= ord(high(TokenType)):
      result.tokenType = TokenType.Native
    else:
      result.tokenType = TokenType(txType)