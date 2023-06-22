import NimQml, Tables, json, sequtils, strformat, chronicles, os, std/algorithm, strutils, uuids, base64
import std/[times, os]

import ../../../app/core/tasks/[qt, threadpool]
import ./dto/chat as chat_dto
import ../message/dto/message as message_dto
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
  ChannelGroupsArgs* = ref object of Args
    channelGroups*: seq[ChannelGroupDto]

  ChannelGroupArgs* = ref object of Args
    channelGroup*: ChannelGroupDto

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


# Signals which may be emitted by this service:
const SIGNAL_CHANNEL_GROUPS_LOADED* = "channelGroupsLoaded"
const SIGNAL_CHANNEL_GROUPS_LOADING_FAILED* = "channelGroupsLoadingFailed"
const SIGNAL_CHAT_UPDATE* = "chatUpdate"
const SIGNAL_CHAT_LEFT* = "channelLeft"
const SIGNAL_SENDING_FAILED* = "messageSendingFailed"
const SIGNAL_SENDING_SUCCESS* = "messageSendingSuccess"
const SIGNAL_MESSAGE_DELETED* = "messageDeleted"
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

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    chats: Table[string, ChatDto] # [chat_id, ChatDto]
    channelGroups: OrderedTable[string, ChannelGroupDto] # [chatGroup_id, ChannelGroupDto]
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
    result.channelGroups = initOrderedTable[string, ChannelGroupDto]()

  # Forward declarations
  proc updateOrAddChat*(self: Service, chat: ChatDto)
  proc hydrateChannelGroups*(self: Service, data: JsonNode)
  proc updateOrAddChannelGroup*(self: Service, channelGroup: ChannelGroupDto, isCommunityChannelGroup: bool = false)
  proc processMessageUpdateAfterSend*(self: Service, response: RpcResponse[JsonNode]): (seq[ChatDto], seq[MessageDto])

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling chat updates
      if (receivedData.chats.len > 0):
        var chats: seq[ChatDto] = @[]
        for chatDto in receivedData.chats:
          if (chatDto.active):
            chats.add(chatDto)

            # Handling members update
            if self.chats.hasKey(chatDto.id) and self.chats[chatDto.id].members != chatDto.members:
              self.events.emit(SIGNAL_CHAT_MEMBERS_CHANGED, ChatMembersChangedArgs(chatId: chatDto.id, members: chatDto.members))
            self.updateOrAddChat(chatDto)

        self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(chats: chats))

      if (receivedData.clearedHistories.len > 0):
        for clearedHistoryDto in receivedData.clearedHistories:
          self.events.emit(SIGNAL_CHAT_HISTORY_CLEARED, ChatArgs(chatId: clearedHistoryDto.chatId))

      # Handling community updates
      if (receivedData.communities.len > 0):
        for community in receivedData.communities:
          if community.joined:
            self.updateOrAddChannelGroup(community.toChannelGroupDto(), isCommunityChannelGroup = true)

    self.events.on(SIGNAL_CHAT_REQUEST_UPDATE_AFTER_SEND) do(e: Args):
      var args = RpcResponseArgs(e)
      discard self.processMessageUpdateAfterSend(args.response)

  proc getChannelGroups*(self: Service): seq[ChannelGroupDto] =
    return toSeq(self.channelGroups.values)

  proc loadChannelGroupById*(self: Service, channelGroupId: string) =
    try:
      let response = status_chat.getChannelGroupById(channelGroupId)
      self.hydrateChannelGroups(response.result)
    except Exception as e:
      error "error loadChannelGroupById: ", errorDescription = e.msg

  proc asyncGetChannelGroups*(self: Service) =
    let arg = AsyncGetChannelGroupsTaskArg(
      tptr: cast[ByteAddress](asyncGetChannelGroupsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncGetChannelGroupsResponse",
    )
    self.threadpool.start(arg)

  proc sortPersonnalChatAsFirst[T, D](x, y: (T, D)): int =
    if (x[1].channelGroupType == Personal): return -1
    if (y[1].channelGroupType == Personal): return 1
    return 0

  proc hydrateChannelGroups(self: Service, data: JsonNode) =
    var chats: seq[ChatDto] = @[]
    for (sectionId, section) in data.pairs:
      var channelGroup = section.toChannelGroupDto()
      channelGroup.id = sectionId
      self.channelGroups[sectionId] = channelGroup
      for (chatId, chat) in section["chats"].pairs:
        chats.add(chat.toChatDto())

    # Make the personal channelGroup the first one
    self.channelGroups.sort(sortPersonnalChatAsFirst[string, ChannelGroupDto], SortOrder.Ascending)

    for chat in chats:
      if chat.active and chat.chatType != chat_dto.ChatType.Unknown:
        if chat.chatType == chat_dto.ChatType.Public:
          # Deactivate old public chats
          discard status_chat.deactivateChat(chat.id)
        else:
          self.chats[chat.id] = chat

  proc onAsyncGetChannelGroupsResponse*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson

      if(rpcResponseObj["channelGroups"].kind == JNull):
        raise newException(RpcException, "No channel groups returned")

      self.hydrateChannelGroups(rpcResponseObj["channelGroups"])
      self.events.emit(SIGNAL_CHANNEL_GROUPS_LOADED, ChannelGroupsArgs(channelGroups: self.getChannelGroups()))
    except Exception as e:
      let errDesription = e.msg
      error "error get channel groups: ", errDesription
      self.events.emit(SIGNAL_CHANNEL_GROUPS_LOADING_FAILED, Args())

  proc init*(self: Service) =
    self.doConnect()

    self.asyncGetChannelGroups()

  proc hasChannel*(self: Service, chatId: string): bool =
    self.chats.hasKey(chatId)


  proc getChatIndex*(self: Service, channelGroupId, chatId: string): int =
    var i = 0

    if not self.channelGroups.contains(channelGroupId):
      warn "unknown channel group", channelGroupId
      return -1

    for chat in self.channelGroups[channelGroupId].chats:
      if (chat.id == chatId):
        return i
      i.inc()
    return -1
      
  proc chatsWithCategoryHaveUnreadMessages*(self: Service, communityId: string, categoryId: string): bool =
    if communityId == "" or categoryId == "":
      return false

    if not self.channelGroups.contains(communityId):
      warn "unknown community", communityId
      return false

    for chat in self.channelGroups[communityId].chats:
      if chat.categoryId != categoryId:
        continue
      if chat.unviewedMessagesCount > 0 or chat.unviewedMentionsCount > 0:
        return true
    return false

  proc sectionUnreadMessagesAndMentionsCount*(self: Service, communityId: string):
      tuple[unviewedMessagesCount: int, unviewedMentionsCount: int] =
    if communityId == "":
      return

    if not self.channelGroups.contains(communityId):
      warn "unknown community", communityId
      return

    result.unviewedMentionsCount = 0
    result.unviewedMessagesCount = 0

    for chat in self.channelGroups[communityId].chats:
      result.unviewedMentionsCount += chat.unviewedMentionsCount
      # We count the unread messages if we are unmuted and it's not a mention, we want to show a badge on mentions
      if chat.unviewedMentionsCount == 0 and chat.muted:
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

    var channelGroupId = chat.communityId
    if (channelGroupId == ""):
      channelGroupId = singletonInstance.userProfile.getPubKey()

    if not self.channelGroups.contains(channelGroupId):
      warn "unknown community for new channel update", channelGroupId
      return

    let index = self.getChatIndex(channelGroupId, chat.id)
    if (index == -1):
      self.channelGroups[channelGroupId].chats.add(self.chats[chat.id])
    else:
      self.channelGroups[channelGroupId].chats[index] = self.chats[chat.id]

  proc updateMissingFieldsInCommunityChat(self: Service, channelGroupId: string, newChat: ChatDto): ChatDto =
    
    if not self.channelGroups.contains(channelGroupId):
      warn "unknown channel group", channelGroupId
      return

    var chat = newChat
    for previousChat in self.channelGroups[channelGroupId].chats:
      if previousChat.id != newChat.id:
        continue
      chat.unviewedMessagesCount = previousChat.unviewedMessagesCount
      chat.unviewedMentionsCount = previousChat.unviewedMentionsCount
      chat.muted = previousChat.muted
      chat.highlight = previousChat.highlight
      break
    return chat

  # Community channel groups have less info because they come from community signals
  proc updateOrAddChannelGroup*(self: Service, channelGroup: ChannelGroupDto, isCommunityChannelGroup: bool = false) =
    var newChannelGroup = channelGroup
    if isCommunityChannelGroup and self.channelGroups.contains(channelGroup.id):
      # We need to update missing fields in the chats seq before saving
      let newChats = channelGroup.chats.mapIt(self.updateMissingFieldsInCommunityChat(channelGroup.id, it))
      newChannelGroup.chats = newChats
        
    self.channelGroups[channelGroup.id] = newChannelGroup
    for chat in newChannelGroup.chats:
      self.updateOrAddChat(chat)

  proc getChannelGroupById*(self: Service, channelGroupId: string): ChannelGroupDto =
    if not self.channelGroups.contains(channelGroupId):
      warn "Unknown channel group", channelGroupId
      return
    return self.channelGroups[channelGroupId]

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

    for chat in chats:
      if (chat.active):
        self.events.emit(SIGNAL_CHAT_CREATED, CreatedChatArgs(chat: chat))

    for msg in messages:
      for chat in chats:
        if chat.id == msg.chatId:
          self.events.emit(SIGNAL_SENDING_SUCCESS, MessageSendingSuccess(message: msg, chat: chat))
          break

  proc processUpdateForTransaction*(self: Service, messageId: string, response: RpcResponse[JsonNode]) =
    var (chats, _) = self.processMessageUpdateAfterSend(response)
    self.events.emit(SIGNAL_MESSAGE_DELETED, MessageArgs(id: messageId, channel: chats[0].id))

  proc emitUpdate(self: Service, response: RpcResponse[JsonNode]) =
    var (chats, _) = self.parseChatResponse(response)
    self.events.emit(SIGNAL_CHAT_UPDATE, ChatUpdateArgs(chats: chats))

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

  proc sendImages*(self: Service, chatId: string, imagePathsAndDataJson: string, msg: string, replyTo: string): string =
    result = ""
    try:
      var images = Json.decode(imagePathsAndDataJson, seq[string])
      let base64JPGPrefix = "data:image/jpeg;base64,"
      var imagePaths: seq[string] = @[]

      for imagePathOrSource in images.mitems:
        let imagePath = image_resizer(imagePathOrSource, 2000, TMPDIR)
        if imagePath != "":
          imagePaths.add(imagePath)

      let response = status_chat.sendImages(chatId, imagePaths, msg, replyTo)

      for imagePath in imagePaths:
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

  proc updateGroupChatDetails*(self: Service, communityID: string, chatID: string, name: string, color: string, imageJson: string) =
    try:
      var parsedImage = imageJson.parseJson
      parsedImage["imagePath"] = %singletonInstance.utils.formatImagePath(parsedImage["imagePath"].getStr)
      let response = status_chat.editChat(communityID, chatID, name, color, $parsedImage)
      if (not response.error.isNil):
        let msg = response.error.message & " chatId=" & chatId
        error "error while editing group chat details", msg
        return

      let resultedChat = response.result.toChatDto()

      var chat = self.chats[chatID]
      chat.name = name
      chat.color = color
      chat.icon = resultedChat.icon
      self.updateOrAddChat(chat)

      self.events.emit(SIGNAL_GROUP_CHAT_DETAILS_UPDATED, ChatUpdateDetailsArgs(id: chatID, newName: name, newColor: color, newImage: resultedChat.icon))
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
        var member = toChatMember(memberObj, id)
        # Make yourself as the first result
        if (id == myPubkey):
          result.insert(member)
        else:
          result.add(member)
    except Exception as e:
      error "error while getting members", msg = e.msg, communityID, chatId

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
      self.channelGroups[communityId].channelPermissions.channels[chatId] = checkChannelPermissionsResponse
      self.events.emit(SIGNAL_CHECK_CHANNEL_PERMISSIONS_RESPONSE, CheckChannelPermissionsResponseArgs(communityId: communityId, chatId: chatId, checkChannelPermissionsResponse: checkChannelPermissionsResponse))
    except Exception as e:
      let errMsg = e.msg
      error "error checking all channel permissions: ", errMsg

  proc asyncCheckAllChannelsPermissions*(self: Service, communityId: string) =
    let arg = AsyncCheckAllChannelsPermissionsTaskArg(
      tptr: cast[ByteAddress](asyncCheckAllChannelsPermissionsTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onAsyncCheckAllChannelsPermissionsDone",
      communityId: communityId
    )
    self.threadpool.start(arg)

  proc onAsyncCheckAllChannelsPermissionsDone*(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let error = Json.decode($rpcResponseObj["error"], RpcError)
        error "Error checking all community channel permissions", msg = error.message
        return

      let communityId = rpcResponseObj{"communityId"}.getStr()
      let checkAllChannelsPermissionsResponse = rpcResponseObj["response"]["result"].toCheckAllChannelsPermissionsResponseDto()
      self.channelGroups[communityId].channelPermissions = checkAllChannelsPermissionsResponse
      self.events.emit(SIGNAL_CHECK_ALL_CHANNELS_PERMISSIONS_RESPONSE, CheckAllChannelsPermissionsResponseArgs(communityId: communityId, checkAllChannelsPermissionsResponse: checkAllChannelsPermissionsResponse))
    except Exception as e:
      let errMsg = e.msg
      error "error checking all channels permissions: ", errMsg

