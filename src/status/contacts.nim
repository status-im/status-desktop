import json, sequtils, sugar
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
  contact.systemTags.add(":contact/blocked")
  discard status_contacts.blockContact(contact)
  self.events.emit("contactBlocked", Args())

proc unblockContact*(self: ContactModel, id: string): string =
  var contact = self.getContactByID(id)
  contact.systemTags.delete(contact.systemTags.find(":contact/blocked"))
  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, contact.identityImage.thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactUnblocked", Args())

proc getAllContacts*(): seq[Profile] =
  result = map(status_contacts.getContacts().getElems(), proc(x: JsonNode): Profile = x.toProfileModel())

proc getAddedContacts*(): seq[Profile] =
  result = getAllContacts().filter(c => c.systemTags.contains(":contact/added"))

proc getContacts*(self: ContactModel): seq[Profile] =
  result = getAllContacts()
  self.events.emit("contactUpdate", ContactUpdateArgs(contacts: result))

proc addContact*(self: ContactModel, id: string, localNickname: string): string =
  var contact = self.getContactByID(id)
  if contact == nil:
    let alias = status_accounts.generateAlias(id)
    contact = Profile(
      id: id,
      username: alias,
      identicon: status_accounts.generateIdenticon(id),
      alias: alias,
      ensName: "",
      ensVerified: false,
      appearance: 0,
      systemTags: @[]
    )

  let updating = contact.systemTags.contains(":contact/added")
  if not updating:
    contact.systemTags.add(":contact/added")
    status_chat.saveChat(getTimelineChatId(contact.id), ChatType.Profile, ensName=contact.ensName, profile=contact.id)
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
      localNickname: nickname
    )
    self.events.emit("contactUpdate", ContactUpdateArgs(contacts: @[profile]))

proc addContact*(self: ContactModel, id: string): string =
  result = self.addContact(id, "")

proc removeContact*(self: ContactModel, id: string) =
  let contact = self.getContactByID(id)
  contact.systemTags.delete(contact.systemTags.find(":contact/added"))

  var thumbnail = ""
  if contact.identityImage != nil:
    thumbnail = contact.identityImage.thumbnail

  discard status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, contact.systemTags, contact.localNickname)
  self.events.emit("contactRemoved", Args())

proc isAdded*(self: ContactModel, id: string): bool =
  var contact = self.getContactByID(id)
  if contact.isNil: return false
  contact.systemTags.contains(":contact/added")
