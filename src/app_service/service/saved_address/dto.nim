import json, sequtils, sugar

include  ../../common/json_utils

type 
  SavedAddressDto* = ref object of RootObj
    name*: string
    address*: string

proc newSavedAddressDto*(
  name: string,
  address: string,
): SavedAddressDto =
  return SavedAddressDto(
    name: name,
    address: address,
  )

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
