import json
import backend/collectibles_types

type CommunityCollectibleOwner* = object
  contactId*: string
  name*: string
  imageSource*: string
  collectibleOwner*: CollectibleOwner

proc toCommunityCollectibleOwners*(
    jsonAsset: JsonNode
): seq[CommunityCollectibleOwner] =
  var ownerList: seq[CommunityCollectibleOwner] = @[]
  for item in jsonAsset.items:
    ownerList.add(
      CommunityCollectibleOwner(
        contactId: item{"contactId"}.getStr,
        name: item{"name"}.getStr,
        imageSource: item{"imageSource"}.getStr,
        collectibleOwner: getCollectibleOwner(item{"collectibleOwner"}),
      )
    )
  return ownerList
