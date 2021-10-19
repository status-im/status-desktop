import NimQml, chronicles, sequtils, sugar, strutils, json

import status/utils as status_utils
import status/status
import status/chat/chat
import status/types/profile
import status/ens as status_ens

import contact_list

# import ../../../app_service/[main]
# import ../../../app_service/tasks/[qt, threadpool]

logScope:
  topics = "contacts-view"

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
    # status: Status
    # appService: AppService
    # contactList*: ContactList
    contactRequests*: ContactList
    addedContacts*: ContactList
    blockedContacts*: ContactList
    contactToAdd*: Profile
    accountKeyUID*: string

  proc setup(self: Model) =
    self.QObject.setup

  proc delete*(self: Model) =
    # self.contactList.delete
    self.addedContacts.delete
    self.contactRequests.delete
    self.blockedContacts.delete
    self.QObject.delete

  proc newModel*(): Model =
    new(result, delete)
    # result.status = status
    # result.appService = appService
    # result.contactList = newContactList()
    result.contactRequests = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.contactToAdd = Profile(
      username: "",
      alias: "",
      ensName: ""
    )
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
        self.contactRequestAdded(status_ens.userNameOrAlias(contact), contact.address)

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

  proc contactToAddChanged*(self: Model) {.signal.}

  proc getContactToAddUsername(self: Model): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.ensName != "":
      username = self.contactToAdd.ensName

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: Model): QVariant {.slot.} =
    return newQVariant(self.contactToAdd.address)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged

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

  proc lookupContact*(self: Model, value: string) {.slot.} =
    if value == "":
      return

    # self.lookupContact("ensResolved", value)

  proc ensWasResolved*(self: Model, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: Model, id: string) {.slot.} =
    self.ensWasResolved(id)
    if id == "":
      self.contactToAddChanged()
      return

    let contact = self.status.contacts.getContactByID(id)

    if contact != nil:
      self.contactToAdd = contact
    else:
      self.contactToAdd = Profile(
        address: id,
        username: "",
        alias: generateAlias(id),
        ensName: "",
        ensVerified: false
      )
    self.contactToAddChanged()

  proc addContact*(self: Model, publicKey: string) {.slot.} =
    self.status.contacts.addContact(publicKey, self.accountKeyUID)
    self.status.chat.join(status_utils.getTimelineChatId(publicKey), ChatType.Profile, "", publicKey)

  proc rejectContactRequest*(self: Model, publicKey: string) {.slot.} =
    self.status.contacts.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: Model, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.rejectContactRequest(pubkey.getStr)

  proc acceptContactRequests*(self: Model, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.addContact(pubkey.getStr)

  proc changeContactNickname*(self: Model, publicKey: string, nickname: string) {.slot.} =
    var nicknameToSet = nickname
    if (nicknameToSet == ""):
      nicknameToSet = DELETE_CONTACT
    self.status.contacts.setNickName(publicKey, nicknameToSet, self.accountKeyUID)

  proc unblockContact*(self: Model, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.status.contacts.unblockContact(publicKey)

  proc contactBlocked*(self: Model, publicKey: string) {.signal.}

  proc blockContact*(self: Model, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.contactBlocked(publicKey)
    self.status.contacts.blockContact(publicKey)

  proc removeContact*(self: Model, publicKey: string) {.slot.} =
    self.status.contacts.removeContact(publicKey)
    let channelId = status_utils.getTimelineChatId(publicKey)
    if self.status.chat.hasChannel(channelId):
      self.status.chat.leave(channelId)
