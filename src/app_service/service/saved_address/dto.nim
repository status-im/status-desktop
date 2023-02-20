import json

include  ../../common/json_utils

type
  SavedAddressDto* = ref object of RootObj
    name*: string
    address*: string
    ens*: string
    favourite*: bool
    chainShortNames*: string
    isTest*: bool

proc newSavedAddressDto*(
  name: string,
  address: string,
  ens: string,
  favourite: bool,
  chainShortNames: string,
  isTest: bool
): SavedAddressDto =
  return SavedAddressDto(
    name: name,
    address: address,
    ens: ens,
    favourite: favourite,
    chainShortNames: chainShortNames,
    isTest: isTest
  )

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("ens", result.ens)
  discard jsonObj.getProp("favourite", result.favourite)
  discard jsonObj.getProp("chainShortNames", result.chainShortNames)
  discard jsonObj.getProp("isTest", result.isTest)
