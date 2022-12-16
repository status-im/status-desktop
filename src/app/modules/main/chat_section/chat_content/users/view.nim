import NimQml, sequtils, sugar
import ../../../../shared_models/[member_model, member_item]
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      temporaryModel: Model # used for editing purposes
      temporaryModelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.temporaryModel = newModel()
    result.temporaryModelVariant = newQVariant(result.temporaryModel)

  proc model*(self: View): Model =
    return self.model

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant]model:
    read = getModel
    notify = modelChanged

  proc getMembersPublicKeys*(self: View): string {.slot.} =
    return self.delegate.getMembersPublicKeys()

  proc temporaryModelChanged*(self: View) {.signal.}

  proc getTemporaryModel(self: View): QVariant {.slot.} =
    return self.temporaryModelVariant

  QtProperty[QVariant]temporaryModel:
    read = getTemporaryModel
    notify = temporaryModelChanged

  proc resetTemporaryModel*(self: View) {.slot.} =
    self.temporaryModel.setItems(self.model.getItems())

  proc appendTemporaryModel*(self: View, pubKey: string, displayName: string) {.slot.} =
    # for temporary model only pubKey and displayName is needed
    let userItem = initMemberItem(
      pubKey = pubKey,
      displayName = displayName,
      ensName = "",
      localNickname = "",
      alias = "",
      icon = "",
      colorId = 0,
      isVerified = false,
    )
    self.temporaryModel.addItem(userItem)

  proc removeFromTemporaryModel*(self: View, pubKey: string) {.slot.} =
    self.temporaryModel.removeItemById(pubKey)

  proc updateGroupMembers*(self: View) {.slot.} =
    let modelIDs = self.model.getItemIds()
    let temporaryModelIDs = self.temporaryModel.getItemIds()
    let membersAdded = filter(temporaryModelIDs, id => not modelIDs.contains(id))
    let membersRemoved = filter(modelIDs, id => not temporaryModelIDs.contains(id))
    if (membersAdded.len > 0):
      self.delegate.addGroupMembers(membersAdded)
    if (membersRemoved.len > 0):
      self.delegate.removeGroupMembers(membersRemoved)
