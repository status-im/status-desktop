import io_interface

import ../../../../../../app_service/service/contacts/service as contact_service
import ../../../../../../app_service/service/community/service as community_service
import ../../../../../../app_service/service/message/service as message_service
import ../../../../../../app_service/service/chat/service as chat_service

import ../../../../../core/eventemitter
import ../../../../../core/unique_event_emitter

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: UniqueUUIDEventEmitter
    sectionId: string
    chatId: string
    belongsToCommunity: bool
    isUsersListAvailable: bool #users list is not available for 1:1 chat
    contactService: contact_service.Service
    chatService: chat_service.Service
    communityService: community_service.Service
    messageService: message_service.Service

# Forward declaration
proc getChat*(self: Controller): ChatDto

proc newController*(
  delegate: io_interface.AccessInterface, events: EventEmitter, sectionId: string, chatId: string,
  belongsToCommunity: bool, isUsersListAvailable: bool, contactService: contact_service.Service,
  chatService: chat_service.Service, communityService: community_service.Service,
  messageService: message_service.Service
): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = initUniqueUUIDEventEmitter(events)
  result.sectionId = sectionId
  result.chatId = chatId
  result.belongsToCommunity = belongsToCommunity
  result.isUsersListAvailable = isUsersListAvailable
  result.contactService = contactService
  result.chatService = chatService
  result.communityService = communityService
  result.messageService = messageService
  result.chatService = chatService

proc delete*(self: Controller) =
  self.events.disconnect()

proc handleCommunityOnlyConnections(self: Controller) =
  self.events.on(SIGNAL_COMMUNITY_MEMBER_APPROVED) do(e: Args):
    let args = CommunityMemberArgs(e)
    if (args.communityId == self.sectionId):
      self.delegate.onChatMembersAdded(@[args.pubKey])

  self.events.on(SIGNAL_COMMUNITY_MEMBERS_CHANGED) do(e:Args):
    let args = CommunityMembersArgs(e)
    if args.communityId != self.sectionId:
      return

    self.delegate.onMembersChanged(args.members)

proc init*(self: Controller) =
  # Events that are needed for all chats because of mentions
  self.events.on(SIGNAL_CONTACT_NICKNAME_CHANGED) do(e: Args):
    let args = ContactArgs(e)
    self.delegate.contactNicknameChanged(args.contactId)

  self.events.on(SIGNAL_CONTACT_UPDATED) do(e: Args):
    let args = ContactArgs(e)
    self.delegate.contactUpdated(args.contactId)

  self.events.on(SIGNAL_LOGGEDIN_USER_NAME_CHANGED) do(e: Args):
    self.delegate.userProfileUpdated()

  self.events.on(SIGNAL_LOGGEDIN_USER_IMAGE_CHANGED) do(e: Args):
    self.delegate.loggedInUserImageChanged()

  # Events only for the user list, so not needed in one to one chats
  if(self.isUsersListAvailable):
    self.events.on(SIGNAL_CONTACT_UNTRUSTWORTHY) do(e: Args):
      var args = TrustArgs(e)
      self.delegate.contactUpdated(args.publicKey)

    self.events.on(SIGNAL_CONTACT_TRUSTED) do(e: Args):
      var args = TrustArgs(e)
      self.delegate.contactUpdated(args.publicKey)

    self.events.on(SIGNAL_REMOVED_TRUST_STATUS) do(e: Args):
      var args = TrustArgs(e)
      self.delegate.contactUpdated(args.publicKey)

    self.events.on(SIGNAL_CONTACTS_STATUS_UPDATED) do(e: Args):
      let args = ContactsStatusUpdatedArgs(e)
      self.delegate.contactsStatusUpdated(args.statusUpdates)

    self.events.on(SIGNAL_CONTACT_ADDED) do(e: Args):
      let args = ContactArgs(e)
      self.delegate.contactUpdated(args.contactId)

    self.events.on(SIGNAL_CONTACT_REMOVED) do(e: Args):
      let args = ContactArgs(e)
      self.delegate.contactUpdated(args.contactId)

    self.events.on(SIGNAL_CONTACT_BLOCKED) do(e: Args):
      let args = ContactArgs(e)
      self.delegate.contactUpdated(args.contactId)

    self.events.on(SIGNAL_CHAT_MEMBERS_ADDED) do(e: Args):
      let args = ChatMembersAddedArgs(e)
      if (args.chatId == self.chatId):
        self.delegate.onChatMembersAdded(args.ids)

    self.events.on(SIGNAL_CHAT_MEMBERS_CHANGED) do(e: Args):
      var args = ChatMembersChangedArgs(e)
      if (args.chatId == self.chatId):
        self.delegate.onMembersChanged(args.members)

    self.events.on(SIGNAL_CHAT_MEMBER_REMOVED) do(e: Args):
      let args = ChatMemberRemovedArgs(e)
      if (args.chatId == self.chatId):
        self.delegate.onChatMemberRemoved(args.id)

    self.events.on(SIGNAL_CHAT_MEMBER_UPDATED) do(e: Args):
      let args = ChatMemberUpdatedArgs(e)
      if (args.chatId == self.chatId):
        self.delegate.onChatMemberUpdated(args.id, args.role, args.joined)

    # Events only for community channel
    if (self.belongsToCommunity):
      self.handleCommunityOnlyConnections()

proc belongsToCommunity*(self: Controller): bool =
  self.belongsToCommunity

proc getChat*(self: Controller): ChatDto =
  return self.chatService.getChatById(self.chatId)

proc getChatMembers*(self: Controller): seq[ChatMember] =
  return self.chatService.getChatById(self.chatId).members

proc getContactNameAndImage*(self: Controller, contactId: string):
    tuple[name: string, image: string, largeImage: string] =
  return self.contactService.getContactNameAndImage(contactId)

proc getContactDetails*(self: Controller, contactId: string): ContactDetails =
  return self.contactService.getContactDetails(contactId)

proc getStatusForContact*(self: Controller, contactId: string): StatusUpdateDto =
  return self.contactService.getStatusForContactWithId(contactId)

proc addGroupMembers*(self: Controller, pubKeys: seq[string]) =
  self.chatService.addGroupMembers("", self.chatId, pubKeys)

proc removeGroupMembers*(self: Controller, pubKeys: seq[string]) =
  self.chatService.removeMembersFromGroupChat("", self.chatId, pubKeys)
