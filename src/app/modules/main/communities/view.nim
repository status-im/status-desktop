import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/active_section

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: SectionModel
      modelVariant: QVariant
      observedItem: ActiveSection
      observedItemVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.observedItem.delete
    self.observedItemVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.observedItem = newActiveSection()
    result.observedItemVariant = newQVariant(result.observedItem)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc addItem*(self: View, item: SectionItem) =
    self.model.addItem(item)

  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.modelVariant)

  QtProperty[QVariant] model:
    read = getModel

  proc observedItemChanged*(self:View) {.signal.}

  proc getObservedItem(self: View): QVariant {.slot.} =
    return self.observedItemVariant

  QtProperty[QVariant] observedCommunity:
    read = getObservedItem
    notify = observedItemChanged
    
  proc setObservedCommunity*(self: View, itemId: string) {.slot.} =
    let item = self.model.getItemById(itemId)
    if (item.id == ""):
      return
    self.observedItem.setActiveSectionData(item)
    
  proc joinCommunity*(self: View, communityId: string): string {.slot.} =
    result = self.delegate.joinCommunity(communityId)
 