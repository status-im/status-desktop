import NimQml, Tables, json, sequtils, std/algorithm, strformat, strutils, chronicles, json_serialization

import ./dto/community as community_dto

import ../chat/service as chat_service

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../backend/communities as status_go

export community_dto

logScope:
  topics = "community-service"

include ../../common/json_utils

type
  CommunityArgs* = ref object of Args
    community*: CommunityDto
    error*: string

  CommunitiesArgs* = ref object of Args
    communities*: seq[CommunityDto]

  CommunityChatArgs* = ref object of Args
    chat*: ChatDto

  CommunityIdArgs* = ref object of Args
    communityId*: string

  CommunityChatIdArgs* = ref object of Args
    communityId*: string
    chatId*: string

  CommunityRequestArgs* = ref object of Args
    communityRequest*: CommunityMembershipRequestDto

  CommunityChatOrderArgs* = ref object of Args
    communityId*: string
    chatId*: string
    categoryId*: string
    position*: int

  CommunityCategoryArgs* = ref object of Args
    communityId*: string
    category*: Category
    chats*: seq[ChatDto]

  CommunityMemberArgs* = ref object of Args
    communityId*: string
    pubKey*: string

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_JOINED* = "communityJoined"
const SIGNAL_COMMUNITY_MY_REQUEST_ADDED* = "communityMyRequestAdded"
const SIGNAL_COMMUNITY_LEFT* = "communityLeft"
const SIGNAL_COMMUNITY_CREATED* = "communityCreated"
const SIGNAL_COMMUNITY_IMPORTED* = "communityImported"
const SIGNAL_COMMUNITY_EDITED* = "communityEdited"
const SIGNAL_COMMUNITIES_UPDATE* = "communityUpdated"
const SIGNAL_COMMUNITY_CHANNEL_CREATED* = "communityChannelCreated"
const SIGNAL_COMMUNITY_CHANNEL_EDITED* = "communityChannelEdited"
const SIGNAL_COMMUNITY_CHANNEL_REORDERED* = "communityChannelReordered"
const SIGNAL_COMMUNITY_CHANNEL_DELETED* = "communityChannelDeleted"
const SIGNAL_COMMUNITY_CATEGORY_CREATED* = "communityCategoryCreated"
const SIGNAL_COMMUNITY_CATEGORY_EDITED* = "communityCategoryEdited"
const SIGNAL_COMMUNITY_CATEGORY_DELETED* = "communityCategoryDeleted"
const SIGNAL_COMMUNITY_MEMBER_APPROVED* = "communityMemberApproved"

