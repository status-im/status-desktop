import ./controller_interface
import io_interface
import status/[signals]
import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto/contacts
import ../../../../../app_service/service/accounts/service as accounts_service

# import ./item as item
import eventemitter

export controller_interface

type 
  Controller*[T: controller_interface.DelegateInterface] = ref object of controller_interface.AccessInterface
    delegate: io_interface.AccessInterface
    events: EventEmitter
    contactsService: contacts_service.Service
    accountsService: accounts_service.ServiceInterface

# forward declaration:
method getContacts*[T](self: Controller[T], useCache: bool = true): seq[ContactsDto]

proc newController*[T](delegate: io_interface.AccessInterface, 
  events: EventEmitter,
  contactsService: contacts_service.Service,
  accountsService: accounts_service.ServiceInterface): Controller[T] =
  result = Controller[T]()
  result.delegate = delegate
  result.events = events
  result.contactsService = contactsService
  result.accountsService = accountsService

method delete*[T](self: Controller[T]) =
  discard

method init*[T](self: Controller[T]) =
  self.events.on(SignalType.Message.event) do(e: Args):
    let msgData = MessageSignal(e);
    if msgData.contacts.len > 0:
      let contacts = self.getContacts(false)
      self.delegate.updateContactList(contacts)
  self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
    var evArgs = ContactArgs(e)
    self.delegate.contactAdded(evArgs.contact)

  self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
    var evArgs = ContactArgs(e)
    self.delegate.contactBlocked(evArgs.contact)

  self.events.on(SIGNAL_CONTACT_UNBLOCKED) do(e: Args):
    var evArgs = ContactArgs(e)
    self.delegate.contactUnblocked(evArgs.contact)

  self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
    var evArgs = ContactArgs(e)
    self.delegate.contactRemoved(evArgs.contact)

  self.events.on(SIGNAL_CONTACT_LOOKED_UP) do(e: Args):
    let args = LookupResolvedArgs(e)
    self.delegate.contactLookedUp(args.id)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    # I left this as part it was.
    let contacts = self.getContacts()
    self.delegate.setContactList(contacts)

    # Since we have the exact contact which has been updated, then we need to improve the way of updating the view
    # and instead setting the whole list for every change we should update only the appropriate item in the view.
    # Example:
    # let args = ContactUpdatedArgs(e)
    # let contactDto = self.contactsService.getContactById(args.id)
    # self.delegate.onContactUpdated(contactDto)

method getContacts*[T](self: Controller[T], useCache: bool = true): seq[ContactsDto] =
  return self.contactsService.getContacts(useCache)

method getContact*[T](self: Controller[T], id: string): ContactsDto =
  return self.contactsService.getContactById(id)

method generateAlias*[T](self: Controller[T], publicKey: string): string =
  return self.accountsService.generateAlias(publicKey)

method addContact*[T](self: Controller[T], publicKey: string): void =
  self.contactsService.addContact(publicKey)

method rejectContactRequest*[T](self: Controller[T], publicKey: string): void =
  self.contactsService.rejectContactRequest(publicKey)

method unblockContact*[T](self: Controller[T], publicKey: string): void =
  self.contactsService.unblockContact(publicKey)

method blockContact*[T](self: Controller[T], publicKey: string): void =
  self.contactsService.blockContact(publicKey)

method removeContact*[T](self: Controller[T], publicKey: string): void =
  self.contactsService.removeContact(publicKey)

method changeContactNickname*[T](self: Controller[T], publicKey: string, nickname: string) =
  self.contactsService.changeContactNickname(publicKey, nickname)

method lookupContact*[T](self: Controller[T], value: string): void =
  self.contactsService.lookupContact(value)