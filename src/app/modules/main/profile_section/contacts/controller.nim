import ./controller_interface
import io_interface
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
method getContacts*[T](self: Controller[T]): seq[ContactsDto]

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
  self.events.on("contactAdded") do(e: Args):
    let contacts = self.getContacts()
    self.delegate.setContactList(contacts)

  self.events.on("contactBlocked") do(e: Args):
    let contacts = self.getContacts()
    self.delegate.setContactList(contacts)

  self.events.on("contactUnblocked") do(e: Args):
    let contacts = self.getContacts()
    self.delegate.setContactList(contacts)

  self.events.on("contactRemoved") do(e: Args):
    let contacts = self.getContacts()
    self.delegate.setContactList(contacts)

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

method getContacts*[T](self: Controller[T]): seq[ContactsDto] =
  return self.contactsService.getContacts()

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