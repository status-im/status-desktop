import json

include  ../../common/json_utils

type DerivedAddressDto* = object
  address*: string
  publicKey*: string
  path*: string
  hasActivity*: bool
  alreadyCreated*: bool

proc toDerivedAddressDto*(jsonObj: JsonNode): DerivedAddressDto =
  result = DerivedAddressDto()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("public-key", result.publicKey)
  discard jsonObj.getProp("path", result.path)
  discard jsonObj.getProp("hasActivity", result.hasActivity)
  discard jsonObj.getProp("alreadyCreated", result.alreadyCreated)
