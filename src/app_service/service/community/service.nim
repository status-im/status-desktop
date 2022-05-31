import NimQml, Tables, json, sequtils, std/algorithm, strformat, strutils, chronicles, json_serialization

import ./dto/community as community_dto

import ../chat/service as chat_service

import ../../../app/global/global_singleton
import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]
import ../../../backend/communities as status_go

include ./async_tasks

export community_dto

logScope:
  topics = "community-service"

include ../../common/json_utils

type
  CommunityArgs* = ref object of Args
    community*: CommunityDto
    error*: string
    fromUserAction*: bool

  CuratedCommunityArgs* = ref object of Args
    curatedCommunity*: CuratedCommunity

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

  CommunityCategoryOrderArgs* = ref object of Args
    communityId*: string
    categoryId*: string
    position*: int

  CommunityCategoryArgs* = ref object of Args
    communityId*: string
    category*: Category
    chats*: seq[ChatDto]

  CommunityMemberArgs* = ref object of Args
    communityId*: string
    pubKey*: string

  CommunityMutedArgs* = ref object of Args
    communityId*: string
    muted*: bool

  CategoryArgs* = ref object of Args
    communityId*: string
    categoryId*: string

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_JOINED* = "communityJoined"
const SIGNAL_COMMUNITY_MY_REQUEST_ADDED* = "communityMyRequestAdded"
const SIGNAL_COMMUNITY_LEFT* = "communityLeft"
const SIGNAL_COMMUNITY_CREATED* = "communityCreated"
const SIGNAL_COMMUNITY_ADDED* = "communityAdded"
const SIGNAL_COMMUNITY_IMPORTED* = "communityImported"
const SIGNAL_COMMUNITY_DATA_IMPORTED* = "communityDataImported" # This one is when just loading the data with requestCommunityInfo
const SIGNAL_COMMUNITY_EDITED* = "communityEdited"
const SIGNAL_COMMUNITIES_UPDATE* = "communityUpdated"
const SIGNAL_COMMUNITY_CHANNEL_CREATED* = "communityChannelCreated"
const SIGNAL_COMMUNITY_CHANNEL_EDITED* = "communityChannelEdited"
const SIGNAL_COMMUNITY_CHANNEL_REORDERED* = "communityChannelReordered"
const SIGNAL_COMMUNITY_CHANNEL_DELETED* = "communityChannelDeleted"
const SIGNAL_COMMUNITY_CATEGORY_CREATED* = "communityCategoryCreated"
const SIGNAL_COMMUNITY_CATEGORY_EDITED* = "communityCategoryEdited"
const SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED* = "communityCategoryNameEdited"
const SIGNAL_COMMUNITY_CATEGORY_DELETED* = "communityCategoryDeleted"
const SIGNAL_COMMUNITY_CATEGORY_REORDERED* = "communityCategoryReordered"
const SIGNAL_COMMUNITY_MEMBER_APPROVED* = "communityMemberApproved"
const SIGNAL_COMMUNITY_MEMBER_REMOVED* = "communityMemberRemoved"
const SIGNAL_NEW_REQUEST_TO_JOIN_COMMUNITY* = "newRequestToJoinCommunity"
const SIGNAL_CURATED_COMMUNITY_FOUND* = "curatedCommunityFound"
const SIGNAL_COMMUNITY_MUTED* = "communityMuted"
const SIGNAL_CATEGORY_MUTED* = "categoryMuted"
const SIGNAL_CATEGORY_UNMUTED* = "categoryUnmuted"

