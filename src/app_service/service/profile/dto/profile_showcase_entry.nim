import json, strformat, strutils, stint, json_serialization, tables
include ../../../common/json_utils
include ../../../common/utils

type ProfileShowcaseEntryType* {.pure.}= enum
  Community = 0,
  Account = 1,
  Collectible = 2,
  Asset = 3,

type ProfileShowcaseVisibility* {.pure.}= enum
  ToNoOne = 0,
  ToIDVerifiedContacts = 1,
  ToContacts = 2,
  ToEveryone = 3,

type ProfileShowcaseEntryDto* = ref object of RootObj
  id*: string
  entryType*: ProfileShowcaseEntryType
  visibility*: ProfileShowcaseVisibility
  order*: int

proc `$`*(self: ProfileShowcaseEntryDto): string =
  result = fmt"""ProfileShowcaseEntryDto(
    id: {$self.id},
    entryType: {self.entryType},
    visibility: {self.visibility},
    order: {self.order}
    )"""

proc toProfileShowcaseEntryDto*(jsonObj: JsonNode): ProfileShowcaseEntryDto =
  result = ProfileShowcaseEntryDto()
  discard jsonObj.getProp("id", result.id)
  discard jsonObj.getProp("order", result.order)

  var entryTypeInt: int
  if (jsonObj.getProp("type", entryTypeInt) and
    (entryTypeInt >= ord(low(ProfileShowcaseEntryType)) and
    entryTypeInt <= ord(high(ProfileShowcaseEntryType)))):
      result.entryType = ProfileShowcaseEntryType(entryTypeInt)

  var visibilityInt: int
  if (jsonObj.getProp("contactVerificationStatus", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.visibility = ProfileShowcaseVisibility(visibilityInt)

proc parseProfileShowcaseEntries*(jsonMsgs: JsonNode): Table[string, ProfileShowcaseEntryDto] =
  var entries: Table[string, ProfileShowcaseEntryDto] = initTable[string, ProfileShowcaseEntryDto]()
  for jsonMsg in jsonMsgs:
    let item = jsonMsg.toProfileShowcaseEntryDto()
    entries.add(item.id, item)
  return entries
