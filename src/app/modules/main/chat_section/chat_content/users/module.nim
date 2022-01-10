import NimQml
import io_interface
import ../io_interface as delegate_interface
import view, item, model, controller
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service

export io_interface

type 
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: controller.AccessInterface
    moduleLoaded: bool

proc newModule*(delegate: delegate_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string, 
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service, 
  communityService: community_service.Service, messageService: message_service.Service): 
  Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable, 
  contactService, communityService, messageService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  # add me as the first user to the list
  let loggedInUserDisplayName = singletonInstance.userProfile.getName() & "(You)"
  self.view.model().addItem(initItem(singletonInstance.userProfile.getPubKey(), loggedInUserDisplayName, 
  OnlineStatus.Online, singletonInstance.userProfile.getIcon(), singletonInstance.userProfile.getIsIdenticon()))

  # add other memebers
  let usersKeys = self.controller.getMembersPublicKeys()
  for k in usersKeys:
    let (name, image, isIdenticon) = self.controller.getContactNameAndImage(k)
    let statusUpdateDto = self.controller.getStatusForContact(k)
    let status = statusUpdateDto.statusType.int.OnlineStatus
    self.view.model().addItem(initItem(k, name, status, image, isidenticon))

  self.moduleLoaded = true
  self.delegate.usersDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method newMessagesLoaded*(self: Module, messages: seq[MessageDto]) = 
  for m in messages:
    if(self.view.model().isContactWithIdAdded(m.`from`)):
      continue

    let (name, image, isIdenticon) = self.controller.getContactNameAndImage(m.`from`)
    let statusUpdateDto = self.controller.getStatusForContact(m.`from`)
    let status = statusUpdateDto.statusType.int.OnlineStatus
    self.view.model().addItem(initItem(m.`from`, name, status, image, isidenticon))

method contactNicknameChanged*(self: Module, publicKey: string) =
  let (name, _, _) = self.controller.getContactNameAndImage(publicKey)
  self.view.model().setName(publicKey, name)

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = s.statusType.int.OnlineStatus
    self.view.model().setOnlineStatus(s.publicKey, status)

method contactUpdated*(self: Module, publicKey: string) =
  let (name, image, isIdenticon) = self.controller.getContactNameAndImage(publicKey)
  self.view.model().updateItem(publicKey, name, image, isIdenticon)

method loggedInUserImageChanged*(self: Module) =
  self.view.model().setIcon(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon(),
  singletonInstance.userProfile.getIsIdenticon())