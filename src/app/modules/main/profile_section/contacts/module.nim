import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../global/global_singleton

import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto/contacts
import ../../../../../app_service/service/accounts/service as accounts_service

import eventemitter

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T,
  events: EventEmitter,
  contactsService: contacts_service.Service,
  accountsService: accounts_service.ServiceInterface):
  Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController[Module[T]](result, events, contactsService, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("contactsModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method setContactList*[T](self: Module[T], contacts: seq[ContactsDto]) =
  self.view.setContactList(contacts)

method updateContactList*[T](self: Module[T], contacts: seq[ContactsDto]) =
  self.view.updateContactList(contacts)

method load*[T](self: Module[T]) =
  self.controller.init()
  let contacts =  self.controller.getContacts()
  self.setContactList(contacts)
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getContact*[T](self: Module[T], id: string): ContactsDto =
  self.controller.getContact(id)

method generateAlias*[T](self: Module[T], publicKey: string): string =
  self.controller.generateAlias(publicKey)

method addContact*[T](self: Module[T], publicKey: string) =
  self.controller.addContact(publicKey)

method contactAdded*[T](self: Module[T], contact: ContactsDto) =
  self.view.contactAdded(contact)

method contactBlocked*[T](self: Module[T], contact: ContactsDto) =
  self.view.contactBlocked(contact)

method contactUnblocked*[T](self: Module[T], contact: ContactsDto) =
  self.view.contactUnblocked(contact)

method contactRemoved*[T](self: Module[T], contact: ContactsDto) =
  self.view.contactRemoved(contact)

method rejectContactRequest*[T](self: Module[T], publicKey: string) =
  self.controller.rejectContactRequest(publicKey)

method unblockContact*[T](self: Module[T], publicKey: string) =
  self.controller.unblockContact(publicKey)

method blockContact*[T](self: Module[T], publicKey: string) =
  self.controller.blockContact(publicKey)

method removeContact*[T](self: Module[T], publicKey: string) =
  self.controller.removeContact(publicKey)

method changeContactNickname*[T](self: Module[T], publicKey: string, nickname: string) =
  self.controller.changeContactNickname(publicKey, nickname)

method lookupContact*[T](self: Module[T], value: string) =
  self.controller.lookupContact(value)

method contactLookedUp*[T](self: Module[T], id: string): void =
  self.view.contactLookedUp(id)