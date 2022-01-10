import ./controller_interface
import io_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/contacts/service as contacts_service

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contacts_service.Service

proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  contactsService: contacts_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactAdded(args.contactId)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactBlocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_UNBLOCKED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUnblocked(args.contactId)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactRemoved(args.contactId)

  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactNicknameChanged(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

method getContacts*(self: Controller): seq[ContactsDto] =
  return self.contactsService.getContacts()

method getContact*(self: Controller, id: string): ContactsDto =
  return self.contactsService.getContactById(id)

method getContactNameAndImage*(self: Controller, contactId: string): 
  tuple[name: string, image: string, isIdenticon: bool] =
  return self.contactsService.getContactNameAndImage(contactId)

method addContact*(self: Controller, publicKey: string) =
  self.contactsService.addContact(publicKey)

method unblockContact*(self: Controller, publicKey: string) =
  self.contactsService.unblockContact(publicKey)

method blockContact*(self: Controller, publicKey: string) =
  self.contactsService.blockContact(publicKey)

method removeContact*(self: Controller, publicKey: string) =
  self.contactsService.removeContact(publicKey)

method changeContactNickname*(self: Controller, publicKey: string, nickname: string) =
  self.contactsService.changeContactNickname(publicKey, nickname)