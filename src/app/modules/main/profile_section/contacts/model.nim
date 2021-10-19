import NimQml, chronicles, sequtils, sugar, strutils, json

import status/utils as status_utils
import status/chat/chat
import status/types/profile
import status/ens as status_ens

import ./models/contact_list

# import ../../../app_service/[main]
# import ../../../app_service/tasks/[qt, threadpool]

# type
#   LookupContactTaskArg = ref object of QObjectTaskArg
#     value: string

# const lookupContactTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
#   let arg = decode[LookupContactTaskArg](argEncoded)
#   var id = arg.value
#   if not id.startsWith("0x"):
#     id = status_ens.pubkey(id)
#   arg.finish(id)

# proc lookupContact[T](self: T, slot: string, value: string) =
#   let arg = LookupContactTaskArg(
#     tptr: cast[ByteAddress](lookupContactTask),
#     vptr: cast[ByteAddress](self.vptr),
#     slot: slot,
#     value: value
#   )
#   self.appService.threadpool.start(arg)

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

  proc updateContactList*(self: Model, contacts: seq[Profile]) =
    for contact in contacts:
      var requestAlreadyAdded = false
      for existingContact in self.contactList.contacts:
        if existingContact.address == contact.address and existingContact.requestReceived():
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
        self.contactRequestAdded(contact.username, contact.address)
        # self.contactRequestAdded(status_ens.userNameOrAlias(contact), contact.address)

    self.contactListChanged()

  proc getContactList(self: Model): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: Model, contactList: seq[Profile]) =
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


