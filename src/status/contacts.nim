import json, sequtils, sugar, chronicles, tables
import libstatus/contacts as status_contacts
import libstatus/accounts as status_accounts
import libstatus/chat as status_chat
import profile/profile
import ../eventemitter

const DELETE_CONTACT* = "__deleteThisContact__"

type
  ContactModel* = ref object
    # contact.ID => Profile
    contactsMap: Table[string, Profile]
    events*: EventEmitter

type 
  ContactUpdateArgs* = ref object of Args
    contacts*: seq[Profile]

proc newContactModel*(events: EventEmitter): ContactModel =
    result = ContactModel()
    result.contactsMap = initTable[string, Profile]()
    result.events = events

proc getContactByID*(self: ContactModel, id: string): Profile =
  if self.contactsMap.hasKey(id):
    return self.contactsMap[id]

  let response = status_contacts.getContactByID(id)
  # TODO: change to options
  let responseResult = parseJSON($response)["result"]
  if responseResult == nil or responseResult.kind == JNull:
    result = nil
  else:
    result = toProfileModel(parseJSON($response)["result"])
    self.contactsMap[id] = result

proc blockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  contact.systemTags.add(contactBlocked)
  let index = contact.systemTags.find(contactAdded)
  if (index > -1):
    contact.systemTags.delete(index)
  self.contactsMap[id] = contact
  discard status_contacts.blockContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, contact.systemTags, contact.localNickname)
  self.events.emit("contactBlocked", Args())

proc unblockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  let index = contact.systemTags.find(contactBlocked)
  if (index > -1):
    contact.systemTags.delete(index)
    self.contactsMap[id] = contact
    discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, contact.identityImage.thumbnail, contact.systemTags, contact.localNickname)
    self.events.emit("contactUnblocked", Args())

proc getAllContacts*(self: ContactModel): seq[Profile] =
  if self.contactsMap.len == 0:
    result = map(status_contacts.getContacts().getElems(), proc(x: JsonNode): Profile = x.toProfileModel())
    for profile in result:
      self.contactsMap[profile.id] = profile
  else:
    result = toSeq(self.contactsMap.values)

proc getAddedContacts*(self: ContactModel): seq[Profile] =
  result = self.getAllContacts().filter(c => c.systemTags.contains(contactAdded))

proc getContacts*(self: ContactModel): seq[Profile] =
  result = self.getAllContacts()
  self.events.emit("contactUpdate", ContactUpdateArgs(contacts: result))

proc getOrCreateContact*(self: ContactModel, id: string): Profile =
  result = self.getContactByID(id)
  if result == nil:
    let alias = status_accounts.generateAlias(id)
    result = Profile(
      id: id,
      username: alias,
      localNickname: "",
      identicon: status_accounts.generateIdenticon(id),
      alias: alias,
      ensName: "",
      ensVerified: false,
      appearance: 0,
      systemTags: @[]
    )

proc setNickName*(self: ContactModel, id: string, localNickname: string): string =
  var contact = self.getOrCreateContact(id)
  let nickname =
    if (localNickname == ""):
      contact.localNickname
    elif (localNickname == DELETE_CONTACT):
      ""
    else:
      localNickname

  var thumbnail = ""
  if contact.identityImage != nil:
    thumbnail = contact.identityImage.thumbnail

  self.contactsMap[id].localNickname = nickname
  result = status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, nickname)
  self.events.emit("contactAdded", Args())
  discard requestContactUpdate(contact.id)

proc addContact*(self: ContactModel, id: string): string =
  var contact = self.getOrCreateContact(id)
  
  let updating = contact.systemTags.contains(contactAdded)
  if not updating:
    contact.systemTags.add(contactAdded)
    discard status_chat.createProfileChat(contact.id)
  else:
    let index = contact.systemTags.find(contactBlocked)
    if (index > -1):
      contact.systemTags.delete(index)

  var thumbnail = ""
  if contact.identityImage != nil:
    thumbnail = contact.identityImage.thumbnail

  self.contactsMap[id] = contact
  result = status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactAdded", Args())
  discard requestContactUpdate(contact.id)

  if updating:
    let profile = Profile(
      id: contact.id,
      username: contact.alias,
      identicon: contact.identicon,
      alias: contact.alias,
      ensName: contact.ensName,
      ensVerified: contact.ensVerified,
      appearance: 0,
      systemTags: contact.systemTags,
      localNickname: contact.localNickname
    )
    self.events.emit("contactUpdate", ContactUpdateArgs(contacts: @[profile]))

proc removeContact*(self: ContactModel, id: string) =
  let contact = self.getContactByID(id)
  contact.systemTags.delete(contact.systemTags.find(contactAdded))

  var thumbnail = ""
  if contact.identityImage != nil:
    thumbnail = contact.identityImage.thumbnail

  self.contactsMap[id] = contact
  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactRemoved", Args())

proc isAdded*(self: ContactModel, id: string): bool =
  var contact = self.getContactByID(id)
  if contact.isNil: return false
  contact.systemTags.contains(contactAdded)

proc contactRequestReceived*(self: ContactModel, id: string): bool =
  var contact = self.getContactByID(id)
  if contact.isNil: return false
  contact.systemTags.contains(contactRequest)

proc rejectContactRequest*(self: ContactModel, id: string) =
  let contact = self.getContactByID(id)
  contact.systemTags.delete(contact.systemTags.find(contactRequest))

  var thumbnail = ""
  if contact.identityImage != nil:
    thumbnail = contact.identityImage.thumbnail

  self.contactsMap[id] = contact
  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactRemoved", Args())
