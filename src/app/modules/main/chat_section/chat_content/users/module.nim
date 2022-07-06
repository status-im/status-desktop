import NimQml, strutils
import io_interface
import ../io_interface as delegate_interface
import view, controller
import ../../../../shared_models/[member_model, member_item]
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/common/conversion
import ../../../../../../app_service/common/types
import ../../../../../../app_service/service/contacts/dto/contacts
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
    controller: Controller
    moduleLoaded: bool

# Forward declaration
method addChatMember*(self: Module,  member: ChatMember)

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
  let members = self.controller.getChatMembers()
  for member in members:
    self.addChatMember(member)

  self.moduleLoaded = true
  self.delegate.usersDidLoad()

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method onNewMessagesLoaded*(self: Module, messages: seq[MessageDto]) =
  for m in messages:
    if(self.view.model().isContactWithIdAdded(m.`from`)):
      continue

    let contactDetails = self.controller.getContactDetails(m.`from`)
    let statusUpdateDto = self.controller.getStatusForContact(m.`from`)
    let status = toOnlineStatus(statusUpdateDto.statusType)
    self.view.model().addItem(initMemberItem(
      pubKey = m.`from`,
      displayName = contactDetails.displayName,
      ensName = contactDetails.details.name, # is it correct?
      localNickname = contactDetails.details.localNickname,
      alias = contactDetails.details.alias,
      icon = contactDetails.icon,
      onlineStatus = status,
      isContact = contactDetails.details.isContact,
      isUntrustworthy = contactDetails.details.trustStatus == TrustStatus.Untrustworthy,
      )
    )

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
    var status = toOnlineStatus(s.statusType)
    self.view.model().setOnlineStatus(s.publicKey, status)

method contactUpdated*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    pubKey = publicKey,
    displayName = contactDetails.displayName,
    ensName = contactDetails.details.name,
    localNickname = contactDetails.details.localNickname,
    alias = contactDetails.details.alias,
    icon = contactDetails.icon,
    isContact = contactDetails.details.isContact,
    isUntrustworthy = contactDetails.details.trustStatus == TrustStatus.Untrustworthy,
  )

method loggedInUserImageChanged*(self: Module) =
  self.view.model().setIcon(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())

method addChatMember*(self: Module,  member: ChatMember) =
  if member.id == "":
    return

  if not member.joined:
    if self.view.model().isContactWithIdAdded(member.id):
      # Member is no longer joined
      self.view.model().removeItemById(member.id)
    return

  if self.view.model().isContactWithIdAdded(member.id):
    return

  let isMe = member.id == singletonInstance.userProfile.getPubKey()
  let contactDetails = self.controller.getContactDetails(member.id)
  var status = OnlineStatus.Online
  var displayName = contactDetails.displayName
  if (isMe):
    displayName = displayName & " (You)"
    let currentUserStatus = intToEnum(singletonInstance.userProfile.getCurrentUserStatus(), StatusType.Unknown)
    status = toOnlineStatus(currentUserStatus)
  else:
    let statusUpdateDto = self.controller.getStatusForContact(member.id)
    status = toOnlineStatus(statusUpdateDto.statusType)
  
  self.view.model().addItem(initMemberItem(
    pubKey = member.id,
    displayName = displayName,
    ensName = contactDetails.details.name,
    localNickname = contactDetails.details.localNickname,
    alias = contactDetails.details.alias,
    icon = contactDetails.icon,
    onlineStatus = status,
    isContact = contactDetails.details.isContact,
    isAdmin = member.admin,
    joined = member.joined,
    isUntrustworthy = contactDetails.details.trustStatus == TrustStatus.Untrustworthy
    ))

method onChatMembersAdded*(self: Module,  ids: seq[string]) =
  for id in ids:
    self.addChatMember(self.controller.getChatMember(id))

method onChatUpdated*(self: Module,  chat: ChatDto) =
  for member in chat.members:
    self.addChatMember(self.controller.getChatMember(member.id))

  if chat.members.len > 0:
    let ids = self.view.model.getItemIds()
    for id in ids:
      var found = false
      for member in chat.members:
        if (member.id == id):
          found = true
          break
      if (not found):
        self.view.model().removeItemById(id)

method onChatMemberRemoved*(self: Module, id: string) =
  self.view.model().removeItemById(id)

method onChatMemberUpdated*(self: Module, publicKey: string, admin: bool, joined: bool) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    pubKey = publicKey,
    displayName = contactDetails.displayName,
    ensName = contactDetails.details.name,
    localNickname = contactDetails.details.localNickname,
    alias = contactDetails.details.alias,
    icon = contactDetails.icon,
    isContact = contactDetails.details.isContact,
    isAdmin = admin,
    joined = joined,
    isUntrustworthy = contactDetails.details.trustStatus == TrustStatus.Untrustworthy,
    )

method getMembersPublicKeys*(self: Module): string =
  let publicKeys = self.controller.getMembersPublicKeys()
  return publicKeys.join(" ")

