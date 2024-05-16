import NimQml, Tables, json, sequtils, stew/shims/strformat, chronicles, os, strutils, uuids, base64
import std/[times, os]

import ../../../app/core/tasks/[qt, threadpool]
import ./dto/chat as chat_dto
import ../message/dto/message as message_dto
import ../message/dto/link_preview
import ../activity_center/dto/notification as notification_dto
import ../community/dto/community as community_dto
import ../contacts/service as contact_service
import ../../../backend/chat as status_chat
import ../../../backend/communities as status_communities
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
include ../../../app/core/tasks/common
include async_tasks

type
  ChatUpdateArgs* = ref object of Args
    chats*: seq[ChatDto]

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

  ChatUpdateDetailsArgs* = ref object of Args
    id*: string
    newName*: string
    newColor*: string
    newImage*: string

  ChatMembersAddedArgs* = ref object of Args
    chatId*: string
    ids*: seq[string]

  ChatMemberRemovedArgs* = ref object of Args
    chatId*: string
    id*: string

  ChatMembersChangedArgs* = ref object of Args
    chatId*: string
    members*: seq[ChatMember]

  ChatMemberUpdatedArgs* = ref object of Args
    chatId*: string
    id*: string
    role*: MemberRole
    joined*: bool

  RpcResponseArgs* = ref object of Args
    response*: RpcResponse[JsonNode]

  CheckChannelPermissionsResponseArgs* = ref object of Args
    communityId*: string
    chatId*: string
    checkChannelPermissionsResponse*: CheckChannelPermissionsResponseDto

  CheckAllChannelsPermissionsResponseArgs* = ref object of Args
    communityId*: string
    checkAllChannelsPermissionsResponse*: CheckAllChannelsPermissionsResponseDto

  CheckChannelsPermissionsErrorArgs* = ref object of Args
    communityId*: string
    error*: string

