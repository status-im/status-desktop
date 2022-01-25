import NimQml, Tables, json, sequtils, std/algorithm, strformat, chronicles, json_serialization

import ./dto/community as community_dto

import ../chat/service as chat_service

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import status/statusgo_backend_new/communities as status_go

export community_dto

logScope:
  topics = "community-service"

type
  CommunityArgs* = ref object of Args
    community*: CommunityDto

  CommunitiesArgs* = ref object of Args
    communities*: seq[CommunityDto]

  CommunityChatArgs* = ref object of Args
    communityId*: string
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
    channels*: seq[string]

  CommunityMemberArgs* = ref object of Args
    communityId*: string
    pubKey*: string

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_JOINED* = "communityJoined"
const SIGNAL_COMMUNITY_MY_REQUEST_ADDED* = "communityMyRequestAdded"
const SIGNAL_COMMUNITY_LEFT* = "communityLeft"
const SIGNAL_COMMUNITY_CREATED* = "communityCreated"
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
        if (receivedData.chats.len > 0):
          self.handleCommunityUpdates(receivedData.communities, receivedData.chats)

        self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: receivedData.communities))

    self.events.on(SignalType.Message.event) do(e:Args):
      var receivedData = MessageSignal(e)
      if(receivedData.membershipRequests.len > 0):
        for membershipRequest in receivedData.membershipRequests:
          if (not self.joinedCommunities.contains(membershipRequest.communityId)):
            error "Received a membership request for an unknown community", communityId=membershipRequest.communityId
            continue
          var community = self.joinedCommunities[membershipRequest.communityId]
          community.pendingRequestsToJoin.add(membershipRequest)
          self.joinedCommunities[membershipRequest.communityId] = community
          self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))

  proc mapChatToChatDto(chat: Chat): ChatDto =
    result = ChatDto()
    result.id = chat.id
    result.name = chat.name
    result.color = chat.color
    result.emoji = chat.emoji
    result.description = chat.description
    result.canPost = chat.canPost
    result.position = chat.position
    result.categoryId = chat.categoryId

  proc findChatById(id: string, chats: seq[ChatDto]): ChatDto =
    for chat in chats:
      if(chat.id == id):
        return chat

  proc findIndexById(id: string, chats: seq[Chat]): int =
    for chat in chats:
      if(chat.id == id):
        return 0
    return -1

  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto]) =
    let community = communities[0]
    var sortingOrderChanged = false
    if(not self.joinedCommunities.hasKey(community.id)):
      error "error: community doesn't exist"
      return

    let prev_community = self.joinedCommunities[community.id]

    # channel was added
    if(community.chats.len > prev_community.chats.len):
      for chat in community.chats:
        if findIndexById(chat.id, prev_community.chats) == -1:
          # update missing params
          let updated_chat = findChatById(community.id&chat.id, updatedChats)
          var chat_to_be_added = chat
          chat_to_be_added.id = community.id&chat.id
          chat_to_be_added.color = updated_chat.color

          self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, CommunityChatArgs(communityId: community.id, chat: mapChatToChatDto(chat_to_be_added)))

    # channel was removed
    elif(community.chats.len < prev_community.chats.len):
      for prv_chat in prev_community.chats:
        if findIndexById(prv_chat.id, community.chats) == -1:
          self.events.emit(SIGNAL_COMMUNITY_CHANNEL_DELETED, CommunityChatIdArgs(communityId: community.id, chatId: community.id&prv_chat.id))
    # some property has changed
    else:
      for chat in community.chats:
        # id is present
        if findIndexById(chat.id, prev_community.chats) == -1:
          error "error: chat not present"
          return
        # but something is different
        for prev_chat in prev_community.chats:

          # Category changes not handled yet
          #if(chat.id == prev_chat.id and chat.categoryId != prev_chat.categoryId):

          # Handle position changes
          if(chat.id == prev_chat.id and chat.position != prev_chat.position):
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED, CommunityChatOrderArgs(communityId: community.id, chatId: community.id&chat.id, categoryId: chat.categoryId, position: chat.position))

          # Handle name/description changes
          if(chat.id == prev_chat.id and (chat.name != prev_chat.name or chat.description != prev_chat.description)):
            # update missing params
            let updated_chat = findChatById(community.id&chat.id, updatedChats)
            var chat_to_be_edited = chat
            chat_to_be_edited.id = community.id&chat.id
            if(updated_chat.color != ""):
              chat_to_be_edited.color = updated_chat.color

            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, CommunityChatArgs(communityId: community.id, chat: mapChatToChatDto(chat_to_be_edited)))

    self.joinedCommunities[community.id].chats = community.chats

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
      description: string) =
    try:
      let response = status_go.createCommunityChannel(communityId, name, description)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community channel: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        let chat = response.result["chats"][0].toChat()

        # update the joined communities
        self.joinedCommunities[communityId].chats.add(chat)

        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, CommunityChatArgs(
          communityId: communityId,
          chat: mapChatToChatDto(chat))
        )
    except Exception as e:
      error "Error creating community channel", msg = e.msg, communityId, name, description

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

      if response.result != nil and response.result.kind != JNull:
        let chat = response.result["chats"][0].toChat()

        # update the joined communities
        let idx = self.joinedCommunities[communityId].chats.find(chat)
        if(idx != -1):
          self.joinedCommunities[communityId].chats[idx] = chat

        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, CommunityChatArgs(chat: mapChatToChatDto(chat)))
    except Exception as e:
      error "Error editing community channel", msg = e.msg, communityId, channelId

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

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error reordering community channel: " & error.message)

      self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED,
        CommunityChatOrderArgs(
          communityId: communityId,
          categoryId: categoryId,
          chatId: chatId,
          position: position
        )
      )
    except Exception as e:
      error "Error reordering community channel", msg = e.msg, communityId, chatId, position

  proc deleteCommunityChat*(self: Service, communityId: string, chatId: string) =
    try:
      let response = status_go.deleteCommunityChat(communityId, chatId)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error deleting community chat: " & error.message)

      if response.result == nil or response.result.kind == JNull:
        error "response is invalid"
        return

      let community = response.result["communities"][0].toCommunityDto()

      # update the joined communities
      self.joinedCommunities[community.id].chats = community.chats

      self.events.emit(SIGNAL_COMMUNITY_CHANNEL_DELETED,
        CommunityChatIdArgs(
          communityId: communityId,
          chatId: chatId
        )
      )
    except Exception as e:
      error "Error deleting community channel", msg = e.msg, communityId, chatId

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
        for k, v in response.result["communityChanges"].getElems()[0]["categoriesAdded"].pairs():
          let category = v.toCategory()
          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_CREATED,
            CommunityCategoryArgs(communityId: communityId, category: category, channels: channels))
          
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
            CommunityCategoryArgs(communityId: communityId, category: category, channels: channels))
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
      if (response.error != nil):
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, fmt"Error importing the community: {error.message}")
    except Exception as e:
      error "Error requesting community info", msg = e.msg

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
