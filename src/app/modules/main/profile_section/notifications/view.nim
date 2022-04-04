import NimQml
import io_interface, model

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      exemptionsModel: Model
      exemptionsModelVariant: QVariant
      
  proc delete*(self: View) =
    self.exemptionsModel.delete
    self.exemptionsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.exemptionsModel = newModel()
    result.exemptionsModelVariant = newQVariant(result.exemptionsModel)
    
  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc sendTestNotification*(self: View, title: string, message: string) {.slot.} =
    self.delegate.sendTestNotification(title, message)

  proc exemptionsModel*(self: View): Model =
    return self.exemptionsModel

  proc exemptionsModelChanged*(self: View) {.signal.}
  proc getExemptionsModel(self: View): QVariant {.slot.} =
    return self.exemptionsModelVariant
  QtProperty[QVariant] exemptionsModel:
    read = getExemptionsModel
    notify = exemptionsModelChanged

  proc saveExemptions*(self: View, itemId: string, muteAllMessages: bool, personalMentions: string, 
    globalMentions: string, otherMessages: string) {.slot.} =
    self.delegate.saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, otherMessages)