# Signals which may be emitted by this service:
const SIGNAL_ACTIVE_CHATS_LOADED* = "activeChatsLoaded"
const SIGNAL_CHATS_LOADING_FAILED* = "chatsLoadingFailed"
const SIGNAL_CHAT_UPDATE* = "chatUpdate"
const SIGNAL_CHAT_LEFT* = "channelLeft"
const SIGNAL_SENDING_FAILED* = "messageSendingFailed"
const SIGNAL_SENDING_SUCCESS* = "messageSendingSuccess"
const SIGNAL_MESSAGE_REMOVE* = "messageRemove"
const SIGNAL_CHAT_MUTED* = "chatMuted"
const SIGNAL_CHAT_UNMUTED* = "chatUnmuted"
const SIGNAL_CHAT_HISTORY_CLEARED* = "chatHistoryCleared"
const SIGNAL_CHAT_RENAMED* = "chatRenamed"
const SIGNAL_GROUP_CHAT_DETAILS_UPDATED* = "groupChatDetailsUpdated"
const SIGNAL_CHAT_MEMBERS_ADDED* = "chatMemberAdded"
const SIGNAL_CHAT_MEMBERS_CHANGED* = "chatMembersChanged"
const SIGNAL_CHAT_MEMBER_REMOVED* = "chatMemberRemoved"
const SIGNAL_CHAT_MEMBER_UPDATED* = "chatMemberUpdated"
const SIGNAL_CHAT_SWITCH_TO_OR_CREATE_1_1_CHAT* = "switchToOrCreateOneToOneChat"
const SIGNAL_CHAT_ADDED_OR_UPDATED* = "chatAddedOrUpdated"
const SIGNAL_CHAT_CREATED* = "chatCreated"
const SIGNAL_CHAT_REQUEST_UPDATE_AFTER_SEND* = "chatRequestUpdateAfterSend"
const SIGNAL_CHECK_CHANNEL_PERMISSIONS_RESPONSE* = "checkChannelPermissionsResponse"
const SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_RESPONSE* = "checkAllChannelsPermissionsResponse"
const SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_FAILED* = "checkAllChannelsPermissionsFailed"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    contactService: contact_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      contactService: contact_service.Service
    ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.contactService = contactService
    result.chats = initTable[string, ChatDto]()

  # Forward declarations
  proc updateOrAddChat*(self: Service, chat: ChatDto)
  proc processMessengerResponse*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto])

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling chat updates
      if (receivedData.chats.len > 0):
        var chats: seq[ChatDto] = @[]
        for chatDto in receivedData.chats:
          if (chatDto.active):
            var updatedChat = chatDto
            # Handling members update for non-community chats
            let isCommunityChat = chatDto.chatType == ChatType.CommunityChat
            if not isCommunityChat and self.chats.hasKey(chatDto.id) and self.chats[chatDto.id].members != chatDto.members:
              self.events.emit(SIGNAL_CHAT_MEMBERS_CHANGED, ChatMembersChangedArgs(chatId: chatDto.id, members: chatDto.members))

            if isCommunityChat and self.chats.hasKey(chatDto.id):
              updatedChat.updateMissingFields(self.chats[chatDto.id])

            chats.add(updatedChat)
            self.updateOrAddChat(updatedChat)

          elif self.chats.hasKey(chatDto.id) and self.chats[chatDto.id].active:
            # We left the chat
            self.events.emit(SIGNAL_CHAT_LEFT, ChatArgs(chatId: chatDto.id))

        self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(chats: chats))

      if (receivedData.clearedHistories.len > 0):
        for clearedHistoryDto in receivedData.clearedHistories:
          self.events.emit(SIGNAL_CHAT_HISTORY_CLEARED, ChatArgs(chatId: clearedHistoryDto.chatId))

    self.events.on(SIGNAL_CHAT_REQUEST_UPDATE_AFTER_SEND) do(e: Args):
      var args = RpcResponseArgs(e)
      discard self.processMessengerResponse(args.response)

  proc asyncGetActiveChat*(self: Service) =
    let arg = AsyncGetActiveChatsTaskArg(
      tptr: cast[ByteAddress](asyncGetActiveChatsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncGetActiveChatsResponse",
    )
    self.threadpool.start(arg)

  proc hydrateChats(self: Service, data: JsonNode) =
    for chatJson in data:
      let chat = chatJson.toChatDto()
      if chat.active and chat.chatType != chat_dto.ChatType.Unknown:
          self.chats[chat.id] = chat

  proc onAsyncGetActiveChatsResponse*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson

      if (rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != ""):
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)

      if rpcResponseObj["chats"].kind != JNull:
        self.hydrateChats(rpcResponseObj["chats"])

      self.events.emit(SIGNAL_ACTIVE_CHATS_LOADED, Args())
    except Exception as e:
      let errDesription = e.msg
      error "error get active chats: ", errDesription
      self.events.emit(SIGNAL_CHATS_LOADING_FAILED, Args())

  proc init*(self: Service) =
    self.doConnect()

    self.asyncGetActiveChat()

  proc hasChannel*(self: Service, chatId: string): bool =
    self.chats.hasKey(chatId)

  proc sectionUnreadMessagesAndMentionsCount*(self: Service, sectionId: string, sectionIsMuted: bool):
      tuple[unviewedMessagesCount: int, unviewedMentionsCount: int] =

    result.unviewedMentionsCount = 0
    result.unviewedMessagesCount = 0

    let myPubKey = singletonInstance.userProfile.getPubKey()
    var sectionIdToFind = sectionId
    if sectionId == myPubKey:
      # If the section is the personal one (ID == pubKey), then we set the sectionIdToFind to ""
      # because personal chats have communityId == ""
      sectionIdToFind = ""
    for _, chat in self.chats:
      if chat.communityId != sectionIdToFind:
        continue
      result.unviewedMentionsCount += chat.unviewedMentionsCount
      # We count the unread messages if we are unmuted and it's not a mention, we want to show a badge on mentions
      if chat.unviewedMentionsCount == 0 and (chat.muted or sectionIsMuted):
        continue
      if chat.unviewedMessagesCount > 0:
        result.unviewedMessagesCount = result.unviewedMessagesCount + chat.unviewedMessagesCount

  proc updateOrAddChat*(self: Service, chat: ChatDto) =
    # status-go doesn't seem to preserve categoryIDs from chat
    # objects received via new messages. So we rely on what we
    # have in memory.

    if chat.id == "":
      return
    var categoryId = ""
    if self.chats.hasKey(chat.id):
      categoryId = self.chats[chat.id].categoryId
    self.chats[chat.id] = chat
    self.chats[chat.id].categoryId = categoryId
    self.events.emit(SIGNAL_CHAT_ADDED_OR_UPDATED, ChatArgs(communityId: chat.communityId, chatId: chat.id))

  proc updateChannelMembers*(self: Service, channel: ChatDto) =
    if not self.chats.hasKey(channel.id):
      return

    var chat = self.chats[channel.id]
    chat.members = channel.members
    self.updateOrAddChat(chat)
    self.events.emit(SIGNAL_CHAT_MEMBERS_CHANGED, ChatMembersChangedArgs(chatId: chat.id, members: chat.members))

  proc parseChatResponse*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) =
    var chats: seq[ChatDto] = @[]
    var messages: seq[MessageDto] = @[]
    let errDesription = response.result{"error"}.getStr
    if errDesription != "":
      error "Error in parseGroupChatResponse: ", errDesription
    else:
      if response.result{"messages"} != nil:
        for jsonMsg in response.result["messages"]:
          messages.add(jsonMsg.toMessageDto)
      if response.result{"chats"} != nil:
        for jsonChat in response.result["chats"]:
          let chat = chat_dto.toChatDto(jsonChat)
          # TODO add the channel back to `chat` when it is refactored
          self.updateOrAddChat(chat)
          chats.add(chat)
    return (chats, messages)

  proc signalChatsAndMessagesUpdates*(self: Service, chats: seq[ChatDto], messages: seq[MessageDto]) =
    if chats.len == 0 or messages.len == 0:
      error "no chats or messages in the parsed response"
      return
    for chat in chats:
      if (chat.active):
        self.events.emit(SIGNAL_CHAT_CREATED, CreatedChatArgs(chat: chat))
    var chatMap: Table[string, ChatDto] = initTable[string, ChatDto]()
    for chat in chats:
      chatMap[chat.id] = chat
    for msg in messages:
      if chatMap.hasKey(msg.chatId):
        let chat = chatMap[msg.chatId]
        self.events.emit(SIGNAL_SENDING_SUCCESS, MessageSendingSuccess(message: msg, chat: chat))

  proc processMessengerResponse*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto]) =
    result = self.parseChatResponse(response)
    var (chats, messages) = result
    self.signalChatsAndMessagesUpdates(chats, messages)

  proc processGroupChatResponse*(self: Service, response: RpcResponse[JsonNode]) =
    proc parseGroupChatResponse(response: RpcResponse[JsonNode]): (ChatDto, seq[MessageDto], string) =
      var chat: ChatDto
      var messages: seq[MessageDto] = @[]

      let errorDescription = response.result{"error"}.getStr

      if response.result{"chat"} != nil:
        chat = chat_dto.toChatDto(response.result["chat"])
      if response.result{"messages"} != nil:
        for jsonMsg in response.result["messages"]:
          messages.add(jsonMsg.toMessageDto)
      return (chat, messages, errorDescription)

    var (chat, messages, errorDescription) = parseGroupChatResponse(response)
    if errorDescription != "":
      error "Received an error in the ProcessGroupChatResponse: ", errorDescription
    else:
      self.updateOrAddChat(chat)
      self.signalChatsAndMessagesUpdates(@[chat], messages)

  proc processUpdateForTransaction*(self: Service, messageId: string, response: RpcResponse[JsonNode]) =
    var (chats, _) = self.processMessengerResponse(response)
    # TODO: Signal is not handled anywhere
    self.events.emit(SIGNAL_MESSAGE_REMOVE, MessageArgs(id: messageId, channel: chats[0].id))

  proc emitUpdate(self: Service, response: RpcResponse[JsonNode]) =
    var (chats, _) = self.parseChatResponse(response)
    self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(chats: chats))

  proc getAllChats*(self: Service): seq[ChatDto] =
    return toSeq(self.chats.values)

  proc getChatsOfChatTypes*(self: Service, types: seq[chat_dto.ChatType]): seq[ChatDto] =
    return self.getAllChats().filterIt(it.chatType in types)

  proc getChatsForPersonalSection*(self: Service): seq[ChatDto] =
    return self.getAllChats().filterIt(it.isActivePersonalChat())

  proc getChatsForCommunity*(self: Service, communityId: string): seq[ChatDto] =
    return self.getAllChats().filterIt(it.communityId == communityId)

  proc getChatById*(self: Service, chatId: string, showWarning: bool = true): ChatDto =
    if(not self.chats.contains(chatId)):
      if (showWarning):
        warn "trying to get chat data for an unexisting chat id", chatId
      return

    return self.chats[chatId]

  proc getChatsByIds*(self: Service, chatIds: seq[string]): seq[ChatDto] =
    if chatIds.len == 0:
      return
    return self.getAllChats().filterIt(it.id in chatIds)

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

      discard status_chat.deactivateChat(chatId, preserveHistory = chat.chatType == chat_dto.ChatType.OneToOne)

      self.chats.del(chatId)
      self.events.emit(SIGNAL_CHAT_LEFT, ChatArgs(chatId: chatId))
    except Exception as e:
      error "Error deleting channel", chatId, msg = e.msg
      return

  proc sendImages*(self: Service,
                   chatId: string,
                   imagePathsAndDataJson: string,
                   msg: string,
                   replyTo: string,
                   preferredUsername: string = "",
                   linkPreviews: seq[LinkPreview] = @[]): string =
    result = ""
    try:
      var images = Json.decode(imagePathsAndDataJson, seq[string])
      let base64JPGPrefix = "data:image/jpeg;base64,"
      var imagePaths: seq[string] = @[]

      for imagePathOrSource in images.mitems:
        let imagePath = image_resizer(imagePathOrSource, 2000, TMPDIR)
        if imagePath != "":
          imagePaths.add(imagePath)

      let response = status_chat.sendImages(chatId, imagePaths, msg, replyTo, preferredUsername, linkPreviews)

      for imagePath in imagePaths:
        removeFile(imagePath)

      discard self.processMessengerResponse(response)
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
    linkPreviews: seq[LinkPreview] = @[],
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
        linkPreviews,
        communityId) # Only send a community ID for the community invites

      let (chats, messages) = self.processMessengerResponse(response)
      if chats.len == 0 or messages.len == 0:
        self.events.emit(SIGNAL_SENDING_FAILED, ChatArgs(chatId: chatId))
    except Exception as e:
      error "Error sending message", msg = e.msg

  proc requestAddressForTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response =  status_chat_commands.requestAddressForTransaction(chatId, fromAddress, amount, address)
      discard self.processMessengerResponse(response)
    except Exception as e:
      error "Error requesting address for transaction", msg = e.msg

  proc requestTransaction*(self: Service, chatId: string, fromAddress: string, amount: string, tokenAddress: string) =
    try:
      let address = if (tokenAddress == ZERO_ADDRESS): "" else: tokenAddress
      let response = status_chat_commands.requestTransaction(chatId, fromAddress, amount, address)
      discard self.processMessengerResponse(response)
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
      discard self.processMessengerResponse(response)
    except Exception as e:
      error "Error requesting transaction", msg = e.msg

  proc muteChat*(self: Service, chatId: string, interval: int) =
    try:
      if(chatId.len == 0):
        error "error trying to mute chat with an empty id"
        return

      let response = status_chat.muteChat(chatId, interval)
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
        self.processGroupChatResponse(response)
    except Exception as e:
      error "error while adding group members: ", msg = e.msg

  proc removeMemberFromGroupChat*(self: Service, communityID: string, chatID: string, member: string) =
    try:
      let response = status_group_chat.removeMember(communityID, chatId, member)
      if (response.error.isNil):
        self.events.emit(SIGNAL_CHAT_MEMBER_REMOVED, ChatMemberRemovedArgs(chatId: chatId, id: member))
        self.processGroupChatResponse(response)
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

  proc updateGroupChatDetails*(self: Service, communityID: string, chatID: string, name: string, color: string, imageJson: string) =
    try:
      var parsedImage = imageJson.parseJson
      parsedImage["imagePath"] = %singletonInstance.utils.formatImagePath(parsedImage["imagePath"].getStr)
      let response = status_chat.editChat(communityID, chatID, name, color, $parsedImage)

      discard self.processMessengerResponse(response)

      let chat = self.chats[chatID]
      self.events.emit(SIGNAL_GROUP_CHAT_DETAILS_UPDATED, ChatUpdateDetailsArgs(id: chatID, newName: name, newColor: color, newImage: chat.icon))
    except Exception as e:
      error "error while updating group chat: ", msg = e.msg

  proc makeAdmin*(self: Service, communityID: string, chatID: string, memberId: string) =
    try:
      discard status_group_chat.makeAdmin(communityID, chatId, memberId)
      for member in self.chats[chatId].members.mitems:
        if (member.id == memberId):
          member.role = MemberRole.Admin
          self.events.emit(
            SIGNAL_CHAT_MEMBER_UPDATED,
            ChatMemberUpdatedArgs(id: member.id, role: member.role, chatId: chatId, joined: member.joined)
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

  proc updateUnreadMessage*(self: Service, chatID: string, messagesCount:int, messagesWithMentionsCount:int) =
    var chat = self.getChatById(chatID)
    if chat.id == "":
      return

    chat.unviewedMessagesCount = messagesCount
    chat.unviewedMentionsCount = messagesWithMentionsCount
    self.updateOrAddChat(chat)

  proc updateUnreadMessagesAndMentions*(self: Service, chatID: string, markAllAsRead: bool, markAsReadCount: int, markAsReadMentionsCount: int) =
    var chat = self.getChatById(chatID)
    if chat.id == "":
      return
    if markAllAsRead:
      chat.unviewedMessagesCount = 0
      chat.unviewedMentionsCount = 0
    else:
      chat.unviewedMessagesCount = max(0, chat.unviewedMessagesCount - markAsReadCount)
      chat.unviewedMentionsCount = max(0, chat.unviewedMentionsCount - markAsReadMentionsCount)
    self.updateOrAddChat(chat)

  proc asyncCheckChannelPermissions*(self: Service, communityId: string, chatId: string) =
    let arg = AsyncCheckChannelPermissionsTaskArg(
      tptr: cast[ByteAddress](asyncCheckChannelPermissionsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncCheckChannelPermissionsDone",
      communityId: communityId,
      chatId: chatId
    )
    self.threadpool.start(arg)

  proc onAsyncCheckChannelPermissionsDone*(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "Error checking community channel permissions", msg = error.message
        return

      let communityId = rpcResponseObj{"communityId"}.getStr()
      let chatId = rpcResponseObj{"chatId"}.getStr()
      let checkChannelPermissionsResponse = rpcResponseObj["response"]["result"].toCheckChannelPermissionsResponseDto()

      self.events.emit(SIGNAL_CHECK_CHANNEL_PERMISSIONS_RESPONSE, CheckChannelPermissionsResponseArgs(communityId: communityId, chatId: chatId, checkChannelPermissionsResponse: checkChannelPermissionsResponse))
    except Exception as e:
      let errMsg = e.msg
      error "error checking all channel permissions: ", errMsg

  proc asyncCheckAllChannelsPermissions*(self: Service, communityId: string, addresses: seq[string]) =
    let arg = AsyncCheckAllChannelsPermissionsTaskArg(
      tptr: cast[ByteAddress](asyncCheckAllChannelsPermissionsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncCheckAllChannelsPermissionsDone",
      communityId: communityId,
      addresses: addresses,
    )
    self.threadpool.start(arg)

  proc onAsyncCheckAllChannelsPermissionsDone*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson
    let communityId = rpcResponseObj{"communityId"}.getStr()
    try:
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj["error"].getStr)

      if rpcResponseObj["response"]{"error"}.kind != JNull:
        let error = Json.decode(rpcResponseObj["response"]["error"].getStr, RpcError)
        raise newException(RpcException, error.message)

      let checkAllChannelsPermissionsResponse = rpcResponseObj["response"]["result"].toCheckAllChannelsPermissionsResponseDto()
      # TODO save it
      self.events.emit(SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_RESPONSE, CheckAllChannelsPermissionsResponseArgs(communityId: communityId, checkAllChannelsPermissionsResponse: checkAllChannelsPermissionsResponse))
    except Exception as e:
      let errMsg = e.msg
      error "error checking all channels permissions: ", errMsg
      self.events.emit(SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_FAILED, CheckChannelsPermissionsErrorArgs(
        communityId: communityId,
        error: errMsg,
      ))
