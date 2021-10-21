import json
import sets
import permission
include ../../../common/json_utils

type Dapp* = object
  name*: string
  permissions*: HashSet[Permission]

proc toDapp*(jsonObj: JsonNode): Dapp =
  result = Dapp()
  result.permissions = initHashSet[Permission]()
  discard jsonObj.getProp("name", result.name)
  for permission in jsonObj["permissions"].getElems():
    result.permissions.incl(permission.getStr().toPermission())
