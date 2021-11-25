import ./controller_interface
import io_interface
import ../../../../core/signals/types
import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto/contacts
import ../../../../../app_service/service/accounts/service as accounts_service

# import ./item as item
import eventemitter

export controller_interface

type 
  Controller* = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contacts_service.Service
    accountsService: accounts_service.ServiceInterface

proc newController*(delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  contactsService: contacts_service.Service,
  accountsService: accounts_service.ServiceInterface): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService
  result.accountsService = accountsService

method delete*(self: Controller) =
  discard

method init*(self: Controller) =
  self.events.on(SIGNAL_CONTACT_LOOKED_UP) do(e: Args):
    var args = ContactArgs(e)
    self.delegate.contactLookedUp(args.contactId)

  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var args = ContactAddedArgs(e)
    self.delegate.contactAdded(args.contact)

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
    var args = ContactNicknameUpdatedArgs(e)
    self.delegate.contactNicknameChanged(args.contactId, args.nickname)

method getContacts*(self: Controller): seq[ContactsDto] =
  return self.contactsService.getContacts()

method getContact*(self: Controller, id: string): ContactsDto =
  return self.contactsService.getContactById(id)

method generateAlias*(self: Controller, publicKey: string): string =
  return self.accountsService.generateAlias(publicKey)

method addContact*(self: Controller, publicKey: string) =
  self.contactsService.addContact(publicKey)

method rejectContactRequest*(self: Controller, publicKey: string) =
  self.contactsService.rejectContactRequest(publicKey)

method unblockContact*(self: Controller, publicKey: string) =
  self.contactsService.unblockContact(publicKey)

method blockContact*(self: Controller, publicKey: string) =
  self.contactsService.blockContact(publicKey)

method removeContact*(self: Controller, publicKey: string) =
  self.contactsService.removeContact(publicKey)

method changeContactNickname*(self: Controller, publicKey: string, nickname: string) =
  self.contactsService.changeContactNickname(publicKey, nickname)

method lookupContact*(self: Controller, value: string) =
  self.contactsService.lookupContact(value)