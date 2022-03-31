import json

include  ../../common/json_utils

type DerivedAddressDto* = object
  address*: string
  path*: string
  hasActivity*: bool

proc toDerivedAddressDto*(jsonObj: JsonNode): DerivedAddressDto =
  result = DerivedAddressDto()
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("path", result.path)
  discard jsonObj.getProp("hasActivity", result.hasActivity)
