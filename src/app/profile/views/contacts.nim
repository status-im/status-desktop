import NimQml, chronicles, sequtils, sugar, strutils, json
import ../../../status/status
import ../../../status/threads
import ../../../status/libstatus/core
import contact_list
import ../../../status/profile/profile
import ../../../status/ens as status_ens

logScope:
  topics = "contacts-view"

QtObject:
  type ContactsView* = ref object of QObject
    status: Status
    contactList*: ContactList
    addedContacts*: ContactList
    blockedContacts*: ContactList
    contactToAdd*: Profile

  proc setup(self: ContactsView) =
    self.QObject.setup

  proc delete*(self: ContactsView) =
    self.contactList.delete
    self.addedContacts.delete
    self.blockedContacts.delete
    self.QObject.delete

  proc newContactsView*(status: Status): ContactsView =
    new(result, delete)
    result.status = status
    result.contactList = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.contactToAdd = Profile(
      username: "",
      alias: "",
      ensName: ""
    )
    result.setup

  proc updateContactList*(self: ContactsView, contacts: seq[Profile]) =
    for contact in contacts:
      self.contactList.updateContact(contact)
      if contact.systemTags.contains(":contact/added"):
          self.addedContacts.updateContact(contact)
      if contact.systemTags.contains(":contact/blocked"):
          self.blockedContacts.updateContact(contact)

  proc contactListChanged*(self: ContactsView) {.signal.}

  proc getContactList(self: ContactsView): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: ContactsView, contactList: seq[Profile]) =
    self.contactList.setNewData(contactList)
    self.addedContacts.setNewData(contactList.filter(c => c.systemTags.contains(":contact/added")))
    self.blockedContacts.setNewData(contactList.filter(c => c.systemTags.contains(":contact/blocked")))
    self.contactListChanged()

  QtProperty[QVariant] list:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc getAddedContacts(self: ContactsView): QVariant {.slot.} =
    return newQVariant(self.addedContacts)

  QtProperty[QVariant] addedContacts:
    read = getAddedContacts
    notify = contactListChanged

  proc getBlockedContacts(self: ContactsView): QVariant {.slot.} =
    return newQVariant(self.blockedContacts)

  QtProperty[QVariant] blockedContacts:
    read = getBlockedContacts
    notify = contactListChanged

  proc isContactBlocked*(self: ContactsView, pubkey: string): bool {.slot.} =
    for contact in self.blockedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc contactToAddChanged*(self: ContactsView) {.signal.}

  proc getContactToAddUsername(self: ContactsView): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.ensName != "":
      username = self.contactToAdd.ensName

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: ContactsView): QVariant {.slot.} =
    return newQVariant(self.contactToAdd.address)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged

  proc isAdded*(self: ContactsView, id: string): bool {.slot.} =
    if id == "": return false
    self.status.contacts.isAdded(id)

  proc lookupContact*(self: ContactsView, value: string) {.slot.} =
    if value == "":
      return

    spawnAndSend(self, "ensResolved") do: # Call self.ensResolved(string) when ens is resolved
      var id = value
      if not id.startsWith("0x"):
        id = status_ens.pubkey(id)
      id

  proc ensResolved(self: ContactsView, id: string) {.slot.} =
    let contact = self.status.contacts.getContactByID(id)

    if contact != nil:
      self.contactToAdd = contact
    else:
      self.contactToAdd = Profile(
        username: "",
        alias: "",
        ensName: "",
        ensVerified: false
      )
    self.contactToAddChanged()

  proc contactChanged(self: ContactsView, publicKey: string, isAdded: bool) {.signal.}

  proc addContact*(self: ContactsView, publicKey: string): string {.slot.} =
    result = self.status.contacts.addContact(publicKey)
    let thejson = %* [   # TODO: We must ensure also that existing contacts have this chat type
    {
      "lastClockValue": 0,
      "color": "#000000",
      "name": publicKey,
      "lastMessage": nil,
      "active": true,
      "id": "@" & publicKey,
      "profile": publicKey,
      "unviewedMessagesCount": 0,
      "chatType":  4, # TODO: replace for constant chattype.Profile
      "timestamp": 1588940692659
    }
    ]
    discard callPrivateRPC("wakuext_saveChat", thejson)
    self.contactChanged(publicKey, true)

  proc changeContactNickname*(self: ContactsView, publicKey: string, nickname: string) {.slot.} =
    var nicknameToSet = nickname
    if (nicknameToSet == ""):
      nicknameToSet = DELETE_CONTACT
    discard self.status.contacts.addContact(publicKey, nicknameToSet)

  proc unblockContact*(self: ContactsView, publicKey: string) {.slot.} =
    self.contactListChanged()
    discard self.status.contacts.unblockContact(publicKey)

  proc blockContact*(self: ContactsView, publicKey: string): string {.slot.} =
    self.contactListChanged()
    return self.status.contacts.blockContact(publicKey)

  proc removeContact*(self: ContactsView, publicKey: string) {.slot.} =
    self.status.contacts.removeContact(publicKey)
    self.contactChanged(publicKey, false)
