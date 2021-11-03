import NimQml
import model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      
  proc delete*(self: View) =
    self.model.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()

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