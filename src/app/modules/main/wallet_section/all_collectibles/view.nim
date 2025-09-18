import nimqml, sequtils, strutils, chronicles

import ./io_interface

import app/modules/shared_models/collectibles_model as collectibles_model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      allCollectiblesModel: collectibles_model.Model

  proc delete*(self: View)
  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.allCollectiblesModel = delegate.getAllCollectiblesModel()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getAllCollectiblesModel(self: View): QVariant {.slot.} =
    return newQVariant(self.allCollectiblesModel)
  QtProperty[QVariant] allCollectiblesModel:
    read = getAllCollectiblesModel

  proc collectiblePreferencesUpdated*(self: View, result: bool) {.signal.}

  proc updateCollectiblePreferences*(self: View, collectiblePreferencesJson: string) {.slot.} =
    self.delegate.updateCollectiblePreferences(collectiblePreferencesJson)

  proc getCollectiblePreferencesJson(self: View): QVariant {.slot.} =
    let preferences = self.delegate.getCollectiblePreferencesJson()
    return newQVariant(preferences)

  QtProperty[QVariant] collectiblePreferencesJson:
    read = getCollectiblePreferencesJson

  proc collectibleGroupByCommunityChanged*(self: View) {.signal.}

  proc getCollectibleGroupByCommunity(self: View): bool {.slot.} =
    return self.delegate.getCollectibleGroupByCommunity()

  QtProperty[bool] collectibleGroupByCommunity:
    read = getCollectibleGroupByCommunity
    notify = collectibleGroupByCommunityChanged

  proc toggleCollectibleGroupByCommunity*(self: View): bool {.slot.} =
    if not self.delegate.toggleCollectibleGroupByCommunity():
      error "Failed to toggle collectibleGroupByCommunity"
      return
    self.collectibleGroupByCommunityChanged()

  proc collectibleGroupByCollectionChanged*(self: View) {.signal.}

  proc getCollectibleGroupByCollection(self: View): bool {.slot.} =
    return self.delegate.getCollectibleGroupByCollection()

  QtProperty[bool] collectibleGroupByCollection:
    read = getCollectibleGroupByCollection
    notify = collectibleGroupByCollectionChanged

  proc toggleCollectibleGroupByCollection*(self: View): bool {.slot.} =
    if not self.delegate.toggleCollectibleGroupByCollection():
      error "Failed to toggle collectibleGroupByCollection"
      return
    self.collectibleGroupByCollectionChanged()

  proc delete*(self: View) =
    self.QObject.delete

