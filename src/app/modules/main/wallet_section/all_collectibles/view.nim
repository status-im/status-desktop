import NimQml, sequtils, strutils, chronicles

import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
  proc delete*(self: View) =
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate

  proc load*(self: View) =
    self.delegate.viewDidLoad()

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