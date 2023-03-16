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

  proc getName(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getName())

  proc nameChanged(self: View) {.signal.}

  QtProperty[QVariant] name:
    read = getName
    notify = nameChanged

  proc getID(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getId())

  proc idChanged(self: View) {.signal.}

  QtProperty[QVariant] id:
    read = getID
    notify = idChanged

  proc getTokenID(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getTokenId().toString())

  proc tokenIdChanged(self: View) {.signal.}

  QtProperty[QVariant] tokenId:
    read = getTokenID
    notify = tokenIdChanged

  proc getDescription(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getDescription())

  proc descriptionChanged(self: View) {.signal.}

  QtProperty[QVariant] description:
    read = getDescription
    notify = descriptionChanged

  proc getBackgroundColor(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getBackgroundColor())

  proc backgroundColorChanged(self: View) {.signal.}

  QtProperty[QVariant] backgroundColor:
    read = getBackgroundColor
    notify = backgroundColorChanged

  proc getImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getImageUrl())

  proc imageUrlChanged(self: View) {.signal.}

  QtProperty[QVariant] imageUrl:
    read = getImageUrl
    notify = imageUrlChanged

  proc getCollectionName(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getCollectionName())

  proc collectionNameChanged(self: View) {.signal.}

  QtProperty[QVariant] collectionName:
    read = getCollectionName
    notify = collectionNameChanged

  proc getCollectionImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getCollectionImageUrl())

  proc collectionImageUrlChanged(self: View) {.signal.}

  QtProperty[QVariant] collectionImageUrl:
    read = getCollectionImageUrl
    notify = collectionImageUrlChanged

  proc getPermalink(self: View): QVariant {.slot.} =
    return newQVariant(self.collectible.getPermalink())

  proc permalinkChanged(self: View) {.signal.}

  QtProperty[QVariant] permalink:
    read = getPermalink
    notify = permalinkChanged

  proc propertiesChanged(self: View) {.signal.}

  proc getProperties*(self: View): QVariant {.slot.} =
    return newQVariant(self.propertiesModel)

  QtProperty[QVariant] properties:
    read = getProperties
    notify = propertiesChanged

  proc rankingsChanged(self: View) {.signal.}

  proc getRankings*(self: View): QVariant {.slot.} =
    return newQVariant(self.rankingsModel)

  QtProperty[QVariant] rankings:
    read = getRankings
    notify = rankingsChanged

  proc statsChanged(self: View) {.signal.}

  proc getStats*(self: View): QVariant {.slot.} =
    return newQVariant(self.statsModel)

  QtProperty[QVariant] stats:
    read = getStats
    notify = statsChanged

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
    self.collectionNameChanged()
    self.collectionImageUrlChanged()
    self.nameChanged()
    self.idChanged()
    self.tokenIdChanged()
    self.descriptionChanged()
    self.backgroundColorChanged()
    self.imageUrlChanged()

    self.propertiesModel.setItems(collectible.getProperties())
    self.propertiesChanged()

    self.rankingsModel.setItems(collectible.getRankings())
    self.rankingsChanged()

    self.statsModel.setItems(collectible.getStats())
    self.statsChanged()
