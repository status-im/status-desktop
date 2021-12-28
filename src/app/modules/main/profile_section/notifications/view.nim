import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      mutedContactsModel: Model
      mutedContactsModelVariant: QVariant
      mutedChatsModel: Model
      mutedChatsModelVariant: QVariant
      
  proc delete*(self: View) =
    self.mutedContactsModel.delete
    self.mutedContactsModelVariant.delete
    self.mutedChatsModel.delete
    self.mutedChatsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.mutedContactsModel = newModel()
    result.mutedContactsModelVariant = newQVariant(result.mutedContactsModel)
    result.mutedChatsModel = newModel()
    result.mutedChatsModelVariant = newQVariant(result.mutedChatsModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc mutedContactsModel*(self: View): Model =
    return self.mutedContactsModel

  proc mutedContactsModelChanged*(self: View) {.signal.}
  proc getMutedContactsModel(self: View): QVariant {.slot.} =
    return self.mutedContactsModelVariant
  QtProperty[QVariant] mutedContactsModel:
    read = getMutedContactsModel
    notify = mutedContactsModelChanged

  proc mutedChatsModel*(self: View): Model =
    return self.mutedChatsModel

  proc mutedChatsModelChanged*(self: View) {.signal.}
  proc getMutedChatsModel(self: View): QVariant {.slot.} =
    return self.mutedChatsModelVariant
  QtProperty[QVariant] mutedChatsModel:
    read = getMutedChatsModel
    notify = mutedChatsModelChanged

  proc unmuteChat*(self: View, chatId: string) {.slot.} =
    self.delegate.unmuteChat(chatId)