import json, strutils

include ../../common/json_utils

type SavedAddressDto* = ref object of RootObj
  name*: string
  address*: string
  mixedcaseAddress*: string
  ens*: string
  colorId*: string
  isTest*: bool
  removed*: bool
  createdAt*: int64

proc toSavedAddressDto*(jsonObj: JsonNode): SavedAddressDto =
  result = SavedAddressDto()
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("address", result.address)
  discard jsonObj.getProp("mixedcaseAddress", result.mixedcaseAddress)
  discard jsonObj.getProp("ens", result.ens)
  discard jsonObj.getProp("colorId", result.colorId)
  result.colorId = result.colorId.toUpper()
    # to match `preDefinedWalletAccountColors` on the qml side
  discard jsonObj.getProp("isTest", result.isTest)
  discard jsonObj.getProp("createdAt", result.createdAt)
  discard jsonObj.getProp("removed", result.removed)

proc toJsonNode*(self: SavedAddressDto): JsonNode =
  result =
    %*{
      "name": self.name,
      "address": self.address,
      "mixedcaseAddress": self.mixedcaseAddress,
      "ens": self.ens,
      "colorId": self.colorId,
      "isTest": self.isTest,
      "createdAt": self.createdAt,
      "removed": self.removed,
    }
