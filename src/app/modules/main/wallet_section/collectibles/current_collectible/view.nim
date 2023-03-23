import NimQml, sequtils, sugar, stint

import ./io_interface
import ../../../../../../app_service/service/network/dto as network_dto
import ../models/collectibles_item
import ../models/collectible_trait_item
import ../models/collectible_trait_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

      networkShortName: string
      networkColor: string
      networkIconUrl: string

      collectible: Item
      propertiesModel: TraitModel
      rankingsModel: TraitModel
      statsModel: TraitModel

  proc setup(self: View) =
    self.QObject.setup

  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.setup()
    result.delegate = delegate
    result.collectible = initItem()
    result.propertiesModel = newTraitModel()
    result.rankingsModel = newTraitModel()
    result.statsModel = newTraitModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getNetworkShortName(self: View): QVariant {.slot.} =
    return newQVariant(self.networkShortName)

  proc networkShortNameChanged(self: View) {.signal.}

  QtProperty[QVariant] networkShortName:
    read = getNetworkShortName
    notify = networkShortNameChanged

  proc getNetworkColor(self: View): QVariant {.slot.} =
    return newQVariant(self.networkColor)

  proc networkColorChanged(self: View) {.signal.}

  QtProperty[QVariant] networkColor:
    read = getNetworkColor
    notify = networkColorChanged

  proc getNetworkIconUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.networkIconUrl)

  proc networkIconUrlChanged(self: View) {.signal.}

  QtProperty[QVariant] networkIconUrl:
    read = getNetworkIconUrl
    notify = networkIconUrlChanged

  proc currentCollectibleChanged(self: View) {.signal.}

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getName())
  QtProperty[QVariant] name:
    read = getName
    notify = currentCollectibleChanged

  proc getID(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getId())
  QtProperty[QVariant] id:
    read = getID
    notify = currentCollectibleChanged

  proc getTokenID(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getTokenId().toString())
  QtProperty[QVariant] tokenId:
    read = getTokenID
    notify = currentCollectibleChanged

  proc getDescription(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getDescription())
  QtProperty[QVariant] description:
    read = getDescription
    notify = currentCollectibleChanged

  proc getBackgroundColor(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getBackgroundColor())
  QtProperty[QVariant] backgroundColor:
    read = getBackgroundColor
    notify = currentCollectibleChanged

  proc getMediaUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getMediaUrl())
  QtProperty[QVariant] mediaUrl:
    read = getMediaUrl
    notify = currentCollectibleChanged

  proc getMediaType(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getMediaType())
  QtProperty[QVariant] mediaType:
    read = getMediaType
    notify = currentCollectibleChanged

  proc getImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getImageUrl())
  QtProperty[QVariant] imageUrl:
    read = getImageUrl
    notify = currentCollectibleChanged

  proc getCollectionName(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getCollectionName())
  QtProperty[QVariant] collectionName:
    read = getCollectionName
    notify = currentCollectibleChanged

  proc getCollectionImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getCollectionImageUrl())
  QtProperty[QVariant] collectionImageUrl:
    read = getCollectionImageUrl
    notify = currentCollectibleChanged

  proc getPermalink(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getPermalink())
  QtProperty[QVariant] permalink:
    read = getPermalink
    notify = currentCollectibleChanged

  proc getProperties*(self: View): QVariant {.slot.} =
    return newQVariant(self.propertiesModel)
  QtProperty[QVariant] properties:
    read = getProperties
    notify = currentCollectibleChanged

  proc getRankings*(self: View): QVariant {.slot.} =
    return newQVariant(self.rankingsModel)
  QtProperty[QVariant] rankings:
    read = getRankings
    notify = currentCollectibleChanged

  proc getStats*(self: View): QVariant {.slot.} =
    return newQVariant(self.statsModel)
  QtProperty[QVariant] stats:
    read = getStats
    notify = currentCollectibleChanged

  proc update*(self: View, address: string, tokenId: string) {.slot.} =
    self.delegate.update(address, parse(tokenId, Uint256))

  proc setData*(self: View, collectible: Item, network: network_dto.NetworkDto) =
    if (self.networkShortName != network.shortName):
      self.networkShortName = network.shortName
      self.networkShortNameChanged()

    if (self.networkColor != network.chainColor):
      self.networkColor = network.chainColor
      self.networkColorChanged()

    if (self.networkIconUrl != network.iconURL):
      self.networkIconUrl = network.iconURL
      self.networkIconUrlChanged()

    self.collectible = collectible
    self.propertiesModel.setItems(collectible.getProperties())
    self.rankingsModel.setItems(collectible.getRankings())
    self.statsModel.setItems(collectible.getStats())

    self.currentCollectibleChanged()