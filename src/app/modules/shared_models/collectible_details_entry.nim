import NimQml, json, strformat, sequtils, strutils, stint, strutils

import backend/collectibles as backend
import collectible_trait_model

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
      data: backend.CollectibleDetails
      extradata: ExtraData
      traits: TraitModel

  proc setup(self: CollectibleDetailsEntry) =
    self.QObject.setup

  proc delete*(self: CollectibleDetailsEntry) =
    self.QObject.delete

  proc newCollectibleDetailsFullEntry*(data: backend.CollectibleDetails, extradata: ExtraData): CollectibleDetailsEntry =
    new(result, delete)
    result.id = data.id
    result.data = data
    result.extradata = extradata
    result.traits = newTraitModel()
    result.traits.setItems(data.traits)
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
    if self.data == nil:
      return ""
    return self.data.name

  QtProperty[string] name:
    read = getName

  proc getImageURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.imageUrl

  QtProperty[string] imageUrl:
    read = getImageURL

  proc getMediaURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.animationUrl

  QtProperty[string] mediaUrl:
    read = getMediaURL

  proc getMediaType*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.animationMediaType

  QtProperty[string] mediaType:
    read = getMediaType

  proc getBackgroundColor*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.backgroundColor

  QtProperty[string] backgroundColor:
    read = getBackgroundColor

  proc getCollectionName*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.collectionName

  QtProperty[string] collectionName:
    read = getCollectionName

  proc getDescription*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.description

  QtProperty[string] description:
    read = getDescription

  proc getCollectionImageURL*(self: CollectibleDetailsEntry): string {.slot.} =
    if self.data == nil:
      return ""
    return self.data.collectionImageUrl

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

  proc getNetworkColor*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.extradata.networkColor

  QtProperty[string] networkColor:
    read = getNetworkColor

  proc getNetworkIconURL*(self: CollectibleDetailsEntry): string {.slot.} =
    return self.extradata.networkIconURL

  QtProperty[string] networkIconUrl:
    read = getNetworkIconURL