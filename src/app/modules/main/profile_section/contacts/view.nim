import NimQml

import ../../../shared_models/contacts_model
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      myContactsModel: Model
      myContactsModelVariant: QVariant
      blockedContactsModel: Model
      blockedContactsModelVariant: QVariant

  proc delete*(self: View) =
    self.myContactsModel.delete
    self.myContactsModelVariant.delete
    self.blockedContactsModel.delete
    self.blockedContactsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.myContactsModel = newModel()
    result.myContactsModelVariant = newQVariant(result.myContactsModel)
    result.blockedContactsModel = newModel()
    result.blockedContactsModelVariant = newQVariant(result.blockedContactsModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc myContactsModel*(self: View): Model =
    return self.myContactsModel

  proc blockedContactsModel*(self: View): Model =
    return self.blockedContactsModel

  proc myContactsModelChanged(self: View) {.signal.}
  proc getMyContactsModel(self: View): QVariant {.slot.} =
    return self.myContactsModelVariant
  QtProperty[QVariant] myContactsModel:
    read = getMyContactsModel
    notify = myContactsModelChanged

  proc blockedContactsModelChanged(self: View) {.signal.}
  proc getBlockedContactsModel(self: View): QVariant {.slot.} =
    return self.blockedContactsModelVariant
  QtProperty[QVariant] blockedContactsModel:
    read = getBlockedContactsModel
    notify = blockedContactsModelChanged

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(publicKey)

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