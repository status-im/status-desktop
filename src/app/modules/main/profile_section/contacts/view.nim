import NimQml

import ../../../shared_models/user_model
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      myMutualContactsModel: Model
      myMutualContactsModelVariant: QVariant
      blockedContactsModel: Model
      blockedContactsModelVariant: QVariant
      receivedContactRequestsModel: Model
      receivedContactRequestsModelVariant: QVariant
      sentContactRequestsModel: Model
      sentContactRequestsModelVariant: QVariant
      # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
      # receivedButRejectedContactRequestsModel: Model
      # receivedButRejectedContactRequestsModelVariant: QVariant
      # sentButRejectedContactRequestsModel: Model
      # sentButRejectedContactRequestsModelVariant: QVariant

  proc delete*(self: View) =
    self.myMutualContactsModel.delete
    self.myMutualContactsModelVariant.delete
    self.blockedContactsModel.delete
    self.blockedContactsModelVariant.delete
    self.receivedContactRequestsModel.delete
    self.receivedContactRequestsModelVariant.delete
    self.sentContactRequestsModel.delete
    self.sentContactRequestsModelVariant.delete
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # self.receivedButRejectedContactRequestsModel.delete
    # self.receivedButRejectedContactRequestsModelVariant.delete
    # self.sentButRejectedContactRequestsModel.delete
    # self.sentButRejectedContactRequestsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.myMutualContactsModel = newModel()
    result.myMutualContactsModelVariant = newQVariant(result.myMutualContactsModel)
    result.blockedContactsModel = newModel()
    result.blockedContactsModelVariant = newQVariant(result.blockedContactsModel)
    result.receivedContactRequestsModel = newModel()
    result.receivedContactRequestsModelVariant = newQVariant(result.receivedContactRequestsModel)
    result.sentContactRequestsModel = newModel()
    result.sentContactRequestsModelVariant = newQVariant(result.sentContactRequestsModel)
    # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
    # result.receivedButRejectedContactRequestsModel = newModel()
    # result.receivedButRejectedContactRequestsModelVariant = newQVariant(result.receivedButRejectedContactRequestsModel)
    # result.sentButRejectedContactRequestsModel = newModel()
    # result.sentButRejectedContactRequestsModelVariant = newQVariant(result.sentButRejectedContactRequestsModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc myMutualContactsModel*(self: View): Model =
    return self.myMutualContactsModel

  proc blockedContactsModel*(self: View): Model =
    return self.blockedContactsModel

  proc receivedContactRequestsModel*(self: View): Model =
    return self.receivedContactRequestsModel
  
  proc sentContactRequestsModel*(self: View): Model =
    return self.sentContactRequestsModel

  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # proc receivedButRejectedContactRequestsModel*(self: View): Model =
  #   return self.receivedButRejectedContactRequestsModel

  # proc sentButRejectedContactRequestsModel*(self: View): Model =
  #   return self.sentButRejectedContactRequestsModel

  proc myMutualContactsModelChanged(self: View) {.signal.}
  proc getMyMutualContactsModel(self: View): QVariant {.slot.} =
    return self.myMutualContactsModelVariant
  QtProperty[QVariant] myMutualContactsModel:
    read = getMyMutualContactsModel
    notify = myMutualContactsModelChanged

  proc blockedContactsModelChanged(self: View) {.signal.}
  proc getBlockedContactsModel(self: View): QVariant {.slot.} =
    return self.blockedContactsModelVariant
  QtProperty[QVariant] blockedContactsModel:
    read = getBlockedContactsModel
    notify = blockedContactsModelChanged

  proc receivedContactRequestsModelChanged(self: View) {.signal.}
  proc getReceivedContactRequestsModel(self: View): QVariant {.slot.} =
    return self.receivedContactRequestsModelVariant
  QtProperty[QVariant] receivedContactRequestsModel:
    read = getReceivedContactRequestsModel
    notify = receivedContactRequestsModelChanged

  proc sentContactRequestsModelChanged(self: View) {.signal.}
  proc getSentContactRequestsModel(self: View): QVariant {.slot.} =
    return self.sentContactRequestsModelVariant
  QtProperty[QVariant] sentContactRequestsModel:
    read = getSentContactRequestsModel
    notify = sentContactRequestsModelChanged

  # Temporary commented until we provide appropriate flags on the `status-go` side to cover all sections.
  # proc receivedButRejectedContactRequestsModelChanged(self: View) {.signal.}
  # proc getReceivedButRejectedContactRequestsModel(self: View): QVariant {.slot.} =
  #   return self.receivedButRejectedContactRequestsModelVariant
  # QtProperty[QVariant] receivedButRejectedContactRequestsModel:
  #   read = getReceivedButRejectedContactRequestsModel
  #   notify = receivedButRejectedContactRequestsModelChanged

  # proc sentButRejectedContactRequestsModelChanged(self: View) {.signal.}
  # proc getSentButRejectedContactRequestsModel(self: View): QVariant {.slot.} =
  #   return self.sentButRejectedContactRequestsModelVariant
  # QtProperty[QVariant] sentButRejectedContactRequestsModel:
  #   read = getSentButRejectedContactRequestsModel
  #   notify = sentButRejectedContactRequestsModelChanged

  proc isMyMutualContact*(self: View, publicKey: string): bool {.slot.} =
    return self.myMutualContactsModel.isContactWithIdAdded(publicKey)

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(publicKey)

  proc switchToOrCreateOneToOneChat*(self: View, publicKey: string) {.slot.} =
    self.delegate.switchToOrCreateOneToOneChat(publicKey)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    self.delegate.changeContactNickname(publicKey, nickname)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)

  proc removeContactRequestRejection*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContactRequestRejection(publicKey)