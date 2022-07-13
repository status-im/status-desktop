import NimQml, Tables, json, sequtils, strformat, chronicles, os, std/algorithm, strutils

import ./dto/chat as chat_dto
import ../message/dto/message as message_dto
import ../activity_center/dto/notification as notification_dto
import ../contacts/service as contact_service
import ../../../backend/chat as status_chat
import ../../../backend/group_chat as status_group_chat
import ../../../backend/chatCommands as status_chat_commands
import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import ../../../app/core/signals/types
import ../../../constants

import ../../common/message as message_common
from ../../common/account_constants import ZERO_ADDRESS

export chat_dto


logScope:
  topics = "chat-service"

include ../../common/json_utils

type
  ChatUpdateArgs* = ref object of Args
    chats*: seq[ChatDto]
    messages*: seq[MessageDto]
    # TODO refactor that part
    # pinnedMessages*: seq[MessageDto]
    # emojiReactions*: seq[Reaction]
    # communities*: seq[Community]
    # communityMembershipRequests*: seq[CommunityMembershipRequest]
    activityCenterNotifications*: seq[ActivityCenterNotificationDto]
    # statusUpdates*: seq[StatusUpdate]
    # deletedMessages*: seq[RemovedMessage]

  CreatedChatArgs* = ref object of Args
    chat*: ChatDto

  ChatArgs* = ref object of Args
    communityId*: string # This param should be renamed to `sectionId`, that will avoid some confusions one may have.
    chatId*: string

  ChatExtArgs* = ref object of ChatArgs
    ensName*: string

  MessageSendingSuccess* = ref object of Args
    chat*: ChatDto
    message*: MessageDto

  MessageArgs* = ref object of Args
    id*: string
    channel*: string

  ChatRenameArgs* = ref object of Args
    id*: string
    newName*: string

  ChatMembersAddedArgs* = ref object of Args
    chatId*: string
    ids*: seq[string]

  ChatMemberRemovedArgs* = ref object of Args
    chatId*: string
    id*: string

  ChatMemberUpdatedArgs* = ref object of Args
    chatId*: string
    id*: string
    admin*: bool
    joined*: bool


