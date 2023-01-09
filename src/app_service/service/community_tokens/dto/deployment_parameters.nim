import json, stint

type
  DeploymentParameters* = object
    name*: string
    symbol*: string
    supply*: int
    infiniteSupply*: bool
    transferable*: bool
    remoteSelfDestruct*: bool
    tokenUri*: string
    description*: string # not part of smart contract

proc `%`*(x: DeploymentParameters): JsonNode =
  result = newJobject()
  result["name"] = %x.name
  result["symbol"] = %x.symbol
  result["supply"] = %x.supply
  result["infiniteSupply"] = %x.infiniteSupply
  result["transferable"] = %x.transferable
  result["remoteSelfDestruct"] = %x.remoteSelfDestruct
  result["tokenUri"] = %x.tokenUri


