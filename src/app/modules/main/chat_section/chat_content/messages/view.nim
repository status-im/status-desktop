import NimQml, json
import model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model*: Model
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
    self.delegate.viewDidLoad()

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc toggleReaction*(self: View, messageId: string, emojiId: int) {.slot.} = 
    self.delegate.toggleReaction(messageId, emojiId)

  proc getNamesForReaction*(self: View, messageId: string, emojiId: int): string {.slot.} = 
    return $(%* self.model.getNamesForReaction(messageId, emojiId))