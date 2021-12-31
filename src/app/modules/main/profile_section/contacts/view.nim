import NimQml

import ./model
import ./io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      myContactsModel: Model
      myContactsModelVariant: QVariant
      blockedContactsModel: Model
      blockedContactsModelVariant: QVariant
      contactsWhoAddedMeModel: Model
      contactsWhoAddedMeModelVariant: QVariant

  proc delete*(self: View) =
    self.myContactsModel.delete
    self.myContactsModelVariant.delete
    self.blockedContactsModel.delete
    self.blockedContactsModelVariant.delete
    self.contactsWhoAddedMeModel.delete
    self.contactsWhoAddedMeModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.myContactsModel = newModel()
    result.myContactsModelVariant = newQVariant(result.myContactsModel)
    result.blockedContactsModel = newModel()
    result.blockedContactsModelVariant = newQVariant(result.blockedContactsModel)
    result.contactsWhoAddedMeModel = newModel()
    result.contactsWhoAddedMeModelVariant = newQVariant(result.contactsWhoAddedMeModel)

  proc load*(self: View) =
    self.delegate.viewDidLoad()
    
  proc myContactsModel*(self: View): Model =
    return self.myContactsModel

  proc blockedContactsModel*(self: View): Model =
    return self.blockedContactsModel

  proc contactsWhoAddedMeModel*(self: View): Model =
    return self.contactsWhoAddedMeModel

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

  proc contactsWhoAddedMeModelChanged(self: View) {.signal.}
  proc getContactsWhoAddedMeModel(self: View): QVariant {.slot.} =
    return self.contactsWhoAddedMeModelVariant
  QtProperty[QVariant] contactsWhoAddedMeModel:
    read = getContactsWhoAddedMeModel
    notify = contactsWhoAddedMeModelChanged
  
  proc ensWasResolved*(self: View, resolvedPubKey: string) {.signal.}
  proc emitEnsWasResolvedSignal*(self: View, resolvedPubKey: string) =
    self.ensWasResolved(resolvedPubKey)

  proc resolvedENSWithUUID*(self: View, resolvedAddress: string, uuid: string) {.signal.}
  proc emitrEsolvedENSWithUUIDSignal*(self: View, resolvedAddress: string, uuid: string) =
    self.resolvedENSWithUUID(resolvedAddress, uuid)

  proc lookupContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.lookupContact(publicKey)

  proc resolveENSWithUUID*(self: View, ensName: string, uuid: string) {.slot.} =
    self.delegate.resolveENSWithUUID(ensName, uuid)

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(publicKey)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKeysJSON)

  proc acceptContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    self.delegate.addContact(publicKeysJSON)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    self.delegate.changeContactNickname(publicKey, nickname)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)

  proc isContactAdded*(self: View, publicKey: string): bool {.slot.} =
    return self.delegate.isContactAdded(publicKey)

  proc isContactBlocked*(self: View, publicKey: string): bool {.slot.} =
    return self.delegate.isContactBlocked(publicKey)

  proc isEnsVerified*(self: View, publicKey: string): bool {.slot.} =
    return self.delegate.isEnsVerified(publicKey)

  proc alias*(self: View, publicKey: string): string {.slot.} =
    return self.delegate.alias(publicKey)