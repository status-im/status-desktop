import NimQml, sequtils, sugar
import io_interface
import view, controller
import ../../../../shared_models/[member_model, member_item]
import ../../../../../global/global_singleton
import ../../../../../core/eventemitter
import ../../../../../../app_service/common/types
import ../../../../../../app_service/service/contacts/dto/contacts
import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/chat/service as chat_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service
from ../../../../../../app_service/common/conversion import intToEnum

export io_interface

type
  Module* = ref object of io_interface.AccessInterface
    view: View
    viewVariant: QVariant
    controller: Controller
    moduleLoaded: bool
    isPublicCommunityChannel: bool
    isSectionMemberList: bool

# Forward declaration
proc processChatMember(self: Module,  member: ChatMember, reset: bool = false): tuple[doAdd: bool, memberItem: MemberItem]

proc newModule*(
  events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service, isSectionMemberList: bool = false,
): Module =
  result = Module()
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result, events, sectionId, chatId, belongsToCommunity, isUsersListAvailable,
    contactService, chatService, communityService, messageService,
  )
  result.moduleLoaded = false
  result.isPublicCommunityChannel = false
  result.isSectionMemberList = isSectionMemberList

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

method getUsersListVariant*(self: Module): QVariant =
  self.view.getModel()

method contactNicknameChanged*(self: Module, publicKey: string) =
  if self.isPublicCommunityChannel:
    return
  let contactDetails = self.controller.getContactDetails(publicKey)
  self.view.model().setName(
    publicKey,
    contactDetails.dto.displayName,
    contactDetails.dto.name,
    contactDetails.dto.localNickname
    )

method contactsStatusUpdated*(self: Module, statusUpdates: seq[StatusUpdateDto]) =
  if self.isPublicCommunityChannel:
    return
  for s in statusUpdates:
    var status = toOnlineStatus(s.statusType)
    self.view.model().setOnlineStatus(s.publicKey, status)

method contactUpdated*(self: Module, publicKey: string) =
  if self.isPublicCommunityChannel:
    return
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
    trustStatus = contactDetails.dto.trustStatus,
  )

method userProfileUpdated*(self: Module) =
  if self.isPublicCommunityChannel:
    return
  self.contactUpdated(singletonInstance.userProfile.getPubKey())

method loggedInUserImageChanged*(self: Module) =
  if self.isPublicCommunityChannel:
    return
  self.view.model().setIcon(singletonInstance.userProfile.getPubKey(), singletonInstance.userProfile.getIcon())

# This function either removes the member if it is no longer part of the community,
# does nothing if the member is already in the model or creates the MemberItem
proc processChatMember(self: Module,  member: ChatMember, reset: bool = false): tuple[doAdd: bool, memberItem: MemberItem] =
  result.doAdd = false
  if member.id == "":
    return

  if not reset and not self.controller.belongsToCommunity() and not member.joined:
    if self.view.model().isContactWithIdAdded(member.id):
      # Member is no longer joined
      self.view.model().removeItemById(member.id)
    return

  if not reset and self.view.model().isContactWithIdAdded(member.id):
    return

  let isMe = member.id == singletonInstance.userProfile.getPubKey()
  let contactDetails = self.controller.getContactDetails(member.id)
  var status = OnlineStatus.Online
  if isMe:
    let currentUserStatus = intToEnum(singletonInstance.userProfile.getCurrentUserStatus(), StatusType.Unknown)
    status = toOnlineStatus(currentUserStatus)
  else:
    let statusUpdateDto = self.controller.getStatusForContact(member.id)
    status = toOnlineStatus(statusUpdateDto.statusType)

  result.doAdd = true
  result.memberItem = initMemberItem(
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
    isCurrentUser = isMe,
    memberRole = member.role,
    joined = member.joined,
    trustStatus = contactDetails.dto.trustStatus,
  )

method onChatMembersAdded*(self: Module, ids: seq[string]) =
  if self.isPublicCommunityChannel:
    return
  var memberItems: seq[MemberItem] = @[]

  for memberId in ids:
    let (doAdd, item) = self.processChatMember(ChatMember(id: memberId, role: MemberRole.None, joined: true))
    if doAdd:
      memberItems.add(item)

  self.view.model().addItems(memberItems)

method onChatMemberRemoved*(self: Module, id: string) =
  if self.isPublicCommunityChannel:
    return
  self.view.model().removeItemById(id)

method onMembersChanged*(self: Module,  members: seq[ChatMember]) =
  if self.isPublicCommunityChannel:
    return
  let modelIDs = self.view.model().getItemIds()
  let membersAdded = filter(members, member => not modelIDs.contains(member.id))
  let membersRemoved = filter(modelIDs, id => not members.any(member => member.id == id))

  var memberItems: seq[MemberItem] = @[]
  for member in membersAdded:
    let (doAdd, item) = self.processChatMember(member)
    if doAdd:
      memberItems.add(item)
  self.view.model().addItems(memberItems)

  for id in membersRemoved:
    self.onChatMemberRemoved(id)

method onChatMemberUpdated*(self: Module, publicKey: string, memberRole: MemberRole, joined: bool) =
  if self.isPublicCommunityChannel:
    return
  let contactDetails = self.controller.getContactDetails(publicKey)
  discard self.view.model().updateItem(
    pubKey = publicKey,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    isContact = contactDetails.dto.isContact,
    memberRole,
    joined,
    trustStatus = contactDetails.dto.trustStatus,
  )

method addGroupMembers*(self: Module, pubKeys: seq[string]) =
  self.controller.addGroupMembers(pubKeys)

method removeGroupMembers*(self: Module, pubKeys: seq[string]) =
  self.controller.removeGroupMembers(pubKeys)

method updateMembersList*(self: Module, membersToReset: seq[ChatMember] = @[]) =
  let reset = membersToReset.len > 0
  var members: seq[ChatMember]
  if reset:
    members = membersToReset
  else:
    if self.controller.belongsToCommunity():
      let myCommunity = self.controller.getMyCommunity()

      if self.isSectionMemberList:
        members = myCommunity.members
      else:
        # TODO: when a new channel is added, chat may arrive earlier and we have no up to date community yet
        # see log here: https://github.com/status-im/status-desktop/issues/14442#issuecomment-2120756598
        # should be resolved in https://github.com/status-im/status-desktop/issues/11694
        let myChatId = self.controller.getMyChatId()
        let chat = myCommunity.getCommunityChat(myChatId)
        if not chat.tokenGated:
          # No need to get the members, this channel is not encrypted and can use the section member list
          self.isPublicCommunityChannel = true
          return
        self.isPublicCommunityChannel = false
        if chat.members.len > 0:
          members = chat.members
        else:
          # The channel now has a permisison, but the re-eval wasn't performed yet. Show all members for now
          members = myCommunity.members

    if members.len == 0:
      members = self.controller.getMyChat().members

  var memberItems: seq[MemberItem] = @[]

  for member in members:
    let (doAdd, item) = self.processChatMember(member, reset)
    if doAdd:
      memberItems.add(item)

  if reset:
    self.view.model().setItems(memberItems)
  else:
    self.view.model().addItems(memberItems)
