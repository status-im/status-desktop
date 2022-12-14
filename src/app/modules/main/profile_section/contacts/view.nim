import NimQml

import ../../../shared_models/user_model
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      contactsModel: Model
      contactsModelVariant: QVariant

  proc delete*(self: View) =
    self.contactsModel.delete
    self.contactsModelVariant.delete

    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.contactsModel = newModel()
    result.contactsModelVariant = newQVariant(result.contactsModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc contactsModel*(self: View): Model =
    return self.contactsModel

  proc contactsModelChanged(self: View) {.signal.}
  proc getContactsModel(self: View): QVariant {.slot.} =
    return self.contactsModelVariant

  QtProperty[QVariant] contactsModel:
    read = getContactsModel
    notify = contactsModelChanged

  proc sendContactRequest*(self: View, publicKey: string, message: string) {.slot.} =
    self.delegate.sendContactRequest(publicKey, message)

  proc switchToOrCreateOneToOneChat*(self: View, publicKey: string) {.slot.} =
    self.delegate.switchToOrCreateOneToOneChat(publicKey)

  proc acceptContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.acceptContactRequest(publicKey)

  proc dismissContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.dismissContactRequest(publicKey)

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

  proc removeContactRequestRejection*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContactRequestRejection(publicKey)
    
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

  proc declineVerificationRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.declineVerificationRequest(publicKey)

  proc acceptVerificationRequest*(self: View, publicKey: string, response: string) {.slot.} =
    self.delegate.acceptVerificationRequest(publicKey, response)

