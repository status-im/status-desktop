import Tables, json, sequtils, strformat, chronicles

import eventemitter

import service_interface, ./dto/contacts
import status/statusgo_backend_new/contacts as status_contacts
import status/statusgo_backend_new/accounts as status_accounts
import status/statusgo_backend_new/chat as status_chat
import status/statusgo_backend_new/utils as status_utils
import status/contacts as old_status_contacts

export service_interface

logScope:
  topics = "contacts-service"

type 
  Service* = ref object of ServiceInterface
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]
    events: EventEmitter

method delete*(self: Service) =
  discard

proc newService*(events: EventEmitter): Service =
  result = Service()
  result.events = events
  result.contacts = initTable[string, ContactsDto]()

method init*(self: Service) =
  discard

method getContacts*(self: Service): seq[ContactsDto] =
  let profiles = status_contacts.getContacts()
  for profile in profiles.result:
    result.add(profile.toContactsDto)

method getContact*(self: Service, id: string): ContactsDto =
  return status_contacts.getContactByID(id).result.toContactsDto()

method getOrCreateContact*(self: Service, id: string): ContactsDto =
  result = status_contacts.getContactByID(id).result.toContactsDto()
  if result == nil or  result.id == "":
    let alias = $status_accounts.generateAlias(id)
    result = ContactsDto(
      id: id,
      # username: alias,
      # localNickname: "",
      identicon: $status_accounts.generateIdenticon(id),
      alias: alias,
      # ensName: "",
      ensVerified: false,
      # appearance: 0,
      added: false,
      blocked: false,
      hasAddedUs: false
    )

proc saveContact(self: Service, contact: ContactsDto) = 
  var thumbnail = ""
  var largeImage = ""
  # if contact.identityImage != nil:
    # thumbnail = contact.identityImage.thumbnail
    # largeImage = contact.identityImage.large    

  # status_contacts.saveContact(contact.id, contact.ensVerified, contact.ensName, contact.alias, contact.identicon, thumbnail, largeImage, contact.added, contact.blocked, contact.hasAddedUs, contact.localNickname)
  status_contacts.saveContact(contact.id, contact.ensVerified, "", contact.alias, contact.identicon, thumbnail, largeImage, contact.added, contact.blocked, contact.hasAddedUs, "")

method addContact*(self: Service, publicKey: string) =
  var contact = self.getOrCreateContact(publicKey)
  let updating = contact.added

  if not updating:
    contact.added = true
    # discard status_chat.createProfileChat(contact.id)
  else:
    contact.blocked = false

  self.saveContact(contact)
  
  self.events.emit("contactAdded", Args())
  # sendContactUpdate(contact.id, accountKeyUID)
  if updating:
    let profile = ContactsDto(
      id: contact.id,
      # username: contact.alias,
      identicon: contact.identicon,
      alias: contact.alias,
      # ensName: contact.ensName,
      ensVerified: contact.ensVerified,
      # appearance: 0,
      added: contact.added,
      blocked: contact.blocked,
      hasAddedUs: contact.hasAddedUs,
      # localNickname: contact.localNickname
    )
    # TODO fix this to use ContactsDto
    # self.events.emit("contactUpdate", ContactUpdateArgs(contacts: @[profile]))

method rejectContactRequest*(self: Service, publicKey: string) =
  let contact = status_contacts.getContactByID(publicKey).result.toContactsDto()
  contact.hasAddedUs = false

  self.saveContact(contact)
  self.events.emit("contactRemoved", Args())
  # status_contacts.rejectContactRequest(publicKey)

method changeContactNickname*(self: Service, accountKeyUID: string, publicKey: string, nicknameToSet: string) =
  # status_contacts.setNickName(publicKey, nicknameToSet, accountKeyUID)
  var contact = self.getOrCreateContact(publicKey)
  # let nickname =
  #   if (nicknameToSet == ""):
  #     contact.localNickname
  #   elif (nicknameToSet == DELETE_CONTACT):
  #     ""
  #   else:
  #     nicknameToSet

  # contact.localNickname = nickname
  self.saveContact(contact)
  self.events.emit("contactAdded", Args())
  # sendContactUpdate(contact.id, accountKeyUID)

method unblockContact*(self: Service, publicKey: string) =
  # status_contacts.unblockContact(publicKey)
  var contact = status_contacts.getContactByID(publicKey).result.toContactsDto()
  contact.blocked = false
  self.saveContact(contact)
  self.events.emit("contactUnblocked", old_status_contacts.ContactIdArgs(id: publicKey))

method blockContact*(self: Service, publicKey: string) =
  var contact = status_contacts.getContactByID(publicKey).result.toContactsDto()
  contact.blocked = true
  self.saveContact(contact)
  self.events.emit("contactBlocked", old_status_contacts.ContactIdArgs(id: publicKey))

method removeContact*(self: Service, publicKey: string) =
  #   status_contacts.removeContact(publicKey)
  var contact = status_contacts.getContactByID(publicKey).result.toContactsDto()
  contact.added = false
  contact.hasAddedUs = false

  self.saveContact(contact)
  self.events.emit("contactRemoved", Args())
#   let channelId = status_utils.getTimelineChatId(publicKey)
#   if status_chat.hasChannel(channelId):
#     status_chat.leave(channelId)