# Signals which may be emitted by this service:
const SIGNAL_CHAT_UPDATE* = "chatUpdate"
const SIGNAL_CHAT_LEFT* = "channelLeft"
const SIGNAL_SENDING_FAILED* = "messageSendingFailed"
const SIGNAL_SENDING_SUCCESS* = "messageSendingSuccess"
const SIGNAL_MESSAGE_DELETED* = "messageDeleted"
const SIGNAL_CHAT_MUTED* = "chatMuted"
const SIGNAL_CHAT_UNMUTED* = "chatUnmuted"
const SIGNAL_CHAT_HISTORY_CLEARED* = "chatHistoryCleared"
const SIGNAL_CHAT_RENAMED* = "chatRenamed"
const SIGNAL_CHAT_MEMBERS_ADDED* = "chatMemberAdded"
const SIGNAL_CHAT_MEMBER_REMOVED* = "chatMemberRemoved"
const SIGNAL_CHAT_MEMBER_UPDATED* = "chatMemberUpdated"
const SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT* = "switchToOrCreateOneToOneChat"
const SIGNAL_CHAT_ADDED_OR_UPDATED* = "chatAddedOrUpdated"
const SIGNAL_CHAT_CREATED* = "chatCreated"

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    channelGroups: OrderedTable[string, ChannelGroupDto] # [chatGroup_id, ChannelGroupDto]
    contactService: contact_service.Service

  proc delete*(self: Service) =
    discard

  proc newService*(events: EventEmitter, contactService: contact_service.Service): Service =
    new(result, delete)
    result.events = events
    result.contactService = contactService
    result.chats = initTable[string, ChatDto]()

  # Forward declarations
  proc updateOrAddChat*(self: Service, chat: ChatDto)

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling chat updates
      if (receivedData.chats.len > 0):
        var chats: seq[ChatDto] = @[]
        for chatDto in receivedData.chats:
          if (chatDto.active):
            chats.add(chatDto)
            self.updateOrAddChat(chatDto)
        self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(messages: receivedData.messages, chats: chats))

      if (receivedData.clearedHistories.len > 0):
        for clearedHistoryDto in receivedData.clearedHistories:
          self.events.emit(SIGNAL_CHAT_HISTORY_CLEARED, ChatArgs(chatId: clearedHistoryDto.chatId))
  
  proc sortPersonnalChatAsFirst[T, D](x, y: (T, D)): int =
    if (x[1].channelGroupType == Personal): return -1
    if (y[1].channelGroupType == Personal): return 1
    return 0

  proc init*(self: Service) =  
    self.doConnect()

    try:
      let response = status_chat.getChats()

      var chats: seq[ChatDto] = @[]
      for (sectionId, section) in response.result.pairs:
        var channelGroup = section.toChannelGroupDto()
        channelGroup.id = sectionId
        self.channelGroups[sectionId] = channelGroup
        for (chatId, chat) in section["chats"].pairs:
          chats.add(chat.toChatDto())

      # Make the personal channelGroup the first one
      self.channelGroups.sort(sortPersonnalChatAsFirst[string, ChannelGroupDto], SortOrder.Ascending)

      for chat in chats:
        if chat.active and chat.chatType != chat_dto.ChatType.Unknown:
          self.chats[chat.id] = chat
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc getChannelGroups*(self: Service): seq[ChannelGroupDto] =
    return toSeq(self.channelGroups.values)

  proc hasChannel*(self: Service, chatId: string): bool =
    self.chats.hasKey(chatId)


  proc getChatIndex*(self: Service, channelGroupId, chatId: string): int =
    var i = 0
    for chat in self.channelGroups[channelGroupId].chats:
      if (chat.id == chatId):
        return i
      i.inc()
    return -1
      

  proc updateOrAddChat*(self: Service, chat: ChatDto) =
    self.chats[chat.id] = chat
    self.events.emit(SIGNAL_CHAT_ADDED_OR_UPDATED, ChatArgs(communityId: chat.communityId, chatId: chat.id))

    var channelGroupId = chat.communityId
    if (channelGroupId == ""):
      channelGroupId = singletonInstance.userProfile.getPubKey()
    if (not self.channelGroups.contains(channelGroupId)):
      warn "Unknown community for new channel update", channelGroupId
      return

    let index = self.getChatIndex(channelGroupId, chat.id)
    if (index == -1):
      self.channelGroups[channelGroupId].chats.add(chat)
    else:
      self.channelGroups[channelGroupId].chats[index] = chat

  proc parseChatResponse*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) =
    var chats: seq[ChatDto] = @[]
    var messages: seq[MessageDto] = @[]
    if response.result{"messages"} != nil:
      for jsonMsg in response.result["messages"]:
        messages.add(jsonMsg.toMessageDto)
    if response.result{"chats"} != nil:
      for jsonChat in response.result["chats"]:
        let chat = chat_dto.toChatDto(jsonChat)
        # TODO add the channel back to `chat` when it is refactored
        self.updateOrAddChat(chat)
        chats.add(chat)
    result = (chats, messages)

  proc processMessageUpdateAfterSend*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) =
    result = self.parseChatResponse(response)
    var (chats, messages) = result
    if chats.len == 0 or messages.len == 0:
      error "no chats or messages in the parsed response"
      return

    for msg in messages:
      self.events.emit(SIGNAL_SENDING_SUCCESS, MessageSendingSuccess(message: msg, chat: chats[0]))

  proc processUpdateForTransaction*(self: Service, messageId: string, response: RpcResponse[JsonNode]) =
    var (chats, messages) = self.processMessageUpdateAfterSend(response)
    self.events.emit(SIGNAL_MESSAGE_DELETED, MessageArgs(id: messageId, channel: chats[0].id))

  proc emitUpdate(self: Service, response: RpcResponse[JsonNode]) =
    var (chats, messages) = self.parseChatResponse(response)
    self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(messages: messages, chats: chats))

  proc getAllChats*(self: Service): seq[ChatDto] =
    return toSeq(self.chats.values)

  proc getChatsOfChatTypes*(self: Service, types: seq[chat_dto.ChatType]): seq[ChatDto] =
    return self.getAllChats().filterIt(it.chatType in types)

  proc getChatById*(self: Service, chatId: string, showWarning: bool = true): ChatDto =
    if(not self.chats.contains(chatId)):
      if (showWarning):
        warn "trying to get chat data for an unexisting chat id", chatId
      return

    return self.chats[chatId]

  proc getOneToOneChatNameAndImage*(self: Service, chatId: string):
      tuple[name: string, image: string, largeImage: string] =
    return self.contactService.getContactNameAndImage(chatId)

  proc createChatFromResponse(self: Service, response: RpcResponse[JsonNode]): tuple[chatDto: ChatDto, success: bool] =
    var jsonChat: JsonNode
    if (not response.result.getProp("chat", jsonChat)):
      error "error: response of creating chat doesn't contain created chats"
      result.success = false
      return

    result.chatDto = jsonChat.toChatDto()
    self.updateOrAddChat(result.chatDto)
    result.success = true

  proc createPublicChat*(self: Service, chatId: string): tuple[chatDto: ChatDto, success: bool] =
    try:
      let response = status_chat.createPublicChat(chatId)
      result.chatDto = response.result.toChatDto()
      self.updateOrAddChat(result.chatDto)
      result.success = true
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc createOneToOneChat*(self: Service, communityID: string, chatId: string, ensName: string): tuple[chatDto: ChatDto, success: bool] =
    try:
      if self.hasChannel(chatId):
        # We want to show the chat to the user and for that we activate the chat
        discard status_group_chat.createOneToOneChat(
          communityID,
          chatId,
          ensName=ensName)
        result.success = true
        result.chatDto = self.chats[chatId]
        return

      let response =  status_group_chat.createOneToOneChat(communityID, chatId, ensName)
      result = self.createChatFromResponse(response)
      if result.success:
        self.events.emit(SIGNAL_CHAT_CREATED, CreatedChatArgs(chat: result.chatDto))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc switchToOrCreateOneToOneChat*(self: Service, chatId: string, ensName: string) =
    self.events.emit(SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT, ChatExtArgs(chatId: chatId, ensName: ensName))

  proc leaveChat*(self: Service, chatId: string) =
    try:
      if self.chats.len == 0:
        return
      if(not self.chats.contains(chatId)):
        error "trying to leave chat for an unexisting chat id", chatId
        return

      let chat = self.chats[chatId]
      if chat.chatType == chat_dto.ChatType.PrivateGroupChat:
        let leaveGroupResponse = status_chat.leaveGroupChat(chatId)
        self.emitUpdate(leaveGroupResponse)

      discard status_chat.deactivateChat(chatId)

      var channelGroupId = chat.communityId
      if (channelGroupId == ""):
        channelGroupId = singletonInstance.userProfile.getPubKey()

      self.channelGroups[channelGroupId].chats.delete(self.getChatIndex(channelGroupId, chatId))
      self.chats.del(chatId)
      discard status_chat.deleteMessagesByChatId(chatId)
      self.events.emit(SIGNAL_CHAT_LEFT, ChatArgs(chatId: chatId))
    except Exception as e:
      error "Error deleting channel", chatId, msg = e.msg
      return

  proc sendImages*(self: Service, chatId: string, imagePathsJson: string): string =
    result = ""
    try:
      var images = Json.decode(imagePathsJson, seq[string])

      for imagePath in images.mitems:
        var image = singletonInstance.utils.formatImagePath(imagePath)
        imagePath = image_resizer(image, 2000, TMPDIR)

      let response = status_chat.sendImages(chatId, images)

      for imagePath in images.items:
        removeFile(imagePath)

      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error sending images", msg = e.msg
      result = fmt"Error sending images: {e.msg}"

  proc sendChatMessage*(
    self: Service,
    chatId: string,
    msg: string,
    replyTo: string,
    contentType: int,
    preferredUsername: string = "",
    communityId: string = "") =
    try:
      let allKnownContacts = self.contactService.getContactsByGroup(ContactsGroup.AllKnownContacts)
      let processedMsg = message_common.replaceMentionsWithPubKeys(allKnownContacts, msg)

      let response = status_chat.sendChatMessage(
        chatId,
        processedMsg,
        replyTo,
        contentType,
        preferredUsername,
        communityId) # Only send a community ID for the community invites

      let (chats, messages) = self.processMessageUpdateAfterSend(response)
      if chats.len == 0 or messages.len == 0:
        self.events.emit(SIGNAL_SENDING_FAILED, ChatArgs(chatId: chatId))
    except Exception as e:
      error "Error sending message", msg = e.msg

  proc requestAddressForTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response =  status_chat_commands.requestAddressForTransaction(chatId, fromAddress, amount, address)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting address for transaction", msg = e.msg

  proc requestTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response = status_chat_commands.requestTransaction(chatId, fromAddress, amount, address)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc declineRequestTransaction*(self: Service, messageId: string) =
    try:
      let response = status_chat_commands.declineRequestTransaction(messageId)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc declineRequestAddressForTransaction*(self: Service, messageId: string) =
    try:
      let response = status_chat_commands.declineRequestAddressForTransaction(messageId)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc acceptRequestAddressForTransaction*(self: Service, messageId: string, address: string) =
    try:
      let response = status_chat_commands.acceptRequestAddressForTransaction(messageId, address)
      self.processUpdateForTransaction(messageId, response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc acceptRequestTransaction*(self: Service, transactionHash: string, messageId: string, signature: string) =
    try:
      let response = status_chat_commands.acceptRequestTransaction(transactionHash, messageId, signature)
      discard self.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc muteChat*(self: Service, chatId: string) =
    try:
      if(chatId.len == 0):
        error "error trying to mute chat with an empty id"
        return

      let response = status_chat.muteChat(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId
        error "error while mute chat ", msg
        return

      self.events.emit(SIGNAL_CHAT_MUTED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc unmuteChat*(self: Service, chatId: string) =
    try:
      if(chatId.len == 0):
        error "error trying to unmute chat with an empty id"
        return

      let response = status_chat.unmuteChat(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId
        error "error while unmute chat ", msg
        return

      self.events.emit(SIGNAL_CHAT_UNMUTED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc clearChatHistory*(self: Service, chatId: string) =
    try:
      let response = status_chat.clearChatHistory(chatId)
      if(not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId
        error "error while clearing chat history ", msg
        return

      self.events.emit(SIGNAL_CHAT_HISTORY_CLEARED, ChatArgs(chatId: chatId))
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc addGroupMembers*(self: Service, communityID: string, chatID: string, members: seq[string]) =
    try:
      let response = status_group_chat.addMembers(communityID, chatId, members)
      if (response.error.isNil):
        self.events.emit(SIGNAL_CHAT_MEMBERS_ADDED, ChatMembersAddedArgs(chatId: chatId, ids: members))
    except Exception as e:
      error "error while adding group members: ", msg = e.msg

  proc removeMemberFromGroupChat*(self: Service, communityID: string, chatID: string, member: string) =
    try:
      let response = status_group_chat.removeMember(communityID, chatId, member)
      if (response.error.isNil):
        self.events.emit(SIGNAL_CHAT_MEMBER_REMOVED, ChatMemberRemovedArgs(chatId: chatId, id: member))
    except Exception as e:
      error "error while removing member from group: ", msg = e.msg

  proc removeMembersFromGroupChat*(self: Service, communityID: string, chatID: string, members: seq[string]) =
      try:
        for member in members:
          self.removeMemberFromGroupChat(communityID, chatID, member)
      except Exception as e:
        error "error while removing members from group: ", msg = e.msg

  proc renameGroupChat*(self: Service, communityID: string, chatID: string, name: string) =
    try:
      let response = status_group_chat.renameChat(communityID, chatId, name)
      if (not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId
        error "error while renaming group chat", msg
        return

      var chat = self.chats[chatID]
      chat.name = name
      self.updateOrAddChat(chat)

      self.events.emit(SIGNAL_CHAT_RENAMED, ChatRenameArgs(id: chatId, newName: name))
    except Exception as e:
      error "error while renaming group chat: ", msg = e.msg


  proc makeAdmin*(self: Service, communityID: string, chatID: string, memberId: string) =
    try:
      discard status_group_chat.makeAdmin(communityID, chatId, memberId)
      for member in self.chats[chatId].members.mitems:
        if (member.id == memberId):
          member.admin = true
          self.events.emit(
            SIGNAL_CHAT_MEMBER_UPDATED,
            ChatMemberUpdatedArgs(id: member.id, admin: member.admin, chatId: chatId, joined: member.joined)
          )
          break
    except Exception as e:
      error "error while making user admin: ", msg = e.msg

  proc createGroupChatFromInvitation*(self: Service, groupName: string, chatId: string, adminPK: string): tuple[chatDto: ChatDto, success: bool]  =
    try:
      let response = status_group_chat.createGroupChatFromInvitation(groupName, chatId, adminPK)
      result = self.createChatFromResponse(response)
    except Exception as e:
      error "error while creating group from invitation: ", msg = e.msg

  proc createGroupChat*(self: Service, communityID: string, name: string, members: seq[string]): tuple[chatDto: ChatDto, success: bool] =
    try:
      let response = status_group_chat.createGroupChat(communityID, name, members)
      result = self.createChatFromResponse(response)
      if result.success:
        self.events.emit(SIGNAL_CHAT_CREATED, CreatedChatArgs(chat: result.chatDto))
    except Exception as e:
      error "error while creating group chat", msg = e.msg

  proc getMembers*(self: Service, communityID, chatId: string): seq[ChatMember] =
    try:
      var realChatId = chatId.replace(communityID, "")
      let response = status_chat.getMembers(communityID, realChatId)
      if response.result.kind == JNull:
        # No members. Could be a public chat
        return
      let myPubkey = singletonInstance.userProfile.getPubKey()
      result = @[]
      for (id, memberObj) in response.result.pairs:
        var member = toChatMember(memberObj)
        member.id = id
        # Make yourself as the first result
        if (id == myPubkey):
          result.insert(member)
        else:
          result.add(member)
    except Exception as e:
      error "error while getting members", msg = e.msg, communityID, chatId
