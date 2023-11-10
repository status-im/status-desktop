import NimQml, json, strformat, sequtils, strutils, stint, strutils
import options

import backend/collectibles as backend
import collectible_trait_model
import ../../../app_service/service/community_tokens/dto/community_token 

# Additional data needed to build an Entry, which is
# not included in the backend data and needs to be
# fetched from a different source.
type
  ExtraData* = object
    networkShortName*: string
    networkColor*: string
    networkIconURL*: string

# It is used to display a detailed collectibles entry in the QML UI
QtObject:
  type
    CollectibleDetailsEntry* = ref object of QObject
      id: backend.CollectibleUniqueID
      data: backend.Collectible
      extradata: ExtraData
      traits: TraitModel

  proc setup(self: CollectibleDetailsEntry) =
    self.QObject.setup

  proc delete*(self: CollectibleDetailsEntry) =
    self.QObject.delete

  proc newCollectibleDetailsFullEntry*(data: backend.Collectible, extradata: ExtraData): CollectibleDetailsEntry =
    new(result, delete)
    result.id = data.id
    result.data = data
    result.extradata = extradata
    result.traits = newTraitModel()
    if isSome(data.collectibleData) and isSome(data.collectibleData.get().traits):
      let traits = data.collectibleData.get().traits.get()
      result.traits.setItems(traits)
    result.setup()

  proc newCollectibleDetailsBasicEntry*(id: backend.CollectibleUniqueID, extradata: ExtraData): CollectibleDetailsEntry =
    new(result, delete)
    result.id = id
    result.extradata = extradata
    result.traits = newTraitModel()
    result.setup()

  proc newCollectibleDetailsEmptyEntry*(): CollectibleDetailsEntry =
    let id = backend.CollectibleUniqueID(
      contractID: backend.ContractID(
        chainID: 0,
        address: ""
      ),
      tokenID: stint.u256(0)
    )
    let extradata = ExtraData()
    return newCollectibleDetailsBasicEntry(id, extradata)

  proc `$`*(self: CollectibleDetailsEntry): string =
    return fmt"""CollectibleDetailsEntry(
      id:{self.id},
      data:{self.data},
      extradata:{self.extradata},
      traits:{self.traits}
    )"""

  proc hasCollectibleData(self: CollectibleDetailsEntry): bool =
    return self.data != nil and isSome(self.data.collectibleData)

  proc getCollectibleData(self: CollectibleDetailsEntry): backend.CollectibleData =
    return self.data.collectibleData.get()

  proc hasCollectionData(self: CollectibleDetailsEntry): bool =
    return self.data != nil and isSome(self.data.collectionData)

  proc getCollectionData(self: CollectibleDetailsEntry): backend.CollectionData =
    return self.data.collectionData.get()

  proc hasCommunityData(self: CollectibleDetailsEntry): bool =
    return self.data != nil and isSome(self.data.communityData)

  proc getCommunityData(self: CollectibleDetailsEntry): backend.CommunityData =
    return self.data.communityData.get()

  proc getChainID*(self: CollectibleDetailsEntry): int {.slot.} =
    return self.id.contractID.chainID

  QtProperty[int] chainId:
    read = getChainID

  proc getContractAddress*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.id.contractID.address

  QtProperty[string] contractAddress:
    read = getContractAddress

  proc getTokenID*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.id.tokenID.toString()

  QtProperty[string] tokenId:
    read = getTokenID

  proc getName*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectibleData():
      return ""
    return self.data.collectibleData.get().name

  QtProperty[string] name:
    read = getName

  proc getImageURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectibleData() or isNone(self.getCollectibleData().imageUrl):
      return ""
    return self.getCollectibleData().imageUrl.get()

  QtProperty[string] imageUrl:
    read = getImageURL

  proc getMediaURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectibleData() or isNone(self.getCollectibleData().animationUrl):
      return ""
    return self.getCollectibleData().animationUrl.get()

  QtProperty[string] mediaUrl:
    read = getMediaURL

  proc getMediaType*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectibleData() or isNone(self.getCollectibleData().animationMediaType):
      return ""
    return self.getCollectibleData().animationMediaType.get()

  QtProperty[string] mediaType:
    read = getMediaType

  proc getBackgroundColor*(self: CollectibleDetailsEntry): string {.slot.} =
    var color = "transparent"
    if self.hasCollectibleData() and isSome(self.getCollectibleData().backgroundColor):
      let backgroundColor = self.getCollectibleData().backgroundColor.get()
      if backgroundColor != "":
        color = "#" & backgroundColor
    return color

  QtProperty[string] backgroundColor:
    read = getBackgroundColor

  proc getDescription*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectibleData() or isNone(self.getCollectibleData().description):
      return ""
    return self.getCollectibleData().description.get()

  QtProperty[string] description:
    read = getDescription

  proc getCollectionName*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectionData():
      return ""
    return self.getCollectionData().name

  QtProperty[string] collectionName:
    read = getCollectionName

  proc getCollectionImageURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCollectionData():
      return ""
    return self.getCollectionData().imageUrl

  QtProperty[string] collectionImageUrl:
    read = getCollectionImageURL

  proc getTraits*(self: CollectibleDetailsEntry): QVariant {.slot.} =
    return newQVariant(self.traits)

  QtProperty[QVariant] traits:
    read = getTraits

  proc getNetworkShortName*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.extradata.networkShortName

  QtProperty[string] networkShortName:
    read = getNetworkShortName

  proc getCommunityId*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCommunityData():
      return ""
    return self.getCommunityData().id

  QtProperty[string] communityId:
    read = getCommunityId

  proc getCommunityName*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCommunityData():
      return ""
    return self.getCommunityData().name

  QtProperty[string] communityName:
    read = getCommunityName

  proc getCommunityColor*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCommunityData():
      return ""
    return self.getCommunityData().color

  QtProperty[string] communityColor:
    read = getCommunityColor

  proc getCommunityPrivilegesLevel*(self: CollectibleDetailsEntry): int {.slot.} =
    if not self.hasCommunityData():
      return PrivilegesLevel.Community.int
    return int(self.getCommunityData().privilegesLevel)

  QtProperty[int] communityPrivilegesLevel:
    read = getCommunityPrivilegesLevel

  proc getCommunityImage*(self: CollectibleDetailsEntry): string {.slot.} =
    if not self.hasCommunityData() or isNone(self.getCommunityData().imageUrl):
      return ""
    return self.getCommunityData().imageUrl.get()

  QtProperty[string] communityImage:
    read = getCommunityImage

  proc getNetworkColor*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.extradata.networkColor

  QtProperty[string] networkColor:
    read = getNetworkColor

  proc getNetworkIconURL*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.extradata.networkIconURL

  QtProperty[string] networkIconUrl:
    read = getNetworkIconURL