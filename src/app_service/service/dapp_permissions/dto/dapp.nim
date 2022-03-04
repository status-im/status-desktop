import json
import sets
import permission
include ../../../common/json_utils

type Dapp* = object
  name*: string
  address*: string
  permissions*: HashSet[Permission]

proc toDapp*(jsonObj: JsonNode): Dapp =
  result = Dapp()
  result.permissions = initHashSet[Permission]()
  discard jsonObj.getProp("dapp", result.name)
  discard jsonObj.getProp("address", result.address)
  for permission in jsonObj["permissions"].getElems():
    result.permissions.incl(permission.getStr().toPermission())
