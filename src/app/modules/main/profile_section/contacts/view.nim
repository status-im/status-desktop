import NimQml, sequtils, sugar, json, strutils

# import ./item
import ../../../../../app_service/service/contacts/dto/contacts
import ./model
import status/types/profile
import models/[contact_list]
import ./io_interface

# import status/types/[identity_image, profile]

import ../../../../core/[main]
import ../../../../core/tasks/[qt, threadpool]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      contactToAdd*: ContactsDto

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
    result.contactToAdd = ContactsDto()

  proc setContactList*(self: View, contacts: seq[ContactsDto]) =
    self.model.setContactList(contacts)

  proc updateContactList*(self: View, contacts: seq[ContactsDto]) =
    self.model.updateContactList(contacts)

  proc modelChanged*(self: View) {.signal.}

  proc getModel*(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc contactToAddChanged*(self: View) {.signal.}

  proc getContactToAddUsername(self: View): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.name != "":
      username = self.contactToAdd.name

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: View): QVariant {.slot.} =
    # TODO cofirm that id is the pubKey
    return newQVariant(self.contactToAdd.id)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged  

  proc ensWasResolved*(self: View, resolvedPubKey: string) {.signal.}

  proc contactLookedUp*(self: View, id: string) {.slot.} =
    self.ensWasResolved(id)

    if id == "":
      self.contactToAddChanged()
      return

    let contact = self.delegate.getContact(id)

    if contact.id != "":
      self.contactToAdd = contact
    else:
      self.contactToAdd = ContactsDto(
        id: id,
        alias: self.delegate.generateAlias(id),
        ensVerified: false
      )

    self.contactToAddChanged()

  proc lookupContact*(self: View, value: string) {.slot.} =
    if value == "":
      return

    self.delegate.lookupContact(value)

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.addContact(publicKey)

  proc contactAdded*(self: View, contact: ContactsDto) =
    self.model.contactAdded(contact)

  proc contactBlocked*(self: View, contact: ContactsDto) =
    self.model.contactBlocked(contact)

  proc contactUnblocked*(self: View, contact: ContactsDto) =
    self.model.contactUnblocked(contact)

  proc contactRemoved*(self: View, contact: ContactsDto) =
    self.model.contactRemoved(contact)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.rejectContactRequest(pubkey.getStr)

  proc acceptContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.addContact(pubkey.getStr)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    self.delegate.changeContactNickname(publicKey, nickname)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.unblockContact(publicKey)

  proc contactBlocked*(self: View, publicKey: string) {.signal.}

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.contactBlocked(publicKey)
    self.delegate.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.removeContact(publicKey)
