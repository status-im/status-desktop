import NimQml, chronicles, sequtils, sugar, strutils, json

import ../../../../../app_service/service/contacts/dto/contacts
import status/utils as status_utils
import status/chat/chat
import status/types/profile
import status/ens as status_ens

import ./models/contact_list

QtObject:
  type Model* = ref object of QObject
    contactList*: ContactList
    contactRequests*: ContactList
    addedContacts*: ContactList
    blockedContacts*: ContactList

  proc setup(self: Model) =
    self.QObject.setup

  proc delete*(self: Model) =
    self.contactList.delete
    self.addedContacts.delete
    self.contactRequests.delete
    self.blockedContacts.delete
    self.QObject.delete

  proc newModel*(): Model =
    new(result, delete)
    result.contactList = newContactList()
    result.contactRequests = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.setup

  proc contactListChanged*(self: Model) {.signal.}
  proc contactRequestAdded*(self: Model, name: string, address: string) {.signal.}

  proc contactAdded*(self: Model, contact: ContactsDto) =
    self.contactList.updateContact(contact)
    self.addedContacts.addContactToList(contact)
    self.blockedContacts.removeContactFromList(contact.id)
    self.contactRequests.removeContactFromList(contact.id)

  proc contactBlocked*(self: Model, contact: ContactsDto) =
    self.contactList.updateContact(contact)
    self.addedContacts.removeContactFromList(contact.id)
    self.blockedContacts.addContactToList(contact)
    self.contactRequests.removeContactFromList(contact.id)

  proc contactUnblocked*(self: Model, contact: ContactsDto) =
    self.contactList.updateContact(contact)
    self.blockedContacts.removeContactFromList(contact.id)

  proc contactRemoved*(self: Model, contact: ContactsDto) =
    self.contactList.updateContact(contact)
    self.addedContacts.removeContactFromList(contact.id)
    self.contactRequests.removeContactFromList(contact.id)

  proc changeNicknameForContactWithId*(self: Model, id: string, nickname: string) =
    self.contactList.changeNicknameForContactWithId(id, nickname)
    self.addedContacts.changeNicknameForContactWithId(id, nickname)
    self.blockedContacts.changeNicknameForContactWithId(id, nickname)
    self.contactRequests.changeNicknameForContactWithId(id, nickname)

  proc updateContactList*(self: Model, contacts: seq[ContactsDto]) =
    for contact in contacts:
      var requestAlreadyAdded = false
      for existingContact in self.contactList.contacts:
        if existingContact.id == contact.id and existingContact.requestReceived():
          requestAlreadyAdded = true
          break

      self.contactList.updateContact(contact)
      if contact.added:
        self.addedContacts.updateContact(contact)

      if contact.isBlocked():
        self.blockedContacts.updateContact(contact)

      if contact.requestReceived() and not contact.added and not contact.blocked:
        self.contactRequests.updateContact(contact)

      if not requestAlreadyAdded and contact.requestReceived():
        # TODO add back userNameOrAlias call
        self.contactRequestAdded(contact.name, contact.id)
        # self.contactRequestAdded(status_ens.userNameOrAlias(contact), contact.address)

    self.contactListChanged()

  proc getContactList(self: Model): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: Model, contactList: seq[ContactsDto]) =
    self.contactList.setNewData(contactList)
    self.addedContacts.setNewData(contactList.filter(c => c.added))
    self.blockedContacts.setNewData(contactList.filter(c => c.blocked))
    self.contactRequests.setNewData(contactList.filter(c => c.hasAddedUs and not c.added and not c.blocked))

    self.contactListChanged()

  QtProperty[QVariant] list:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc getAddedContacts(self: Model): QVariant {.slot.} =
    return newQVariant(self.addedContacts)

  QtProperty[QVariant] addedContacts:
    read = getAddedContacts
    notify = contactListChanged

  proc getBlockedContacts(self: Model): QVariant {.slot.} =
    return newQVariant(self.blockedContacts)

  QtProperty[QVariant] blockedContacts:
    read = getBlockedContacts
    notify = contactListChanged

  proc isContactBlocked*(self: Model, pubkey: string): bool {.slot.} =
    for contact in self.blockedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc getContactRequests(self: Model): QVariant {.slot.} =
    return newQVariant(self.contactRequests)

  QtProperty[QVariant] contactRequests:
    read = getContactRequests
    notify = contactListChanged

  proc isAdded*(self: Model, pubkey: string): bool {.slot.} =
    for contact in self.addedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

proc contactRequestReceived*(self: Model, pubkey: string): bool {.slot.} =
    for contact in self.contactRequests.contacts:
      if contact.id == pubkey:
        return true
    return false
