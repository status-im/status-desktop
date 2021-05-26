import json, sequtils, sugar, chronicles
import libstatus/contacts as status_contacts
import libstatus/accounts as status_accounts
import libstatus/chat as status_chat
import libstatus/utils as status_utils
import chat/chat
#import chat/utils
import profile/profile
import ../eventemitter

const DELETE_CONTACT* = "__deleteThisContact__"

type
  ContactModel* = ref object
    events*: EventEmitter

type 
  ContactUpdateArgs* = ref object of Args
    contacts*: seq[Profile]

proc newContactModel*(events: EventEmitter): ContactModel =
    result = ContactModel()
    result.events = events

proc getContactByID*(self: ContactModel, id: string): Profile =
  let response = status_contacts.getContactByID(id)
  # TODO: change to options
  let responseResult = parseJSON($response)["result"]
  if responseResult == nil or responseResult.kind == JNull:
    result = nil
  else:
    result = toProfileModel(parseJSON($response)["result"])

proc blockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  contact.systemTags.add(contactBlocked)
  let index = contact.systemTags.find(contactAdded)
  if (index > -1):
    contact.systemTags.delete(index)
  discard status_contacts.blockContact(contact)
  self.events.emit("contactBlocked", Args())
  

proc unblockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  contact.systemTags.delete(contact.systemTags.find(contactBlocked))
  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, contact.identityImage.thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactUnblocked", Args())

proc getAllContacts*(): seq[Profile] =
  result = map(status_contacts.getContacts().getElems(), proc(x: JsonNode): Profile = x.toProfileModel())

proc getAddedContacts*(): seq[Profile] =
  result = getAllContacts().filter(c => c.systemTags.contains(contactAdded))

proc getContacts*(self: ContactModel): seq[Profile] =
  result = getAllContacts()
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

  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactRemoved", Args())
