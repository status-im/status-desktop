import json

include  ../../common/json_utils

type
  SavedAddressDto* = ref object of RootObj
    name*: string
    address*: string
    ens*: string
    favourite*: bool

proc newSavedAddressDto*(
  name: string,
  address: string,
  favourite: bool
): SavedAddressDto =
  return SavedAddressDto(
    name: name,
    address: address,
    favourite: favourite
  )

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("favourite", result.favourite)
