import json, strutils

include  ../../common/json_utils

type
  SavedAddressDto* = ref object of RootObj
    name*: string
    address*: string
    ens*: string
    colorId*: string
    chainShortNames*: string
    isTest*: bool
    createdAt*: int64

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("ens", result.ens)
  discard jsonObj.getProp("colorId", result.colorId)
  result.colorId = result.colorId.toUpper() # to match `preDefinedWalletAccountColors` on the qml side
  discard jsonObj.getProp("chainShortNames", result.chainShortNames)
  discard jsonObj.getProp("isTest", result.isTest)
  discard jsonObj.getProp("createdAt", result.createdAt)