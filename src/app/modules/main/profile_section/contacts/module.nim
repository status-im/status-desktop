import NimQml, Tables

import io_interface, view, controller, model
import ../io_interface as delegate_interface
import ../../../../global/global_singleton

import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto/contacts
import ../../../../../app_service/service/accounts/service as accounts_service

import eventemitter

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service,
  accountsService: accounts_service.ServiceInterface):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService, accountsService)
  result.moduleLoaded = false

  singletonInstance.engine.setRootContextProperty("contactsModule", result.viewVariant)

method delete*(self: Module) =
  self.view.delete

method setContactList*(self: Module, contacts: seq[ContactsDto]) =
  self.view.model().setContactList(contacts)

method updateContactList*(self: Module, contacts: seq[ContactsDto]) =
  self.view.model().updateContactList(contacts)

method load*(self: Module) =
  self.controller.init()
  self.view.load()
  
method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  let contacts =  self.controller.getContacts()
  self.setContactList(contacts)

  self.moduleLoaded = true
  self.delegate.contactsModuleDidLoad()

method getContact*(self: Module, id: string): ContactsDto =
  self.controller.getContact(id)

method generateAlias*(self: Module, publicKey: string): string =
  self.controller.generateAlias(publicKey)

method addContact*(self: Module, publicKey: string) =
  self.controller.addContact(publicKey)

method contactAdded*(self: Module, contact: ContactsDto) =
  self.view.model().contactAdded(contact)

method contactBlocked*(self: Module, publicKey: string) =
  # once we refactore a model, we should pass only pk from here (like we have for nickname change)
  let contact = self.controller.getContact(publicKey)
  self.view.model().contactBlocked(contact)

method contactUnblocked*(self: Module, publicKey: string) =
  # once we refactore a model, we should pass only pk from here (like we have for nickname change)
  let contact = self.controller.getContact(publicKey)
  self.view.model().contactUnblocked(contact)

method contactRemoved*(self: Module, publicKey: string) =
  # once we refactore a model, we should pass only pk from here (like we have for nickname change)
  let contact = self.controller.getContact(publicKey)
  self.view.model().contactRemoved(contact)

method contactNicknameChanged*(self: Module, publicKey: string, nickname: string) =
  self.view.model().changeNicknameForContactWithId(publicKey, nickname)

method rejectContactRequest*(self: Module, publicKey: string) =
  self.controller.rejectContactRequest(publicKey)

method unblockContact*(self: Module, publicKey: string) =
  self.controller.unblockContact(publicKey)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method removeContact*(self: Module, publicKey: string) =
  self.controller.removeContact(publicKey)

method changeContactNickname*(self: Module, publicKey: string, nickname: string) =
  self.controller.changeContactNickname(publicKey, nickname)

method lookupContact*(self: Module, value: string) =
  self.controller.lookupContact(value)

method contactLookedUp*(self: Module, id: string) =
  self.view.contactLookedUp(id)