import NimQml
import model, item
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      
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

  proc load*(self: View) =
    # In some point, here, we will setup some exposed main module related things.
    self.delegate.viewDidLoad()

  proc addItem*(self: View, item: Item) =
    self.model.addItem(item)

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] sectionsModel:
    read = getModel
    notify = modelChanged

  proc openStoreToKeychainPopup*(self: View) {.signal.}

  proc offerToStorePassword*(self: View) =
    self.openStoreToKeychainPopup()

  proc storePassword*(self: View, password: string) {.slot.} =
    self.delegate.storePassword(password)
  
  proc storingPasswordError*(self:View, errorDescription: string) {.signal.}

  proc emitStoringPasswordError*(self: View, errorDescription: string) =
    self.storingPasswordError(errorDescription)
  
  proc storingPasswordSuccess*(self:View) {.signal.}

  proc emitStoringPasswordSuccess*(self: View) =
    self.storingPasswordSuccess()

  proc setUserStatus*(self: View, status: bool) {.slot.} =
    self.delegate.setUserStatus(status)
