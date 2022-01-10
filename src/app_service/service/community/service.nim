import NimQml, Tables, json, sequtils, std/algorithm, strformat, chronicles, json_serialization

import ./dto/community as community_dto

import ../chat/service as chat_service

import ../../../app/global/global_singleton
import ../../../app/core/eventemitter
import status/statusgo_backend_new/communities as status_go

export community_dto

logScope:
  topics = "community-service"

type
  CommunityArgs* = ref object of Args
    community*: CommunityDto

  CommunityChatArgs* = ref object of Args
    communityId*: string
    chat*: Chat

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

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_JOINED* = "SIGNAL_COMMUNITY_JOINED"
const SIGNAL_COMMUNITY_MY_REQUEST_ADDED* = "SIGNAL_COMMUNITY_MY_REQUEST_ADDED"
const SIGNAL_COMMUNITY_LEFT* = "SIGNAL_COMMUNITY_LEFT"
const SIGNAL_COMMUNITY_CREATED* = "SIGNAL_COMMUNITY_CREATED"
const SIGNAL_COMMUNITY_EDITED* = "SIGNAL_COMMUNITY_EDITED"
const SIGNAL_COMMUNITY_CHANNEL_CREATED* = "SIGNAL_COMMUNITY_CHANNEL_CREATED"
const SIGNAL_COMMUNITY_CHANNEL_EDITED* = "SIGNAL_COMMUNITY_CHANNEL_EDITED"
const SIGNAL_COMMUNITY_CHANNEL_REORDERED* = "SIGNAL_COMMUNITY_CHANNEL_REORDERED"
const SIGNAL_COMMUNITY_CHANNEL_DELETED* = "SIGNAL_COMMUNITY_CHANNEL_DELETED"
const SIGNAL_COMMUNITY_CATEGORY_CREATED* = "SIGNAL_COMMUNITY_CATEGORY_CREATED"
const SIGNAL_COMMUNITY_CATEGORY_EDITED* = "SIGNAL_COMMUNITY_CATEGORY_EDITED"
const SIGNAL_COMMUNITY_CATEGORY_DELETED* = "SIGNAL_COMMUNITY_CATEGORY_DELETED"

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

  proc delete*(self: Service) =
    discard

  proc newService*(events: EventEmitter, chatService: chat_service.Service): Service =
    result = Service()
    result.events = events
    result.chatService = chatService
    result.joinedCommunities = initTable[string, CommunityDto]()
    result.allCommunities = initTable[string, CommunityDto]()
    result.myCommunityRequests = @[]

  proc init*(self: Service) =
    try:
      let joinedCommunities = self.loadJoinedComunities()
      for community in joinedCommunities:
        self.joinedCommunities[community.id] = community

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

  proc leaveCommunity*(self: Service, communityId: string) =
    try:
      discard status_go.leaveCommunity(communityId)

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
        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, CommunityChatArgs(
          communityId: communityId,
          chat: chat)
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
        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, CommunityChatArgs(chat: chat))
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

  proc acceptRequestToJoinCommunity*(self: Service, requestId: string) =
    try:
      discard status_go.acceptRequestToJoinCommunity(requestId)
    except Exception as e:
      error "Error exporting community", msg = e.msg

  proc declineRequestToJoinCommunity*(self: Service, requestId: string) =
    try:
      discard status_go.declineRequestToJoinCommunity(requestId)
    except Exception as e:
      error "Error exporting community", msg = e.msg

  proc inviteUsersToCommunityById*(self: Service, communityId: string, pubKeysJson: string): string =
    try:
      let pubKeysParsed = pubKeysJson.parseJson
      var pubKeys: seq[string] = @[]
      for pubKey in pubKeysParsed:
        pubKeys.add(pubKey.getStr)
      let response =  status_go.inviteUsersToCommunity(communityId, pubKeys)
      discard self.chatService.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error exporting community", msg = e.msg
      result = "Error exporting community: " & e.msg

  proc removeUserFromCommunity*(self: Service, communityId: string, pubKeys: string)  =
    try:
      discard status_go.removeUserFromCommunity(communityId, pubKeys)
    except Exception as e:
      error "Error exporting community", msg = e.msg

  proc banUserFromCommunity*(self: Service, communityId: string, pubKey: string)  =
    try:
      discard status_go.banUserFromCommunity(communityId, pubKey)
    except Exception as e:
      error "Error exporting community", msg = e.msg

  proc setCommunityMuted*(self: Service, communityId: string, muted: bool) =
    try:
      discard status_go.setCommunityMuted(communityId, muted)
    except Exception as e:
      error "Error exporting community", msg = e.msg
