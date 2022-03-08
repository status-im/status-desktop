import NimQml, strutils
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../shared_models/[user_model, user_item]
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/chat/service as chat_service
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

proc newModule*(
  delegate: delegate_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service,
): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable,
    contactService, chatService, communityService, messageService,
  )
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
  let (admin, joined) = self.controller.getChatMemberInfo(singletonInstance.userProfile.getPubKey())
  let loggedInUserDisplayName = singletonInstance.userProfile.getName() & " (You)"
  self.view.model().addItem(initItem(
    singletonInstance.userProfile.getPubKey(),
    loggedInUserDisplayName,
    singletonInstance.userProfile.getEnsName(),
    localNickname = "",
    alias = singletonInstance.userProfile.getUsername(),
    OnlineStatus.Online,
    singletonInstance.userProfile.getIcon(),
    singletonInstance.userProfile.getIdenticon(),
    singletonInstance.userProfile.getIsIdenticon(),
    isAdded = true,
    admin,
    joined,
  ))

    # add other memebers
  let publicKeys = self.controller.getMembersPublicKeys()
  for publicKey in publicKeys:
    if (publicKey == singletonInstance.userProfile.getPubKey()):
      continue

    let (admin, joined) = self.controller.getChatMemberInfo(publicKey)
    let contactDetails = self.controller.getContactDetails(publicKey)
    let statusUpdateDto = self.controller.getStatusForContact(publicKey)
    let status = statusUpdateDto.statusType.int.OnlineStatus
    self.view.model().addItem(initItem(
      publicKey,
      contactDetails.displayName,
      contactDetails.details.name,
      contactDetails.details.localNickname,
      contactDetails.details.alias,
      status,
      contactDetails.icon,
      contactDetails.details.identicon,
      contactDetails.isidenticon,
      contactDetails.details.added,
      admin, 
      joined
      ))

  self.moduleLoaded = true
  self.delegate.usersDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method newMessagesLoaded*(self: Module, messages: seq[MessageDto]) =
  let chat = self.controller.getChat()
  if not chat.isPublicChat():
    return

  for m in messages:
    if(self.view.model().isContactWithIdAdded(m.`from`)):
      continue

    let contactDetails = self.controller.getContactDetails(m.`from`)
    let statusUpdateDto = self.controller.getStatusForContact(m.`from`)
    let status = statusUpdateDto.statusType.int.OnlineStatus
    self.view.model().addItem(initItem(
      m.`from`,
      contactDetails.displayName,
      contactDetails.details.name,
      contactDetails.details.localNickname,
      contactDetails.details.alias,
      status,
      contactDetails.icon,
      contactDetails.details.identicon,
      contactDetails.isidenticon,
      contactDetails.details.added,
      ))

method contactNicknameChanged*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().setName(
    publicKey,
    contactDetails.displayName,
    contactDetails.details.name,
    contactDetails.details.localNickname
    )

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    let status = s.statusType.int.OnlineStatus
    self.view.model().setOnlineStatus(s.publicKey, status)

method contactUpdated*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    publicKey,
    contactDetails.displayName,
    contactDetails.details.name,
    contactDetails.details.localNickname,
    contactDetails.details.alias,
    contactDetails.icon,
    contactDetails.isidenticon,
    contactDetails.details.added,
  )

method loggedInUserImageChanged*(self: Module) =
  self.view.model().setIcon(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon(),
  singletonInstance.userProfile.getIsIdenticon())

method onChatMembersAdded*(self: Module,  ids: seq[string]) =
  for id in ids:
    if(self.view.model().isContactWithIdAdded(id)):
      continue

    let (admin, joined) = self.controller.getChatMemberInfo(id)
    let contactDetails = self.controller.getContactDetails(id)
    let statusUpdateDto = self.controller.getStatusForContact(id)
    let status = statusUpdateDto.statusType.int.OnlineStatus
    self.view.model().addItem(initItem(
      id,
      contactDetails.displayName,
      contactDetails.details.name,
      contactDetails.details.localNickname,
      contactDetails.details.alias,
      status,
      contactDetails.icon,
      contactDetails.details.identicon,
      contactDetails.isidenticon,
      contactDetails.details.added,
      admin, 
      joined
      ))

method onChatMemberRemoved*(self: Module, id: string) =
  self.view.model().removeItemById(id)

method onChatMemberUpdated*(self: Module, publicKey: string, admin: bool, joined: bool) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    publicKey,
    contactDetails.displayName,
    contactDetails.details.name,
    contactDetails.details.localNickname,
    contactDetails.details.alias,
    contactDetails.icon,
    contactDetails.isidenticon,
    contactDetails.details.added,
    admin,
    joined)

method getMembersPublicKeys*(self: Module): string =
  let publicKeys = self.controller.getMembersPublicKeys()
  return publicKeys.join(" ")

