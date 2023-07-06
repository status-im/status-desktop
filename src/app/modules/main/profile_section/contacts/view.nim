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
    # self.sentButRejectedContactRequestsModelVariant.delete
    # self.sentButRejectedContactRequestsModel.delete
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

  proc contactInfoRequestFinished(self: View, publicKey: string, ok: bool) {.signal.}

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

  proc isBlockedContact*(self: View, publicKey: string): bool {.slot.} =
    return self.blockedContactsModel.isContactWithIdAdded(publicKey)

  proc hasPendingContactRequest*(self: View, publicKey: string): bool {.slot.} =
    return self.sentContactRequestsModel.isContactWithIdAdded(publicKey)

  proc sendContactRequest*(self: View, publicKey: string, message: string) {.slot.} =
    self.delegate.sendContactRequest(publicKey, message)

  proc switchToOrCreateOneToOneChat*(self: View, publicKey: string) {.slot.} =
    self.delegate.switchToOrCreateOneToOneChat(publicKey)

  proc acceptContactRequest*(self: View, publicKey: string, contactRequestId: string) {.slot.} =
    self.delegate.acceptContactRequest(publicKey, contactRequestId)

  proc dismissContactRequest*(self: View, publicKey: string, contactRequestId: string) {.slot.} =
    self.delegate.dismissContactRequest(publicKey, contactRequestId)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    self.delegate.changeContactNickname(publicKey, nickname)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)

  proc markUntrustworthy*(self: View, publicKey: string) {.slot.} =
    self.delegate.markUntrustworthy(publicKey)

  proc removeTrustStatus*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeTrustStatus(publicKey)

  proc getSentVerificationDetailsAsJson(self: View, publicKey: string): string {.slot.} =
    return self.delegate.getSentVerificationDetailsAsJson(publicKey)

  proc getVerificationDetailsFromAsJson(self: View, publicKey: string): string {.slot.} =
    return self.delegate.getVerificationDetailsFromAsJson(publicKey)

  proc sendVerificationRequest*(self: View, publicKey: string, challenge: string) {.slot.} =
    self.delegate.sendVerificationRequest(publicKey, challenge)

  proc cancelVerificationRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.cancelVerificationRequest(publicKey)

  proc verifiedTrusted*(self: View, publicKey: string) {.slot.} =
    self.delegate.verifiedTrusted(publicKey)

  proc verifiedUntrustworthy*(self: View, publicKey: string) {.slot.} =
    self.delegate.verifiedUntrustworthy(publicKey)

  proc shareUserUrlWithData*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithData(pubkey)

  proc shareUserUrlWithChatKey*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithChatKey(pubkey)

  proc shareUserUrlWithENS*(self: View, pubkey: string): string {.slot.} =
    return self.delegate.shareUserUrlWithENS(pubkey)

  proc declineVerificationRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.declineVerificationRequest(publicKey)

  proc acceptVerificationRequest*(self: View, publicKey: string, response: string) {.slot.} =
    self.delegate.acceptVerificationRequest(publicKey, response)

  proc requestContactInfo*(self: View, publicKey: string) {.slot.} =
    self.delegate.requestContactInfo(publicKey)

  proc onContactInfoRequestFinished*(self: View, publicKey: string, ok: bool) {.slot.} =
    self.contactInfoRequestFinished(publicKey, ok)