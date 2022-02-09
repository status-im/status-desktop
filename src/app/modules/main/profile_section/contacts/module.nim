import NimQml, chronicles

import io_interface, view, controller
import ../../../shared_models/contacts_item
import ../../../shared_models/contacts_model
import ../io_interface as delegate_interface

import ../../../../core/eventemitter
import ../../../../../app_service/service/contacts/service as contacts_service

export io_interface

logScope:
  topics = "profile-section-contacts-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.AccessInterface
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface,
  events: EventEmitter,
  contactsService: contacts_service.Service):
  Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, contactsService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete

proc createItemFromPublicKey(self: Module, publicKey: string): Item =
  let contact =  self.controller.getContact(publicKey)
  let (name, image, isIdenticon) = self.controller.getContactNameAndImage(contact.id)

  return initItem(contact.id, name, image, isIdenticon, contact.isContact(), contact.isBlocked(),
  contact.requestReceived())

proc initModels(self: Module) =
  var myContacts: seq[Item]
  var blockedContacts: seq[Item]
  let contacts =  self.controller.getContacts()
  for c in contacts:
    let item = self.createItemFromPublicKey(c.id)
    if(item.isContact()):
      myContacts.add(item)
    if(item.isBlocked()):
      blockedContacts.add(item)

  self.view.myContactsModel().addItems(myContacts)
  self.view.blockedContactsModel().addItems(blockedContacts)

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.initModels()
  self.moduleLoaded = true
  self.delegate.contactsModuleDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method addContact*(self: Module, publicKey: string) =
  self.controller.addContact(publicKey)

method contactAdded*(self: Module, publicKey: string) =
  let item = self.createItemFromPublicKey(publicKey)
  self.view.myContactsModel().addItem(item)
  self.view.blockedContactsModel().removeItemWithPubKey(publicKey)

method contactBlocked*(self: Module, publicKey: string) =
  let item = self.createItemFromPublicKey(publicKey)
  self.view.myContactsModel().removeItemWithPubKey(publicKey)
  self.view.blockedContactsModel().addItem(item)

method contactUnblocked*(self: Module, publicKey: string) =
  let item = self.createItemFromPublicKey(publicKey)
  self.view.myContactsModel().addItem(item)
  self.view.blockedContactsModel().removeItemWithPubKey(publicKey)

method contactRemoved*(self: Module, publicKey: string) =
  self.view.myContactsModel().removeItemWithPubKey(publicKey)
  self.view.blockedContactsModel().removeItemWithPubKey(publicKey)

method contactNicknameChanged*(self: Module, publicKey: string) =
  let (name, _, _) = self.controller.getContactNameAndImage(publicKey)
  self.view.myContactsModel().updateName(publicKey, name)
  self.view.blockedContactsModel().updateName(publicKey, name)

method contactUpdated*(self: Module, publicKey: string) =
  let item = self.createItemFromPublicKey(publicKey)
  self.view.myContactsModel().updateItem(item)
  self.view.blockedContactsModel().updateItem(item)

method unblockContact*(self: Module, publicKey: string) =
  self.controller.unblockContact(publicKey)

method blockContact*(self: Module, publicKey: string) =
  self.controller.blockContact(publicKey)

method removeContact*(self: Module, publicKey: string) =
  self.controller.removeContact(publicKey)

method changeContactNickname*(self: Module, publicKey: string, nickname: string) =
  self.controller.changeContactNickname(publicKey, nickname)
