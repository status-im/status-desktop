import NimQml, sequtils, sugar
import io_interface
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
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool

# Forward declaration
proc addChatMember(self: Module,  member: ChatMember)

proc newModule*(
  events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service,
): Module =
  result = Module()
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable,
    contactService, chatService, communityService, messageService,
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.controller.delete
  self.view.delete
  self.viewVariant.delete

method load*(self: Module) =
  if not self.moduleLoaded:
    self.controller.init()
    self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.updateMembersList()
  self.moduleLoaded = true

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method contactNicknameChanged*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().setName(
    publicKey,
    contactDetails.dto.displayName,
    contactDetails.dto.name,
    contactDetails.dto.localNickname
    )

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  for s in statusUpdates:
    var status = toOnlineStatus(s.statusType)
    self.view.model().setOnlineStatus(s.publicKey, status)

method contactUpdated*(self: Module, publicKey: string) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    pubKey = publicKey,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    isContact = contactDetails.dto.isContact,
    isVerified = contactDetails.dto.isContactVerified(),
    isUntrustworthy = contactDetails.dto.trustStatus == TrustStatus.Untrustworthy,
  )

method userProfileUpdated*(self: Module) =
  self.contactUpdated(singletonInstance.userProfile.getPubKey())

method loggedInUserImageChanged*(self: Module) =
  self.view.model().setIcon(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())

proc addChatMember(self: Module,  member: ChatMember) =
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
  if (isMe):
    let currentUserStatus = intToEnum(singletonInstance.userProfile.getCurrentUserStatus(), StatusType.Unknown)
    status = toOnlineStatus(currentUserStatus)
  else:
    let statusUpdateDto = self.controller.getStatusForContact(member.id)
    status = toOnlineStatus(statusUpdateDto.statusType)

  self.view.model().addItem(initMemberItem(
    pubKey = member.id,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
    colorHash = contactDetails.colorHash,
    onlineStatus = status,
    isContact = contactDetails.dto.isContact,
    isVerified = contactDetails.dto.isContactVerified(),
    isAdmin = member.admin,
    joined = member.joined,
    isUntrustworthy = contactDetails.dto.trustStatus == TrustStatus.Untrustworthy
    ))

method onChatMembersAdded*(self: Module, ids: seq[string]) =
  for memberId in ids:
    self.addChatMember(ChatMember(id: memberId, admin: false, joined: true, roles: @[]))

method onChatMemberRemoved*(self: Module, id: string) =
  self.view.model().removeItemById(id)

method onMembersChanged*(self: Module,  members: seq[ChatMember]) =
  let modelIDs = self.view.model().getItemIds()
  let membersAdded = filter(members, member => not modelIDs.contains(member.id))
  let membersRemoved = filter(modelIDs, id => not members.any(member => member.id == id))

  for member in membersAdded:
    self.addChatMember(member)

  for id in membersRemoved:
    self.onChatMemberRemoved(id)


method onChatMemberUpdated*(self: Module, publicKey: string, admin: bool, joined: bool) =
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().updateItem(
    pubKey = publicKey,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    isContact = contactDetails.dto.isContact,
    isVerified = contactDetails.dto.isContactVerified(),
    isAdmin = admin,
    joined = joined,
    isUntrustworthy = contactDetails.dto.trustStatus == TrustStatus.Untrustworthy,
    )

method addGroupMembers*(self: Module, pubKeys: seq[string]) =
  self.controller.addGroupMembers(pubKeys)

method removeGroupMembers*(self: Module, pubKeys: seq[string]) =
  self.controller.removeGroupMembers(pubKeys)

method updateMembersList*(self: Module) =
  let members = self.controller.getChatMembers()
  for member in members:
    self.addChatMember(member)
