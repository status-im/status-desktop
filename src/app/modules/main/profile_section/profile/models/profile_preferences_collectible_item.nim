import json, strutils, strformat, stint, json_serialization, tables

import profile_preferences_base_item

import app_service/service/profile/dto/profile_showcase_preferences
import app/modules/shared_models/collectibles_entry

include app_service/common/json_utils
include app_service/common/utils

type
  ProfileShowcaseCollectibleItem* = ref object of ProfileShowcaseBaseItem
    chainId*: int
    tokenId*: string
    contractAddress*: string
    communityId*: string
    name*: string
    collectionName*: string
    imageUrl*: string
    backgroundColor*: string
    loading*: bool

proc initProfileShowcaseCollectibleItem*(collectible: CollectiblesEntry, visibility: ProfileShowcaseVisibility, order: int): ProfileShowcaseCollectibleItem =
  result = ProfileShowcaseCollectibleItem()
  result.contractAddress = collectible.getContractAddress()
  result.chainId = collectible.getChainID()
  result.tokenId = collectible.getTokenIDAsString()
  result.communityId = collectible.getCommunityId()
  result.name = collectible.getName()
  result.collectionName = collectible.getCollectionName()
  result.imageUrl = collectible.getImageURL()
  result.backgroundColor = collectible.getBackgroundColor()
  result.showcaseVisibility = visibility
  result.order = order
  result.loading = false

proc toProfileShowcaseCollectibleItem*(jsonObj: JsonNode): ProfileShowcaseCollectibleItem =
  result = ProfileShowcaseCollectibleItem()

  discard jsonObj.getProp("order", result.order)
  var visibilityInt: int
  if (jsonObj.getProp("showcaseVisibility", visibilityInt) and
    (visibilityInt >= ord(low(ProfileShowcaseVisibility)) and
    visibilityInt <= ord(high(ProfileShowcaseVisibility)))):
      result.showcaseVisibility = ProfileShowcaseVisibility(visibilityInt)

  discard jsonObj.getProp("chainId", result.chainId)
  discard jsonObj.getProp("tokenId", result.tokenId)
  discard jsonObj.getProp("contractAddress", result.contractAddress)
  discard jsonObj.getProp("communityId", result.communityId)
  discard jsonObj.getProp("name", result.name)
  discard jsonObj.getProp("collectionName", result.collectionName)
  discard jsonObj.getProp("imageUrl", result.imageUrl)
  discard jsonObj.getProp("backgroundColor", result.backgroundColor)

proc toShowcasePreferenceItem*(self: ProfileShowcaseCollectibleItem): ProfileShowcaseCollectiblePreference =
  result = ProfileShowcaseCollectiblePreference()

  result.chainId = self.chainId
  result.tokenId = self.tokenId
  result.contractAddress = self.contractAddress
  result.showcaseVisibility = self.showcaseVisibility
  result.order = self.order

# NOTE: should be same as CollectiblesEntry::getID
proc getID*(self: ProfileShowcaseCollectibleItem): string =
  return fmt"{self.chainId}+{self.contractAddress}+{self.tokenId}"