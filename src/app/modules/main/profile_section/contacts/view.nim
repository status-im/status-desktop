import NimQml

# import ./item
# import ./model
import models/[contact_list]
import ./io_interface

# import status/types/[identity_image, profile]

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
    #   model: Model
    #   modelVariant: QVariant
      contactList*: ContactList
      contactRequests*: ContactList
      addedContacts*: ContactList
      blockedContacts*: ContactList
      contactToAdd*: Profile
      accountKeyUID*: string

  proc delete*(self: View) =
    self.model.delete
    self.contactList.delete
    self.addedContacts.delete
    self.contactRequests.delete
    self.blockedContacts.delete
    # self.modelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    # result.model = newModel()
    # result.modelVariant = newQVariant(result.model)
    result.contactList = newContactList()
    result.contactRequests = newContactList()
    result.addedContacts = newContactList()
    result.blockedContacts = newContactList()
    result.contactToAdd = Profile(
      username: "",
      alias: "",
      ensName: ""
    )

#   proc modelChanged*(self: View) {.signal.}

#   proc getModel*(self: View): QVariant {.slot.} =
#     return self.modelVariant

#   QtProperty[QVariant] model:
#     read = getModel
#     notify = modelChanged

  proc contactListChanged*(self: View) {.signal.}
  proc contactRequestAdded*(self: View, name: string, address: string) {.signal.}

  proc updateContactList*(self: View, contacts: seq[Profile]) =
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

  proc getContactList(self: View): QVariant {.slot.} =
    return newQVariant(self.contactList)

  proc setContactList*(self: View, contactList: seq[Profile]) =
    self.contactList.setNewData(contactList)
    self.addedContacts.setNewData(contactList.filter(c => c.added))
    self.blockedContacts.setNewData(contactList.filter(c => c.blocked))
    self.contactRequests.setNewData(contactList.filter(c => c.hasAddedUs and not c.added and not c.blocked))

    self.contactListChanged()

  QtProperty[QVariant] list:
    read = getContactList
    write = setContactList
    notify = contactListChanged

  proc getAddedContacts(self: View): QVariant {.slot.} =
    return newQVariant(self.addedContacts)

  QtProperty[QVariant] addedContacts:
    read = getAddedContacts
    notify = contactListChanged

  proc getBlockedContacts(self: View): QVariant {.slot.} =
    return newQVariant(self.blockedContacts)

  QtProperty[QVariant] blockedContacts:
    read = getBlockedContacts
    notify = contactListChanged

  proc isContactBlocked*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.blockedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc getContactRequests(self: View): QVariant {.slot.} =
    return newQVariant(self.contactRequests)

  QtProperty[QVariant] contactRequests:
    read = getContactRequests
    notify = contactListChanged

  proc contactToAddChanged*(self: View) {.signal.}

  proc getContactToAddUsername(self: View): QVariant {.slot.} =
    var username = self.contactToAdd.alias;

    if self.contactToAdd.ensVerified and self.contactToAdd.ensName != "":
      username = self.contactToAdd.ensName

    return newQVariant(username)

  QtProperty[QVariant] contactToAddUsername:
    read = getContactToAddUsername
    notify = contactToAddChanged

  proc getContactToAddPubKey(self: View): QVariant {.slot.} =
    return newQVariant(self.contactToAdd.address)

  QtProperty[QVariant] contactToAddPubKey:
    read = getContactToAddPubKey
    notify = contactToAddChanged

  proc isAdded*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.addedContacts.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc contactRequestReceived*(self: View, pubkey: string): bool {.slot.} =
    for contact in self.contactRequests.contacts:
      if contact.id == pubkey:
        return true
    return false

  proc lookupContact*(self: View, value: string) {.slot.} =
    if value == "":
      return

    # self.lookupContact("ensResolved", value)

  proc ensWasResolved*(self: View, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: View, id: string) {.slot.} =
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

  proc addContact*(self: View, publicKey: string) {.slot.} =
    self.status.contacts.addContact(publicKey, self.accountKeyUID)
    self.status.chat.join(status_utils.getTimelineChatId(publicKey), ChatType.Profile, "", publicKey)

  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.status.contacts.rejectContactRequest(publicKey)

  proc rejectContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.rejectContactRequest(pubkey.getStr)

  proc acceptContactRequests*(self: View, publicKeysJSON: string) {.slot.} =
    let publicKeys = publicKeysJSON.parseJson
    for pubkey in publicKeys:
      self.addContact(pubkey.getStr)

  proc changeContactNickname*(self: View, publicKey: string, nickname: string) {.slot.} =
    var nicknameToSet = nickname
    if (nicknameToSet == ""):
      nicknameToSet = DELETE_CONTACT
    self.status.contacts.setNickName(publicKey, nicknameToSet, self.accountKeyUID)

  proc unblockContact*(self: View, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.status.contacts.unblockContact(publicKey)

  proc contactBlocked*(self: View, publicKey: string) {.signal.}

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.contactListChanged()
    self.contactBlocked(publicKey)
    self.status.contacts.blockContact(publicKey)

  proc removeContact*(self: View, publicKey: string) {.slot.} =
    self.status.contacts.removeContact(publicKey)
    let channelId = status_utils.getTimelineChatId(publicKey)
    if self.status.chat.hasChannel(channelId):
      self.status.chat.leave(channelId)
