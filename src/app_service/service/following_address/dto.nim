import json, strutils

include ../../common/json_utils

type
  FollowingAddressDto* = ref object of RootObj
    address*: string
    tags*: seq[string]
    ensName*: string  # From EFP API
    avatar*: string   # Avatar URL from EFP API
    records*: JsonNode  # Social links and other ENS records from EFP API

proc toFollowingAddressDto*(jsonObj: JsonNode): FollowingAddressDto =
  result = FollowingAddressDto()
  discard jsonObj.getProp("address", result.address)
  
  # Handle tags array manually since getProp doesn't support seq[string]
  if jsonObj.hasKey("tags") and jsonObj["tags"].kind == JArray:
    result.tags = @[]
    for tag in jsonObj["tags"]:
      if tag.kind == JString:
        result.tags.add(tag.getStr())
  else:
    result.tags = @[]
    
  # Get ENS data from JSON (provided by EFP API)
  discard jsonObj.getProp("ensName", result.ensName)
  discard jsonObj.getProp("avatar", result.avatar)
  
  # Get records object if present
  if jsonObj.hasKey("records"):
    result.records = jsonObj["records"]
  else:
    result.records = newJObject()

proc toJsonNode*(self: FollowingAddressDto): JsonNode =
  result = %* {
    "address": self.address,
    "tags": self.tags,
    "ensName": self.ensName,
    "avatar": self.avatar,
    "records": self.records
  }