QtObject:
  type 
    Service* = ref object of QObject
      events: EventEmitter
      chatService: chat_service.Service
      joinedCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]
      allCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]
      myCommunityRequests*: seq[CommunityMembershipRequestDto]

  # Forward declaration
  proc loadAllCommunities(self: Service): seq[CommunityDto]
  proc loadJoinedComunities(self: Service): seq[CommunityDto]
  proc loadMyPendingRequestsToJoin*(self: Service)
  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto])
  proc pendingRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto]

  proc delete*(self: Service) =
    discard

  proc newService*(events: EventEmitter, chatService: chat_service.Service): Service =
    result = Service()
    result.events = events
    result.chatService = chatService
    result.joinedCommunities = initTable[string, CommunityDto]()
    result.allCommunities = initTable[string, CommunityDto]()
    result.myCommunityRequests = @[]

  proc doConnect(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling community updates
      if (receivedData.communities.len > 0):
        # Channel added removed is notified in the chats param
        self.handleCommunityUpdates(receivedData.communities, receivedData.chats)

      # Handling membership requests
      if(receivedData.membershipRequests.len > 0):
        for membershipRequest in receivedData.membershipRequests:
          if (not self.joinedCommunities.contains(membershipRequest.communityId)):
            error "Received a membership request for an unknown community", communityId=membershipRequest.communityId
            continue
          var community = self.joinedCommunities[membershipRequest.communityId]
          community.pendingRequestsToJoin.add(membershipRequest)
          self.joinedCommunities[membershipRequest.communityId] = community
          self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))

  proc mapChatToChatDto(chat: Chat, communityId: string): ChatDto =
    result = ChatDto()
    result.id = chat.id
    result.communityId = communityId
    result.name = chat.name
    result.chatType = ChatType.CommunityChat
    result.color = chat.color
    result.emoji = chat.emoji
    result.description = chat.description
    result.canPost = chat.canPost
    result.position = chat.position
    result.categoryId = chat.categoryId
    result.communityId = communityId

  proc updateMissingFields(chatDto: var ChatDto, chat: Chat) =
    # This proc sets fields of `chatDto` which are available only for comminity channels.
    chatDto.position = chat.position
    chatDto.canPost = chat.canPost
    chatDto.categoryId = chat.categoryId

  proc findChatById(id: string, chats: seq[ChatDto]): ChatDto =
    for chat in chats:
      if(chat.id == id):
        return chat

  proc findIndexById(id: string, chats: seq[Chat]): int =
    var idx = -1
    for chat in chats:
      inc idx
      if(chat.id == id):
        return idx
    return -1

  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto]) =
    let community = communities[0]
    var sortingOrderChanged = false
    if(not self.joinedCommunities.hasKey(community.id)):
      error "error: community doesn't exist"
      return

    let prev_community = self.joinedCommunities[community.id]
    self.joinedCommunities[community.id] = community

    # channel was added
    if(community.chats.len > prev_community.chats.len):
      for chat in community.chats:
        if findIndexById(chat.id, prev_community.chats) == -1:
          let chatFullId = community.id & chat.id
          var createdChat = findChatById(chatFullId, updatedChats)
          createdChat.updateMissingFields(chat)
          self.chatService.updateOrAddChat(createdChat) # we have to update chats stored in the chat service.

          let data = CommunityChatArgs(chat: createdChat)
          self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, data)

    # channel was removed
    elif(community.chats.len < prev_community.chats.len):
      for prv_chat in prev_community.chats:
        if findIndexById(prv_chat.id, community.chats) == -1:
          self.events.emit(SIGNAL_COMMUNITY_CHANNEL_DELETED, CommunityChatIdArgs(communityId: community.id, 
          chatId: community.id&prv_chat.id))
    # some property has changed
    else:
      for chat in community.chats:
        # id is present
        if findIndexById(chat.id, prev_community.chats) == -1:
          continue
        # but something is different
        for prev_chat in prev_community.chats:

          # Category changes not handled yet
          #if(chat.id == prev_chat.id and chat.categoryId != prev_chat.categoryId):

          # Handle position changes
          if(chat.id == prev_chat.id and chat.position != prev_chat.position):
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED, CommunityChatOrderArgs(communityId: community.id, 
            chatId: community.id&chat.id, categoryId: chat.categoryId, position: chat.position))

          # Handle name/description changes
          if(chat.id == prev_chat.id and (chat.name != prev_chat.name or chat.description != prev_chat.description)):
            let chatFullId = community.id & chat.id
            var updatedChat = findChatById(chatFullId, updatedChats)
            updatedChat.updateMissingFields(chat)
            self.chatService.updateOrAddChat(updatedChat) # we have to update chats stored in the chat service.
            
            let data = CommunityChatArgs(chat: updatedChat)
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, data)

    self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: communities))

  proc init*(self: Service) =
    self.doConnect()

    try:
      let joinedCommunities = self.loadJoinedComunities()
      for community in joinedCommunities:
        self.joinedCommunities[community.id] = community
        if (community.admin):
          self.joinedCommunities[community.id].pendingRequestsToJoin = self.pendingRequestsToJoinForCommunity(community.id)

      let allCommunities = self.loadAllCommunities()
      for community in allCommunities:
        self.allCommunities[community.id] = community

      self.loadMyPendingRequestsToJoin()

    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return

  proc loadAllCommunities(self: Service): seq[CommunityDto] =
    let response = status_go.getAllCommunities()
    return parseCommunities(response)

  proc loadJoinedComunities(self: Service): seq[CommunityDto] =
    let response = status_go.getJoinedComunities()
    return parseCommunities(response)

  proc getJoinedCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.joinedCommunities.values)

  proc getAllCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.allCommunities.values)

  proc getCommunityById*(self: Service, communityId: string): CommunityDto =
    if(not self.joinedCommunities.hasKey(communityId)):
      error "error: requested community doesn't exists"
      return

    return self.joinedCommunities[communityId]

  proc getCommunityIds*(self: Service): seq[string] =
    return toSeq(self.joinedCommunities.keys)

  proc sortAsc[T](t1, t2: T): int =
    if(t1.position > t2.position):
      return 1
    elif (t1.position < t2.position):
      return -1
    else:
      return 0

  proc sortDesc[T](t1, t2: T): int =
    if(t1.position < t2.position):
      return 1
    elif (t1.position > t2.position):
      return -1
    else:
      return 0

  proc getCategories*(self: Service, communityId: string, order: SortOrder = SortOrder.Ascending): seq[Category] =
    if(not self.joinedCommunities.contains(communityId)):
      error "trying to get community categories for an unexisting community id"
      return

    result = self.joinedCommunities[communityId].categories
    if(order == SortOrder.Ascending):
      result.sort(sortAsc[Category])
    else:
      result.sort(sortDesc[Category])

  proc getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[Chat] =
    ## By default returns chats which don't belong to any category, for passed `communityId`.
    ## If `categoryId` is set then only chats belonging to that category for passed `communityId` will be returned.
    ## Returned chats are sorted by position following set `order` parameter.
    if(not self.joinedCommunities.contains(communityId)):
      error "trying to get community chats for an unexisting community id"
      return

    for chat in self.joinedCommunities[communityId].chats:
      if(chat.categoryId != categoryId):
        continue

      result.add(chat)

    if(order == SortOrder.Ascending):
      result.sort(sortAsc[Chat])
    else:
      result.sort(sortDesc[Chat])

  proc getAllChats*(self: Service, communityId: string, order = SortOrder.Ascending): seq[Chat] =
    ## Returns all chats belonging to the community with passed `communityId`, sorted by position.
    ## Returned chats are sorted by position following set `order` parameter.
    if(not self.joinedCommunities.contains(communityId)):
      error "trying to get all community chats for an unexisting community id"
      return

    result = self.joinedCommunities[communityId].chats

    if(order == SortOrder.Ascending):
      result.sort(sortAsc[Chat])
    else:
      result.sort(sortDesc[Chat])

  proc isUserMemberOfCommunity*(self: Service, communityId: string): bool =
    if(not self.allCommunities.contains(communityId)):
      return false
    return self.allCommunities[communityId].joined and self.allCommunities[communityId].isMember

  proc userCanJoin*(self: Service, communityId: string): bool =
    if(not self.allCommunities.contains(communityId)):
      return false
    return self.allCommunities[communityId].canJoin

  proc joinCommunity*(self: Service, communityId: string): string =
    result = ""
    try:
      if (not self.userCanJoin(communityId) or self.isUserMemberOfCommunity(communityId)):
        return
      discard status_go.joinCommunity(communityId)
      var community = self.allCommunities[communityId]
      self.joinedCommunities[communityId] = community

      for k, chat in community.chats:
        let fullChatId = communityId & chat.id
        let currentChat =  self.chatService.getChatById(fullChatId, showWarning = false)
        echo currentChat
        if (currentChat.id != ""):
          # The chat service already knows that about that chat
          continue
        var chatDto = mapChatToChatDto(chat, communityId)
        chatDto.id = fullChatId
        # TODO find a way to populate missing infos like the color
        self.chatService.updateOrAddChat(chatDto)

      self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: community))
    except Exception as e:
      error "Error joining the community", msg = e.msg
      result = fmt"Error joining the community: {e.msg}"

  proc requestToJoinCommunity*(self: Service, communityId: string, ensName: string) =
    try:
      let response = status_go.requestToJoinCommunity(communityId, ensName)

      if response.result{"requestsToJoinCommunity"} != nil and response.result{"requestsToJoinCommunity"}.kind != JNull:
        for jsonCommunityReqest in response.result["requestsToJoinCommunity"]:
          let communityRequest = jsonCommunityReqest.toCommunityMembershipRequestDto()
          self.myCommunityRequests.add(communityRequest)
          self.events.emit(SIGNAL_COMMUNITY_MY_REQUEST_ADDED, CommunityRequestArgs(communityRequest: communityRequest))
    except Exception as e:
      error "Error requesting to join the community", msg = e.msg, communityId, ensName

  proc loadMyPendingRequestsToJoin*(self: Service) =
    try:
      let response = status_go.myPendingRequestsToJoin()

      if response.result.kind != JNull:
        for jsonCommunityReqest in response.result:
          let communityRequest = jsonCommunityReqest.toCommunityMembershipRequestDto()
          self.myCommunityRequests.add(communityRequest)
          self.events.emit(SIGNAL_COMMUNITY_MY_REQUEST_ADDED, CommunityRequestArgs(communityRequest: communityRequest))
    except Exception as e:
      error "Error fetching my community requests", msg = e.msg

  proc pendingRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto] =
    try:
      let response = status_go.pendingRequestsToJoinForCommunity(communityId)

      result = @[]
      if response.result.kind != JNull:
        for jsonCommunityReqest in response.result:
          result.add(jsonCommunityReqest.toCommunityMembershipRequestDto())
    except Exception as e:
      error "Error fetching community requests", msg = e.msg

  proc leaveCommunity*(self: Service, communityId: string) =
    try:
      let response = status_go.leaveCommunity(communityId)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error leaving community: " & error.message)

      if response.result == nil or response.result.kind == JNull:
        error "error: ", methodName="leaveCommunity", errDesription = "result is nil"
        return

      # Update community so that joined, member list and isMember are updated
      let updatedCommunity = response.result["communities"][0].toCommunityDto()
      self.allCommunities[communityId] = updatedCommunity
      self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[updatedCommunity]))

      # remove this from the joinedCommunities list
      self.joinedCommunities.del(communityId)
      self.events.emit(SIGNAL_COMMUNITY_LEFT, CommunityIdArgs(communityId: communityId))

    except Exception as e:
      error "Error leaving community", msg = e.msg, communityId

  proc createCommunity*(
      self: Service,
      name: string,
      description: string,
      access: int,
      ensOnly: bool,
      color: string,
      imageUrl: string,
      aX: int, aY: int, bX: int, bY: int) =
    try:
      var image = singletonInstance.utils.formatImagePath(imageUrl)
      let response = status_go.createCommunity(
        name,
        description,
        access,
        ensOnly,
        color,
        image,
        aX, aY, bX, bY)
      
      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        let community = response.result["communities"][0].toCommunityDto()

        # add this to the joinedCommunities list
        self.joinedCommunities[community.id] = community

        self.events.emit(SIGNAL_COMMUNITY_CREATED, CommunityArgs(community: community))
    except Exception as e:
      error "Error creating community", msg = e.msg

  proc editCommunity*(
      self: Service,
      id: string,
      name: string,
      description: string,
      access: int,
      ensOnly: bool,
      color: string,
      imageUrl: string,
      aX: int, aY: int, bX: int, bY: int) =
    try:
      var image = singletonInstance.utils.formatImagePath(imageUrl)
      let response = status_go.editCommunity(
        id,
        name,
        description,
        access,
        ensOnly,
        color,
        image,
        aX, aY, bX, bY)
      
      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error editing community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        let community = response.result["communities"][0].toCommunityDto()
        self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))
    except Exception as e:
      error "Error editing community", msg = e.msg

  proc createCommunityChannel*(
      self: Service,
      communityId: string,
      name: string,
      description: string,
      categoryId: string) =
    try:
      let response = status_go.createCommunityChannel(communityId, name, description, categoryId)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community channel: " & error.message)
      
      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", methodName="createCommunityChannel"

    except Exception as e:
      error "Error creating community channel", msg = e.msg, communityId, name, description, methodName="createCommunityChannel"

  proc editCommunityChannel*(
      self: Service,
      communityId: string,
      channelId: string,
      name: string,
      description: string,
      categoryId: string,
      position: int) =
    try:
      let response = status_go.editCommunityChannel(
        communityId,
        channelId,
        name,
        description,
        categoryId,
        position)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error editing community channel: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", methodName="editCommunityChannel"

    except Exception as e:
      error "Error editing community channel", msg = e.msg, communityId, channelId, methodName="editCommunityChannel"

  proc reorderCommunityChat*(
      self: Service,
      communityId: string,
      categoryId: string,
      chatId: string,
      position: int) =
    try:
      let response = status_go.reorderCommunityChat(
        communityId,
        categoryId,
        chatId,
        position)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error reordering community channel: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", methodName="reorderCommunityChat"

    except Exception as e:
      error "Error reordering community channel", msg = e.msg, communityId, chatId, position, methodName="reorderCommunityChat"

  proc deleteCommunityChat*(self: Service, communityId: string, chatId: string) =
    try:
      let response = status_go.deleteCommunityChat(communityId, chatId)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error deleting community chat: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", methodName="deleteCommunityChat"

    except Exception as e:
      error "Error deleting community channel", msg = e.msg, communityId, chatId, methodName="deleteCommunityChat"

  proc createCommunityCategory*(
      self: Service,
      communityId: string,
      name: string,
      channels: seq[string]) =
    try:
      let response = status_go.createCommunityCategory(communityId, name, channels)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community category: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        var chats: seq[ChatDto] = @[]
        for chatId, v in response.result["communityChanges"].getElems()[0]["chatsModified"].pairs():
          let idx = findIndexById(chatId, self.joinedCommunities[communityId].chats)
          if idx > -1:
            self.joinedCommunities[communityId].chats[idx].categoryId = v["CategoryModified"].getStr()
            self.joinedCommunities[communityId].chats[idx].position = v["PositionModified"].getInt()
            if self.joinedCommunities[communityId].chats[idx].categoryId.len > 0:
              let fullChatId = communityId & chatId
              var chatDetails = self.chatService.getChatById(fullChatId) # we are free to do this cause channel must be created before we add it to a category
              chatDetails.updateMissingFields(self.joinedCommunities[communityId].chats[idx])
              self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
              chats.add(chatDetails)
        for k, v in response.result["communityChanges"].getElems()[0]["categoriesAdded"].pairs():
          let category = v.toCategory()
          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_CREATED,
            CommunityCategoryArgs(communityId: communityId, category: category, chats: chats))
          
    except Exception as e:
      error "Error creating community category", msg = e.msg, communityId, name

  proc editCommunityCategory*(
      self: Service,
      communityId: string,
      categoryId: string,
      name: string,
      channels: seq[string]) =
    try:
      let response = status_go.editCommunityCategory(communityId, categoryId, name, channels)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community category: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        for k, v in response.result["communityChanges"].getElems()[0]["categoriesModified"].pairs():
          let category = v.toCategory()
          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_EDITED,
            CommunityCategoryArgs(communityId: communityId, category: category #[, channels: channels]#)) # TODO: add channels
    except Exception as e:
      error "Error creating community category", msg = e.msg, communityId, name

  proc deleteCommunityCategory*(self: Service, communityId: string, categoryId: string) =
    try:
      let response = status_go.deleteCommunityCategory(communityId, categoryId)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error deleting community category: " & error.message)

      self.events.emit(SIGNAL_COMMUNITY_CATEGORY_DELETED,
        CommunityCategoryArgs(
          communityId: communityId,
          category: Category(id: categoryId)
        )
      )
    except Exception as e:
      error "Error deleting community category", msg = e.msg, communityId, categoryId

  proc requestCommunityInfo*(self: Service, communityId: string) =
    try:
      let response = status_go.requestCommunityInfo(communityId)
      if (response.error != nil):
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, fmt"Error requesting community info: {error.message}")
    except Exception as e:
      error "Error requesting community info", msg = e.msg, communityId


  proc importCommunity*(self: Service, communityKey: string) =
    try:
      let response = status_go.importCommunity(communityKey)
      ## after `importCommunity` call everything should be handled in a slot cnnected to `SignalType.CommunityFound.event`
      ## but because of insufficient data (chats details are missing) sent as a payload of that signal we're unable to do 
      ## that until `status-go` part gets improved in ragards of that. 

      if (response.error != nil):
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, fmt"community id `{communityKey}` err: {error.message}")

      if response.result == nil or response.result.kind != JObject:
        raise newException(RpcException, fmt"response is empty or not an json object, community id `{communityKey}`")

      var communityJArr: JsonNode
      if(not response.result.getProp("communities", communityJArr)):
        raise newException(RpcException, fmt"there is no `communities` key in the response for community id: {communityKey}")

      if(communityJArr.len == 0):
        raise newException(RpcException, fmt"`communities` array is empty in the response for community id: {communityKey}")
      
      var chatsJArr: JsonNode
      if(not response.result.getProp("chats", chatsJArr)):
        raise newException(RpcException, fmt"there is no `chats` key in the response for community id: {communityKey}")

      let communityDto = communityJArr[0].toCommunityDto()
      self.joinedCommunities[communityDto.id] = communityDto

      for chatObj in chatsJArr:
        let chatDto = chatObj.toChatDto()
        self.chatService.updateOrAddChat(chatDto) # we have to update chats stored in the chat service.

      for chat in communityDto.chats:
        let fullChatId = communityDto.id & chat.id
        var chatDetails =  self.chatService.getChatById(fullChatId)
        chatDetails.updateMissingFields(chat)
        self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
    
      self.events.emit(SIGNAL_COMMUNITY_IMPORTED, CommunityArgs(community: communityDto))

    except Exception as e:
      error "Error importing the community: ", msg = e.msg
      # We should apply some notification mechanism on the application level which will deal with errors and 
      # notify user about them. Till then we're using this way.
      self.events.emit(SIGNAL_COMMUNITY_IMPORTED, CommunityArgs(error: e.msg))

  proc exportCommunity*(self: Service, communityId: string): string =
    try:
      let response = status_go.exportCommunity(communityId)
      if (response.result != nil):
        return response.result.getStr
    except Exception as e:
      error "Error exporting community", msg = e.msg

  proc getPendingRequestIndex*(self: Service, communityId: string, requestId: string): int =
    let community = self.joinedCommunities[communityId]
    var i = 0
    for pendingRequest in community.pendingRequestsToJoin:
      if (pendingRequest.id == requestId):
        return i
      i.inc()
    return -1

  proc removeMembershipRequestFromCommunityAndGetMemberPubkey*(self: Service, communityId: string, requestId: string): string =
    let index = self.getPendingRequestIndex(communityId, requestId)

    if (index == -1):
      raise newException(RpcException, fmt"Community request not found: {requestId}")

    var community = self.joinedCommunities[communityId]
    result = community.pendingRequestsToJoin[index].publicKey
    community.pendingRequestsToJoin.delete(index)

    self.joinedCommunities[communityId] = community

  proc acceptRequestToJoinCommunity*(self: Service, communityId: string, requestId: string) =
    try:
      discard status_go.acceptRequestToJoinCommunity(requestId)

      let newMemberPubkey = self.removeMembershipRequestFromCommunityAndGetMemberPubkey(communityId, requestId)

      if (newMemberPubkey == ""):
        error "Did not find pubkey in the pending request"
        return

      self.events.emit(SIGNAL_COMMUNITY_MEMBER_APPROVED, CommunityMemberArgs(communityId: communityId, pubKey: newMemberPubkey))
    except Exception as e:
      error "Error accepting request to join community", msg = e.msg

  proc declineRequestToJoinCommunity*(self: Service, communityId: string, requestId: string) =
    try:
      discard status_go.declineRequestToJoinCommunity(requestId)

      discard self.removeMembershipRequestFromCommunityAndGetMemberPubkey(communityId, requestId)

      self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: self.joinedCommunities[communityId]))
    except Exception as e:
      error "Error declining request to join community", msg = e.msg

  proc inviteUsersToCommunityById*(self: Service, communityId: string, pubKeysJson: string): string =
    try:
      let pubKeysParsed = pubKeysJson.parseJson
      var pubKeys: seq[string] = @[]
      for pubKey in pubKeysParsed:
        pubKeys.add(pubKey.getStr)
      let response =  status_go.inviteUsersToCommunity(communityId, pubKeys)
      discard self.chatService.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error inviting to community", msg = e.msg
      result = "Error exporting community: " & e.msg

  proc removeUserFromCommunity*(self: Service, communityId: string, pubKeys: string)  =
    try:
      discard status_go.removeUserFromCommunity(communityId, pubKeys)
    except Exception as e:
      error "Error removing user from community", msg = e.msg

  proc banUserFromCommunity*(self: Service, communityId: string, pubKey: string)  =
    try:
      discard status_go.banUserFromCommunity(communityId, pubKey)
    except Exception as e:
      error "Error banning user from community", msg = e.msg

  proc setCommunityMuted*(self: Service, communityId: string, muted: bool) =
    try:
      discard status_go.setCommunityMuted(communityId, muted)
    except Exception as e:
      error "Error setting community un/muted", msg = e.msg