QtObject:
  type
    Service* = ref object of QObject
      threadpool: ThreadPool
      events: EventEmitter
      chatService: chat_service.Service
      communityTags: string # JSON string contraining tags map
      joinedCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]
      curatedCommunities: Table[string, CuratedCommunity] # [community_id, CuratedCommunity]
      allCommunities: Table[string, CommunityDto] # [community_id, CommunityDto]
      myCommunityRequests*: seq[CommunityMembershipRequestDto]

  # Forward declaration
  proc loadCommunityTags(self: Service): string
  proc loadAllCommunities(self: Service): seq[CommunityDto]
  proc loadJoinedComunities(self: Service): seq[CommunityDto]
  proc loadCuratedCommunities(self: Service): seq[CuratedCommunity]
  proc loadCommunitiesSettings(self: Service): seq[CommunitySettingsDto]
  proc loadMyPendingRequestsToJoin*(self: Service)
  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto])
  proc handleCommunitiesSettingsUpdates(self: Service, communitiesSettings: seq[CommunitySettingsDto])
  proc pendingRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto]

  proc delete*(self: Service) =
    discard

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      chatService: chat_service.Service
      ): Service =
    result = Service()
    result.events = events
    result.threadpool = threadpool
    result.chatService = chatService
    result.communityTags = newString(0)
    result.joinedCommunities = initTable[string, CommunityDto]()
    result.curatedCommunities = initTable[string, CuratedCommunity]()
    result.allCommunities = initTable[string, CommunityDto]()
    result.myCommunityRequests = @[]

  proc doConnect(self: Service) =
    self.events.on(SignalType.CommunityFound.event) do(e: Args):
      var receivedData = CommunitySignal(e)
      self.allCommunities[receivedData.community.id] = receivedData.community
      self.events.emit(SIGNAL_COMMUNITY_DATA_IMPORTED, CommunityArgs(community: receivedData.community))

      if self.curatedCommunities.contains(receivedData.community.id) and not self.curatedCommunities[receivedData.community.id].available:
        let curatedCommunity = CuratedCommunity(available: true,
                                                communityId: receivedData.community.id,
                                                community: receivedData.community)
        self.curatedCommunities[receivedData.community.id] = curatedCommunity
        self.events.emit(SIGNAL_CURATED_COMMUNITY_FOUND, CuratedCommunityArgs(curatedCommunity: curatedCommunity))

    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling community updates
      if (receivedData.communities.len > 0):
        # Channel added removed is notified in the chats param
        self.handleCommunityUpdates(receivedData.communities, receivedData.chats)

      if (receivedData.communitiesSettings.len > 0):
        self.handleCommunitiesSettingsUpdates(receivedData.communitiesSettings)

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

          self.events.emit(SIGNAL_NEW_REQUEST_TO_JOIN_COMMUNITY, CommunityRequestArgs(communityRequest: membershipRequest))

  proc updateMissingFields(chatDto: var ChatDto, chat: ChatDto) =
    # This proc sets fields of `chatDto` which are available only for community channels.
    chatDto.position = chat.position
    chatDto.canPost = chat.canPost
    chatDto.categoryId = chat.categoryId

  proc findChatById(id: string, chats: seq[ChatDto]): ChatDto =
    for chat in chats:
      if(chat.id == id):
        return chat

  proc findIndexById(id: string, chats: seq[ChatDto]): int =
    var idx = -1
    for chat in chats:
      inc idx
      if(chat.id == id):
        return idx
    return -1

  proc findIndexById(id: string, categories: seq[Category]): int =
    var idx = -1
    for category in categories:
      inc idx
      if(category.id == id):
        return idx
    return -1

  proc saveUpdatedJoinedCommunity(self: Service, community: var CommunityDto) =
    # Community data we get from the signals and responses don't contgain the pending requests
    # therefore, we must keep the old one
    community.pendingRequestsToJoin = self.joinedCommunities[community.id].pendingRequestsToJoin

    # Update the joinded community list with the new data
    self.joinedCommunities[community.id] = community

  proc getChatsInCategory(self: Service, community: var CommunityDto, categoryId: string): seq[ChatDto] =
    result = @[]
    for chat in community.chats:
      if (chat.categoryId == categoryId):
        let fullChatId = community.id & chat.id
        var chatDetails = self.chatService.getChatById(fullChatId)
        result.add(chatDetails)

  proc handleCommunitiesSettingsUpdates(self: Service, communitiesSettings: seq[CommunitySettingsDto]) =
    for settings in communitiesSettings:
      if self.allCommunities.hasKey(settings.id):
        self.allCommunities[settings.id].settings = settings
      if self.joinedCommunities.hasKey(settings.id):
        self.joinedCommunities[settings.id].settings = settings
        self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: self.joinedCommunities[settings.id]))

  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto]) =
    var community = communities[0]

    if(not self.allCommunities.hasKey(community.id)):
      self.events.emit(SIGNAL_COMMUNITY_ADDED, CommunityArgs(community: community))
    # add or update community
    self.allCommunities[community.id] = community

    if(self.curatedCommunities.hasKey(community.id)):
      self.curatedCommunities[community.id].available = true
      self.curatedCommunities[community.id].community = community

    if(not self.joinedCommunities.hasKey(community.id)):
      if (community.joined and community.isMember):
        self.joinedCommunities[community.id] = community
        self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: community, fromUserAction: false))
      return

    let prev_community = self.joinedCommunities[community.id]

    # If there's settings without `id` it means the original
    # signal didn't include actual communitySettings, hence we
    # assign the settings we already have, otherwise we risk our
    # settings to be overridden with wrong defaults.
    if community.settings.id == "":
      community.settings = prev_community.settings

    # category was added
    if(community.categories.len > prev_community.categories.len):
      for category in community.categories:
        if findIndexById(category.id, prev_community.categories) == -1:
          let chats = self.getChatsInCategory(community, category.id)

          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_CREATED,
            CommunityCategoryArgs(communityId: community.id, category: category, chats: chats))

    # category was removed
    elif(community.categories.len < prev_community.categories.len):
      for prv_category in prev_community.categories:
        if findIndexById(prv_category.id, community.categories) == -1:
          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_DELETED,
            CommunityCategoryArgs(communityId: community.id, category: Category(id: prv_category.id)))

    # some property has changed
    else:
      for category in community.categories:
        # id is present
        if findIndexById(category.id, prev_community.categories) == -1:
          continue
        # but something is different
        for prev_category in prev_community.categories:
          if(category.id == prev_category.id and category.position != prev_category.position):
            self.events.emit(SIGNAL_COMMUNITY_CATEGORY_REORDERED,
              CommunityChatOrderArgs(
                communityId: community.id,
                categoryId: category.id,
                position: category.position))
          if(category.id == prev_category.id and category.name != prev_category.name):
            self.events.emit(SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED,
              CommunityCategoryArgs(communityId: community.id, category: category))

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

    self.saveUpdatedJoinedCommunity(community)
    self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[community]))

  proc init*(self: Service) =
    self.doConnect()
    self.communityTags = self.loadCommunityTags();
    let joinedCommunities = self.loadJoinedComunities()
    for community in joinedCommunities:
      self.joinedCommunities[community.id] = community
      if (community.admin):
        self.joinedCommunities[community.id].pendingRequestsToJoin = self.pendingRequestsToJoinForCommunity(community.id)

    let allCommunities = self.loadAllCommunities()
    for community in allCommunities:
      self.allCommunities[community.id] = community

    let curatedCommunities = self.loadCuratedCommunities()
    for curatedCommunity in curatedCommunities:
      self.curatedCommunities[curatedCommunity.communityId] = curatedCommunity

    let communitiesSettings = self.loadCommunitiesSettings()
    for settings in communitiesSettings:
      if self.allCommunities.hasKey(settings.id):
        self.allCommunities[settings.id].settings = settings
      if self.joinedCommunities.hasKey(settings.id):
        self.joinedCommunities[settings.id].settings = settings

    self.loadMyPendingRequestsToJoin()

  proc loadCommunityTags(self: Service): string =
    let response = status_go.getCommunityTags()
    var result = newString(0)
    toUgly(result, response.result)
    return result

  proc loadAllCommunities(self: Service): seq[CommunityDto] =
    try:
      let response = status_go.getAllCommunities()
      return parseCommunities(response)
    except Exception as e:
      let errDesription = e.msg
      error "error loading all communities: ", errDesription
      return @[]

  proc loadJoinedComunities(self: Service): seq[CommunityDto] =
    try:
      let response = status_go.getJoinedComunities()
      return parseCommunities(response)
    except Exception as e:
      let errDesription = e.msg
      error "error: ", errDesription
      return @[]

  proc loadCuratedCommunities(self: Service): seq[CuratedCommunity] =
    try:
      let response = status_go.getCuratedCommunities()
      return parseCuratedCommunities(response)
    except Exception as e:
      let errDesription = e.msg
      error "error loading curated communities: ", errDesription
      return @[]

  proc loadCommunitiesSettings(self: Service): seq[CommunitySettingsDto] =
    try:
      let response = status_go.getCommunitiesSettings()
      return parseCommunitiesSettings(response)
    except Exception as e:
      let errDesription = e.msg
      error "error loading communities settings: ", errDesription
      return

  proc getCommunityTags*(self: Service): string =
    return self.communityTags

  proc getJoinedCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.joinedCommunities.values)

  proc getAllCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.allCommunities.values)

  proc getCuratedCommunities*(self: Service): seq[CuratedCommunity] =
    return toSeq(self.curatedCommunities.values)

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

  proc getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[ChatDto] =
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
      result.sort(sortAsc[ChatDto])
    else:
      result.sort(sortDesc[ChatDto])

  proc getAllChats*(self: Service, communityId: string, order = SortOrder.Ascending): seq[ChatDto] =
    ## Returns all chats belonging to the community with passed `communityId`, sorted by position.
    ## Returned chats are sorted by position following set `order` parameter.
    if(not self.joinedCommunities.contains(communityId)):
      error "trying to get all community chats for an unexisting community id"
      return

    result = self.joinedCommunities[communityId].chats

    if(order == SortOrder.Ascending):
      result.sort(sortAsc[ChatDto])
    else:
      result.sort(sortDesc[ChatDto])

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

      let response = status_go.joinCommunity(communityId)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error joining community: " & error.message)

      if response.result == nil or response.result.kind == JNull:
        error "error: ", procName="joinCommunity", errDesription = "result is nil"
        return

      if not response.result.hasKey("communities") or response.result["communities"].kind != JArray or response.result["communities"].len == 0:
        error "error: ", procName="joinCommunity", errDesription = "no 'communities' key in response"
        return

      if not response.result.hasKey("communitiesSettings") or response.result["communitiesSettings"].kind != JArray or response.result["communitiesSettings"].len == 0:
        error "error: ", procName="joinCommunity", errDesription = "no 'communitiesSettings' key in response"
        return

      var updatedCommunity = response.result["communities"][0].toCommunityDto()
      let communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()

      updatedCommunity.settings = communitySettings
      self.allCommunities[communityId] = updatedCommunity
      self.joinedCommunities[communityId] = updatedCommunity

      for k, chat in updatedCommunity.chats:
        let fullChatId = communityId & chat.id
        let currentChat =  self.chatService.getChatById(fullChatId, showWarning = false)

        if (currentChat.id != ""):
          # The chat service already knows that about that chat
          continue
        var chatDto = chat
        chatDto.id = fullChatId
        # TODO find a way to populate missing infos like the color
        self.chatService.updateOrAddChat(chatDto)

      self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[updatedCommunity]))
      self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: updatedCommunity, fromUserAction: true))
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
        error "error: ", procName="leaveCommunity", errDesription = "result is nil"
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
      introMessage: string,
      outroMessage: string,
      access: int,
      color: string,
      tags: string,
      imageUrl: string,
      aX: int, aY: int, bX: int, bY: int,
      historyArchiveSupportEnabled: bool,
      pinMessageAllMembersEnabled: bool) =
    try:
      var image = singletonInstance.utils.formatImagePath(imageUrl)
      var tagsString = tags
      if len(tagsString) == 0:
        tagsString = "[]"

      let response = status_go.createCommunity(
        name,
        description,
        introMessage,
        outroMessage,
        access,
        color,
        tagsString,
        image,
        aX, aY, bX, bY,
        historyArchiveSupportEnabled,
        pinMessageAllMembersEnabled)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        var community = response.result["communities"][0].toCommunityDto()
        let communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()


        community.settings = communitySettings
        # add this to the joinedCommunities list and communitiesSettings
        self.joinedCommunities[community.id] = community

        self.events.emit(SIGNAL_COMMUNITY_CREATED, CommunityArgs(community: community))
    except Exception as e:
      error "Error creating community", msg = e.msg

  proc editCommunity*(
      self: Service,
      id: string,
      name: string,
      description: string,
      introMessage: string,
      outroMessage: string,
      access: int,
      color: string,
      tags: string,
      logoJsonStr: string,
      bannerJsonStr: string,
      historyArchiveSupportEnabled: bool,
      pinMessageAllMembersEnabled: bool) =
    try:
      # TODO: refactor status-go to use `CroppedImage` for logo as it does for banner. This is an API breaking change, sync with mobile
      let logoJson = parseJson(logoJsonStr)
      let cropRectJson = logoJson["cropRect"]
      var tagsString = tags
      if len(tagsString) == 0:
        tagsString = "[]"
      let response = status_go.editCommunity(
        id,
        name,
        description,
        introMessage,
        outroMessage,
        access,
        color,
        tagsString,
        logoJson["imagePath"].getStr(),
        int(cropRectJson["x"].getFloat()),
        int(cropRectJson["y"].getFloat()),
        int(cropRectJson["x"].getFloat() + cropRectJson["width"].getFloat()),
        int(cropRectJson["y"].getFloat() + cropRectJson["height"].getFloat()),
        bannerJsonStr,
        historyArchiveSupportEnabled,
        pinMessageAllMembersEnabled)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error editing community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        var community = response.result["communities"][0].toCommunityDto()
        var communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()

        community.settings = communitySettings
        self.saveUpdatedJoinedCommunity(community)
        self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))
    except Exception as e:
      error "Error editing community", msg = e.msg

  proc createCommunityChannel*(
      self: Service,
      communityId: string,
      name: string,
      description: string,
      emoji: string,
      color: string,
      categoryId: string) =
    try:
      let response = status_go.createCommunityChannel(communityId, name, description, emoji, color,
        categoryId)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community channel: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", procName="createCommunityChannel"

      var chatsJArr: JsonNode
      if(not response.result.getProp("chats", chatsJArr)):
        raise newException(RpcException, fmt"createCommunityChannel; there is no `chats` key in the response for community id: {communityId}")

      for chatObj in chatsJArr:
        var chatDto = chatObj.toChatDto(communityId)
        self.chatService.updateOrAddChat(chatDto)
        let data = CommunityChatArgs(chat: chatDto)
        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, data)
    except Exception as e:
      error "Error creating community channel", msg = e.msg, communityId, name, description, procName="createCommunityChannel"

  proc editCommunityChannel*(
      self: Service,
      communityId: string,
      channelId: string,
      name: string,
      description: string,
      emoji: string,
      color: string,
      categoryId: string,
      position: int) =
    try:
      let response = status_go.editCommunityChannel(
        communityId,
        channelId,
        name,
        description,
        emoji,
        color,
        categoryId,
        position)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error editing community channel: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", procName="editCommunityChannel"

      var chatsJArr: JsonNode
      if(not response.result.getProp("chats", chatsJArr)):
        raise newException(RpcException, fmt"editCommunityChannel; there is no `chats` key in the response for community id: {communityId}")

      for chatObj in chatsJArr:
        var chatDto = chatObj.toChatDto(communityId)

        self.chatService.updateOrAddChat(chatDto) # we have to update chats stored in the chat service.

        let data = CommunityChatArgs(chat: chatDto)
        self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, data)

    except Exception as e:
      error "Error editing community channel", msg = e.msg, communityId, channelId, procName="editCommunityChannel"

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
        error "response is invalid", procName="reorderCommunityChat"

      if response.result != nil and response.result.kind != JNull:
        let updatedCommunity = response.result["communities"][0].toCommunityDto()
        for chat in updatedCommunity.chats:
          let prev_chat_idx = findIndexById(chat.id, self.joinedCommunities[communityId].chats)
          if prev_chat_idx > -1:
            let fullChatId = communityId & chat.id
            let prev_chat = self.joinedCommunities[communityId].chats[prev_chat_idx]
            if(chat.position != prev_chat.position and chat.categoryId == categoryId):
              var chatDetails = self.chatService.getChatById(fullChatId) # we are free to do this cause channel must be created before we add it to a category
              self.joinedCommunities[communityId].chats[prev_chat_idx].position = chat.position
              chatDetails.updateMissingFields(self.joinedCommunities[communityId].chats[prev_chat_idx])
              self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
              self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED, CommunityChatOrderArgs(communityId: updatedCommunity.id, chatId: fullChatId, categoryId: chat.categoryId, position: chat.position))

    except Exception as e:
      error "Error reordering community channel", msg = e.msg, communityId, chatId, position, procName="reorderCommunityChat"

  proc deleteCommunityChat*(self: Service, communityId: string, chatId: string) =
    try:
      let response = status_go.deleteCommunityChat(communityId, chatId)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error deleting community chat: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", procName="deleteCommunityChat"

      var shortChatId = chatId.replace(communityId, "")
      let idx = findIndexById(shortChatId, self.joinedCommunities[communityId].chats)
      if (idx != -1):
        self.joinedCommunities[communityId].chats.delete(idx)

      self.events.emit(SIGNAL_COMMUNITY_CHANNEL_DELETED, CommunityChatIdArgs(
        communityId: communityId, chatId: chatId))
    except Exception as e:
      error "Error deleting community channel", msg = e.msg, communityId, chatId, procName="deleteCommunityChat"

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
          let fullChatId = communityId & chatId
          let idx = findIndexById(fullChatId, self.joinedCommunities[communityId].chats)
          if idx > -1:
            self.joinedCommunities[communityId].chats[idx].categoryId = v["CategoryModified"].getStr()
            self.joinedCommunities[communityId].chats[idx].position = v["PositionModified"].getInt()
            if self.joinedCommunities[communityId].chats[idx].categoryId.len > 0:
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
        var chats: seq[ChatDto] = @[]
        for chatId, v in response.result["communityChanges"].getElems()[0]["chatsModified"].pairs():
          let fullChatId = communityId & chatId
          let idx = findIndexById(fullChatId, self.joinedCommunities[communityId].chats)
          if idx > -1:
            self.joinedCommunities[communityId].chats[idx].categoryId = v["CategoryModified"].getStr()
            self.joinedCommunities[communityId].chats[idx].position = v["PositionModified"].getInt()

            var chatDetails = self.chatService.getChatById(fullChatId) # we are free to do this cause channel must be created before we add it to a category
            chatDetails.updateMissingFields(self.joinedCommunities[communityId].chats[idx])
            self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
            chats.add(chatDetails)

        for k, v in response.result["communityChanges"].getElems()[0]["categoriesModified"].pairs():
          let category = v.toCategory()
          self.events.emit(SIGNAL_COMMUNITY_CATEGORY_EDITED,
            CommunityCategoryArgs(communityId: communityId, category: category, chats: chats))

    except Exception as e:
      error "Error editing community category", msg = e.msg, communityId, name

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

  proc reorderCommunityCategories*(
      self: Service,
      communityId: string,
      categoryId: string,
      position: int) =
    try:
      let response = status_go.reorderCommunityCategories(
        communityId,
        categoryId,
        position)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error reordering community category: " & error.message)

    except Exception as e:
      error "Error reordering category channel", msg = e.msg, communityId, categoryId, position


  proc asyncActivityNotificationLoad*(self: Service, communityId: string) =
    let arg = AsyncRequestCommunityInfoTaskArg(
      tptr: cast[ByteAddress](asyncRequestCommunityInfoTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncCommunityInfoLoaded",
      communityId: communityId
    )
    self.threadpool.start(arg)

  proc asyncCommunityInfoLoaded*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson
    if (rpcResponseObj{"error"}.kind != JNull):
      let error = Json.decode($rpcResponseObj["error"], RpcError)
      error "Error requesting community info", msg = error.message

  proc requestCommunityInfo*(self: Service, communityId: string) =
    try:
      self.asyncActivityNotificationLoad(communityId)
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

      var communitiesSettingsJArr: JsonNode
      if(not response.result.getProp("communitiesSettings", communitiesSettingsJArr)):
        raise newException(RpcException, fmt"there is no `communitiesSettings` key in the response for community id: {communityKey}")

      if(communitiesSettingsJArr.len == 0):
        raise newException(RpcException, fmt"`communitiesSettings` array is empty in the response for community id: {communityKey}")

      var communityDto = communityJArr[0].toCommunityDto()
      let communitySettingsDto = communitiesSettingsJArr[0].toCommunitySettingsDto()

      communityDto.settings = communitySettingsDto
      self.joinedCommunities[communityDto.id] = communityDto

      var chatsJArr: JsonNode
      if(response.result.getProp("chats", chatsJArr)):
        for chatObj in chatsJArr:
          let chatDto = chatObj.toChatDto(communityDto.id)
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
      self.events.emit(SIGNAL_COMMUNITY_IMPORTED, CommunityArgs(error: "Error while importing the community"))

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
      # We no longer send invites, but merely share the community so 
      # users can request access (with automatic acception)
      let response =  status_go.shareCommunityToUsers(communityId, pubKeys)
      discard self.chatService.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error sharing community", msg = e.msg
      result = "Error sharing community: " & e.msg

  proc muteCategory*(self: Service, communityId: string, categoryId: string) =
    try:
      let response = status_go.muteCategory(communityId, categoryId)
      if (not response.error.isNil):
        let msg = response.error.message & " categoryId=" & categoryId
        error "error while mute category ", msg
        return

      self.events.emit(SIGNAL_CATEGORY_MUTED, CategoryArgs(communityId: communityId, categoryId: categoryId))

    except Exception as e:
      error "Error muting category", msg = e.msg

  proc unmuteCategory*(self: Service, communityId: string, categoryId: string) =
    try:
      let response = status_go.unmuteCategory(communityId, categoryId)
      if (not response.error.isNil):
        let msg = response.error.message & " categoryId=" & categoryId
        error "error while unmute category ", msg
        return

      self.events.emit(SIGNAL_CATEGORY_UNMUTED, CategoryArgs(communityId: communityId, categoryId: categoryId))

    except Exception as e:
      error "Error unmuting category", msg = e.msg

  proc removeUserFromCommunity*(self: Service, communityId: string, pubKey: string)  =
    try:
      discard status_go.removeUserFromCommunity(communityId, pubKey)

      self.events.emit(SIGNAL_COMMUNITY_MEMBER_REMOVED,
        CommunityMemberArgs(communityId: communityId, pubKey: pubKey))
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

      self.events.emit(SIGNAL_COMMUNITY_MUTED,
        CommunityMutedArgs(communityId: communityId, muted: muted))
    except Exception as e:
      error "Error setting community un/muted", msg = e.msg

  proc isCommunityRequestPending*(self: Service, communityId: string): bool {.slot.} =
    for communityRequest in self.myCommunityRequests:
      if (communityRequest.communityId == communityId):
        return true
    return false
