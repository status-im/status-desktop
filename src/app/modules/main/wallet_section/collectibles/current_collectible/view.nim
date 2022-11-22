import NimQml, sequtils, sugar

import ./io_interface
import ../collections/model as collections_model
import ../collectibles/model as collectibles_model
import ../collections/item as collection_item
import ../collectibles/item as collectible_item
import ../collectibles/trait_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface

      name: string
      id: string
      description: string
      backgroundColor: string
      imageUrl: string
      collectionID: string
      collectionImageUrl: string
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

  proc getCollectionID(self: View): QVariant {.slot.} =
    return newQVariant(self.collectionID)

  proc collectionIDChanged(self: View) {.signal.}

  QtProperty[QVariant] collectionID:
    read = getCollectionID
    notify = collectionIDChanged

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

  proc update*(self: View, slug: string, id: int) {.slot.} =
    self.delegate.update(slug, id)

  proc setData*(self: View, collection: collection_item.Item, collectible: collectible_item.Item) =
    if (self.name != collectible.getName()):
      self.name = collectible.getName()
      self.nameChanged()

    let idString = $collectible.getId()
    if (self.id != idString):
      self.id = idString
      self.idChanged()

    if (self.description != collectible.getDescription()):
      self.description = collectible.getDescription()
      self.descriptionChanged()

    if (self.backgroundColor != collectible.getBackgroundColor()):
      self.backgroundColor = collectible.getBackgroundColor()
      self.backgroundColorChanged()

    if (self.imageUrl != collectible.getImageUrl()):
      self.imageUrl = collectible.getImageUrl()
      self.imageUrlChanged()

    if (self.collectionImageUrl != collection.getImageUrl()):
      self.collectionImageUrl = collection.getImageUrl()
      self.collectionImageUrlChanged()

    self.propertiesModel.setItems(collectible.getProperties())
    self.propertiesChanged()

    self.rankingsModel.setItems(collectible.getRankings())
    self.rankingsChanged()

    self.statsModel.setItems(collectible.getStats())
    self.statsChanged()
