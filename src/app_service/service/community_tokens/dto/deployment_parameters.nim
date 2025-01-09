import json, stint
import ../../../../backend/interpret/cropped_image
import ../../../common/types

type DeploymentParameters* = object
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
  result["ownerTokenAddress"] = %x.ownerTokenAddress
  result["masterTokenAddress"] = %x.masterTokenAddress
  result["description"] = %x.description
  result["communityId"] = %x.communityId
  if x.croppedImageJson != "":
    result["croppedImage"] = %newCroppedImage(x.croppedImageJson)
  result["base64image"] = %x.base64image
  result["tokenType"] = %x.tokenType
