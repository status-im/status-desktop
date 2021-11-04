import NimQml
import ../../../shared_models/message_model as pinned_msg_model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model*: pinned_msg_model.Model
      modelVariant: QVariant
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = pinned_msg_model.newModel()
    result.modelVariant = newQVariant(result.model)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc getInputAreaModule(self: View): QVariant {.slot.} =
    return self.delegate.getInputAreaModule()

  QtProperty[QVariant] inputAreaModule:
    read = getInputAreaModule


  proc getMessagesModule(self: View): QVariant {.slot.} =
    return self.delegate.getMessagesModule()

  QtProperty[QVariant] messagesModule:
    read = getMessagesModule


  proc getUsersModule(self: View): QVariant {.slot.} =
    return self.delegate.getUsersModule()

  QtProperty[QVariant] usersModule:
    read = getUsersModule


  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc unpinMessage*(self: View, messageId: string) {.slot.} = 
    self.delegate.unpinMessage(messageId)