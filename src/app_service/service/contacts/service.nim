import NimQml, Tables, json, sequtils, strformat, chronicles, strutils

import eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ./dto/contacts as contacts_dto
import status/statusgo_backend_new/contacts as status_contacts
import status/statusgo_backend_new/accounts as status_accounts
import status/statusgo_backend_new/chat as status_chat
import status/statusgo_backend_new/utils as status_utils

export contacts_dto

include async_tasks

logScope:
  topics = "contacts-service"

type
  ContactArgs* = ref object of Args
    contactId*: string

  ContactNicknameUpdatedArgs* = ref object of ContactArgs
    nickname*: string

  ContactAddedArgs* = ref object of Args
    contact*: ContactsDto

# Signals which may be emitted by this service:
const SIGNAL_CONTACT_LOOKED_UP* = "SIGNAL_CONTACT_LOOKED_UP"
# Remove new when old code is removed
const SIGNAL_CONTACT_ADDED* = "new-contactAdded"
const SIGNAL_CONTACT_BLOCKED* = "new-contactBlocked" 
const SIGNAL_CONTACT_UNBLOCKED* = "new-contactUnblocked"
const SIGNAL_CONTACT_REMOVED* = "new-contactRemoved"
const SIGNAL_CONTACT_NICKNAME_CHANGED* = "new-contactNicknameChanged"

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

  proc generateAlias*(self: Service, publicKey: string): string =
    return status_accounts.generateAlias(publicKey).result.getStr

  proc generateIdenticon*(self: Service, publicKey: string): string =
    return status_accounts.generateIdenticon(publicKey).result.getStr

  proc getContactById*(self: Service, id: string): ContactsDto =
    ## Returns contact details based on passed id (public key)
    ## If we don't have stored contact localy or in the db then we create it based on public key.
    if(self.contacts.hasKey(id)):
      return self.contacts[id]

    result = self.fetchContact(id)
    if result.id.len == 0:
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
    # we must keep local contacts updated
    self.contacts[contact.id] = contact

  proc addContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    if not contact.added:
      contact.added = true
    else:
      contact.blocked = false

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_ADDED, ContactAddedArgs(contact: contact))

  proc rejectContactRequest*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.hasAddedUs = false

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_REMOVED, ContactArgs(contactId: contact.id))

  proc changeContactNickname*(self: Service, publicKey: string, nickname: string) =
    var contact = self.getContactById(publicKey)
    contact.localNickname = nickname
    
    self.saveContact(contact)
    let data = ContactNicknameUpdatedArgs(contactId: contact.id, nickname: nickname)
    self.events.emit(SIGNAL_CONTACT_NICKNAME_CHANGED, data)

  proc unblockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.blocked = false

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_UNBLOCKED, ContactArgs(contactId: contact.id))

  proc blockContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.blocked = true

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_BLOCKED, ContactArgs(contactId: contact.id))

  proc removeContact*(self: Service, publicKey: string) =
    var contact = self.getContactById(publicKey)
    contact.added = false
    contact.hasAddedUs = false

    self.saveContact(contact)
    self.events.emit(SIGNAL_CONTACT_REMOVED, ContactArgs(contactId: contact.id))

  proc ensResolved*(self: Service, id: string) {.slot.} =
    let data = ContactArgs(contactId: id)
    self.events.emit(SIGNAL_CONTACT_LOOKED_UP, data)

  proc lookupContact*(self: Service, value: string) =
    let arg = LookupContactTaskArg(
      tptr: cast[ByteAddress](lookupContactTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "ensResolved",
      value: value
    )
    self.threadpool.start(arg)
