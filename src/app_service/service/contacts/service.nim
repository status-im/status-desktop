import NimQml, Tables, json, sequtils, strformat, chronicles, strutils

import eventemitter
import ../../tasks/[qt, threadpool]

import ./dto/contacts as contacts_dto
import status/statusgo_backend_new/contacts as status_contacts
import status/statusgo_backend_new/accounts as status_accounts
import status/statusgo_backend_new/chat as status_chat
import status/statusgo_backend_new/utils as status_utils
import status/contacts as old_status_contacts

export contacts_dto

include async_tasks

logScope:
  topics = "contacts-service"

type
  LookupResolvedArgs* = ref object of Args
    id*: string

  ContactUpdatedArgs* = ref object of Args
    id*: string

# Signals which may be emitted by this service:
const SIGNAL_CONTACT_LOOKED_UP* = "SIGNAL_CONTACT_LOOKED_UP" 
const SIGNAL_CONTACT_UPDATED* = "new-contactUpdated" #Once we are done with refactoring we should remove "new-" from all signals

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    contacts: Table[string, ContactsDto] # [contact_id, ContactsDto]
    events: EventEmitter

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.contacts = initTable[string, ContactsDto]()

  proc fetchContacts(self: Service) =
    try:
      let response = status_contacts.getContacts()

      let contacts = map(response.result.getElems(), proc(x: JsonNode): ContactsDto = x.toContactsDto())

      for contact in contacts:
        self.contacts[contact.id] = contact

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc init*(self: Service) =
    self.fetchContacts()

  proc getContacts*(self: Service): seq[ContactsDto] =
    return toSeq(self.contacts.values)

  proc fetchContact(self: Service, id: string): ContactsDto =
    try:
      let response = status_contacts.getContactByID(id)

      result = response.result.toContactsDto()
      self.contacts[result.id] = result

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getContactById*(self: Service, id: string): ContactsDto =
    if(not self.contacts.hasKey(id)):
      return self.fetchContact(id)

    return self.contacts[id]

  proc generateAlias*(self: Service, publicKey: string): string =
    return status_accounts.generateAlias(publicKey).result.getStr

  method generateIdenticon*(self: Service, publicKey: string): string =
    return status_accounts.generateIdenticon(publicKey).result.getStr

  proc getOrCreateContact*(self: Service, id: string): ContactsDto =
    result = self.getContactById(id)
    if result.id == "":
      let alias = self.generateAlias(id)
      let identicon = self.generateIdenticon(id)
      result = ContactsDto(
        id: id,
        identicon: identicon,
        alias: alias,
        ensVerified: false,
        added: false,
        blocked: false,
        hasAddedUs: false
      )

  proc saveContact(self: Service, contact: ContactsDto) = 
    status_contacts.saveContact(contact.id, contact.ensVerified, contact.name, contact.alias, contact.identicon, 
    contact.image.thumbnail, contact.image.large, contact.added, contact.blocked, contact.hasAddedUs, contact.localNickname)

  proc addContact*(self: Service, publicKey: string) =
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

  proc rejectContactRequest*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.hasAddedUs = false

    self.saveContact(contact)
    self.events.emit("contactRemoved", Args())
    # status_contacts.rejectContactRequest(publicKey)

  proc changeContactNickname*(self: Service, publicKey: string, nickname: string) =
    var contact = self.getOrCreateContact(publicKey)
    contact.localNickname = nickname
    self.saveContact(contact)
    let data = ContactUpdatedArgs(id: contact.id)
    self.events.emit(SIGNAL_CONTACT_UPDATED, data)

  proc unblockContact*(self: Service, publicKey: string) =
    # status_contacts.unblockContact(publicKey)
    var contact = self.getContactById(publicKey)
    contact.blocked = false
    self.saveContact(contact)
    self.events.emit("contactUnblocked", old_status_contacts.ContactIdArgs(id: publicKey))

  proc blockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.blocked = true
    self.saveContact(contact)
    self.events.emit("contactBlocked", old_status_contacts.ContactIdArgs(id: publicKey))

  proc removeContact*(self: Service, publicKey: string) =
    #   status_contacts.removeContact(publicKey)
    var contact = self.getContactById(publicKey)
    contact.added = false
    contact.hasAddedUs = false

    self.saveContact(contact)
    self.events.emit("contactRemoved", Args())
  #   let channelId = status_utils.getTimelineChatId(publicKey)
  #   if status_chat.hasChannel(channelId):
  #     status_chat.leave(channelId)

  proc ensResolved*(self: Service, id: string) {.slot.} =
    # var contact = self.getContact(id)

    # if contact == nil or contact.id == "":
    #   contact = ContactsDto(
    #     id: id,
    #     alias: $status_accounts.generateAlias(id),
    #     ensVerified: false
    #   )

    let data = LookupResolvedArgs(id: id)

    self.events.emit(SIGNAL_CONTACT_LOOKED_UP, data)

  proc lookupContact*(self: Service, value: string) =
    let arg = LookupContactTaskArg(
      tptr: cast[ByteAddress](lookupContactTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "ensResolved",
      value: value
    )
    self.threadpool.start(arg)
