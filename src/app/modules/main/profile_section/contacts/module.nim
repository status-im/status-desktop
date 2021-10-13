import NimQml, Tables

import ./io_interface, ./view, ./controller
import ../../../../core/global_singleton

import ../../../../../app_service/service/contacts/service as contacts_service
import ../../../../../app_service/service/contacts/dto/contacts
import ../../../../../app_service/service/accounts/service as accounts_service

export io_interface

type 
  Module* [T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*[T](delegate: T, contactsService: contacts_service.ServiceInterface, accountsService: accounts_service.ServiceInterface): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  echo "Module loaded"
  result.controller = controller.newController[Module[T]](result, contactsService, accountsService)
  result.moduleLoaded = false

  echo "Module set as root prop"
  singletonInstance.engine.setRootContextProperty("contactsModule", result.viewVariant)

method delete*[T](self: Module[T]) =
  self.view.delete

method load*[T](self: Module[T]) =
#   let profile = self.controller.getProfile()
#   self.view.setProfile(profile)
  self.moduleLoaded = true

method isLoaded*[T](self: Module[T]): bool =
  return self.moduleLoaded

method getContact*[T](self: Module[T], id: string): ContactsDto =
  self.controller.getContact(id)

method generateAlias*[T](self: Module[T], publicKey: string): string =
  self.controller.generateAlias(publicKey)

method addContact*[T](self: Module[T], publicKey: string): void =
  self.controller.addContact(publicKey)

method rejectContactRequest*[T](self: Module[T], publicKey: string): void =
  self.controller.rejectContactRequest(publicKey)

method unblockContact*[T](self: Module[T], publicKey: string): void =
  self.controller.unblockContact(publicKey)

method blockContact*[T](self: Module[T], publicKey: string): void =
  self.controller.blockContact(publicKey)

method removeContact*[T](self: Module[T], publicKey: string): void =
  self.controller.removeContact(publicKey)

method changeContactNickname*[T](self: Module[T], accountKeyUID: string, publicKey: string, nicknameToSet: string): void =
  self.controller.changeContactNickname(accountKeyUID, publicKey, nicknameToSet)
