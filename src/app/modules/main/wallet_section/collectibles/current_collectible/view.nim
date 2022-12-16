import NimQml, sequtils, sugar

import ./io_interface
import ../../../../../../app_service/service/network/dto as network_dto
import ../../../../../../app_service/service/collectible/dto as collectible_dto
import ../models/collectible_trait_item
import ../models/collectible_trait_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

      networkName: string
      networkColor: string
      networkIconUrl: string

      collectionName: string
      collectionImageUrl: string

      name: string
      id: string
      description: string
      backgroundColor: string
      imageUrl: string
      permalink: string
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
    result.description = "Collectibles"
    result.backgroundColor = "transparent"
    result.propertiesModel = newTraitModel()
    result.rankingsModel = newTraitModel()
    result.statsModel = newTraitModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getNetworkName(self: View): QVariant {.slot.} =
    return newQVariant(self.networkName)

  proc networkNameChanged(self: View) {.signal.}

  QtProperty[QVariant] networkName:
    read = getNetworkName
    notify = networkNameChanged

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
    return newQVariant(self.name)

  proc nameChanged(self: View) {.signal.}

  QtProperty[QVariant] name:
    read = getName
    notify = nameChanged

  proc getID(self: View): QVariant {.slot.} =
    return newQVariant(self.id)

  proc idChanged(self: View) {.signal.}

  QtProperty[QVariant] id:
    read = getID
    notify = idChanged

  proc getDescription(self: View): QVariant {.slot.} =
    return newQVariant(self.description)

  proc descriptionChanged(self: View) {.signal.}

  QtProperty[QVariant] description:
    read = getDescription
    notify = descriptionChanged

  proc getBackgroundColor(self: View): QVariant {.slot.} =
    return newQVariant(self.backgroundColor)

  proc backgroundColorChanged(self: View) {.signal.}

  QtProperty[QVariant] backgroundColor:
    read = getBackgroundColor
    notify = backgroundColorChanged

  proc getImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.imageUrl)

  proc imageUrlChanged(self: View) {.signal.}

  QtProperty[QVariant] imageUrl:
    read = getImageUrl
    notify = imageUrlChanged

  proc getCollectionName(self: View): QVariant {.slot.} =
    return newQVariant(self.collectionName)

  proc collectionNameChanged(self: View) {.signal.}

  QtProperty[QVariant] collectionName:
    read = getCollectionName
    notify = collectionNameChanged

  proc getCollectionImageUrl(self: View): QVariant {.slot.} =
    return newQVariant(self.collectionImageUrl)

  proc collectionImageUrlChanged(self: View) {.signal.}

  QtProperty[QVariant] collectionImageUrl:
    read = getCollectionImageUrl
    notify = collectionImageUrlChanged

  proc getPermalink(self: View): QVariant {.slot.} =
    return newQVariant(self.permalink)

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

  QtProperty[QVariant] rankings:
    read = getStats
    notify = statsChanged

  proc update*(self: View, collectionSlug: string, id: int) {.slot.} =
    self.delegate.update(collectionSlug, id)

  proc setData*(self: View, collection: collectible_dto.CollectionDto, collectible: collectible_dto.CollectibleDto, network: network_dto.NetworkDto) =
    if (self.networkName != network.chainName):
      self.networkName = network.chainName
      self.networkNameChanged()

    if (self.networkColor != network.chainColor):
      self.networkColor = network.chainColor
      self.networkColorChanged()

    if (self.networkIconUrl != network.iconURL):
      self.networkIconUrl = network.iconURL
      self.networkIconUrlChanged()

    if (self.collectionName != collection.name):
      self.collectionName = collection.name
      self.collectionNameChanged()

    if (self.collectionImageUrl != collection.imageUrl):
      self.collectionImageUrl = collection.imageUrl
      self.collectionImageUrlChanged()
    
    if (self.name != collectible.name):
      self.name = collectible.name
      self.nameChanged()

    let idString = $collectible.id
    if (self.id != idString):
      self.id = idString
      self.idChanged()

    if (self.description != collectible.description):
      self.description = collectible.description
      self.descriptionChanged()

    let backgroundColor = if (collectible.backgroundColor == ""): "transparent" else: ("#" & collectible.backgroundColor)
    if (self.backgroundColor != backgroundColor):
      self.backgroundColor = backgroundColor
      self.backgroundColorChanged()

    if (self.imageUrl != collectible.imageUrl):
      self.imageUrl = collectible.imageUrl
      self.imageUrlChanged()

    self.propertiesModel.setItems(collectible.properties.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)))
    self.propertiesChanged()

    self.rankingsModel.setItems(collectible.rankings.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)))
    self.rankingsChanged()

    self.statsModel.setItems(collectible.statistics.map(t => initTrait(t.traitType, t.value, t.displayType, t.maxValue)))
    self.statsChanged()
