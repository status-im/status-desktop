import NimQml, Tables, json, sequtils, std/sets, std/algorithm, strformat, strutils, chronicles, json_serialization, sugar
import json_serialization/std/tables as ser_tables

import ./dto/community as community_dto

import ../activity_center/service as activity_center_service
import ../message/service as message_service
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

type
  CommunityArgs* = ref object of Args
    community*: CommunityDto
    error*: string
    fromUserAction*: bool

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
    chat*: ChatDto

  CommunityChatsOrderArgs* = ref object of Args
    communityId*: string
    chats*: seq[ChatDto]

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
    requestId*: string

  CommunityMembersArgs* = ref object of Args
    communityId*: string
    members*: seq[ChatMember]

  CommunityMutedArgs* = ref object of Args
    communityId*: string
    muted*: bool

  CategoryArgs* = ref object of Args
    communityId*: string
    categoryId*: string

  CommunityTokenPermissionArgs* = ref object of Args
    communityId*: string
    tokenPermission*: CommunityTokenPermissionDto
    error*: string

  CommunityTokenMetadataArgs* = ref object of Args
    communityId*: string
    tokenMetadata*: CommunityTokensMetadataDto

  CommunityTokenPermissionRemovedArgs* = ref object of Args
    communityId*: string
    permissionId*: string

  DiscordCategoriesAndChannelsArgs* = ref object of Args
    categories*: seq[DiscordCategoryDto]
    channels*: seq[DiscordChannelDto]
    oldestMessageTimestamp*: int
    errors*: Table[string, DiscordImportError]
    errorsCount*: int

  DiscordImportProgressArgs* = ref object of Args
    communityId*: string
    communityImage*: string
    communityName*: string
    tasks*: seq[DiscordImportTaskProgress]
    progress*: float
    errorsCount*: int
    warningsCount*: int
    stopped*: bool
    totalChunksCount*: int
    currentChunk*: int

# Signals which may be emitted by this service:
const SIGNAL_COMMUNITY_DATA_LOADED* = "communityDataLoaded"
const SIGNAL_COMMUNITY_JOINED* = "communityJoined"
const SIGNAL_COMMUNITY_SPECTATED* = "communitySpectated"
const SIGNAL_COMMUNITY_MY_REQUEST_ADDED* = "communityMyRequestAdded"
const SIGNAL_COMMUNITY_LEFT* = "communityLeft"
const SIGNAL_COMMUNITY_CREATED* = "communityCreated"
const SIGNAL_COMMUNITY_ADDED* = "communityAdded"
const SIGNAL_COMMUNITY_IMPORTED* = "communityImported"
const SIGNAL_COMMUNITY_DATA_IMPORTED* = "communityDataImported" # This one is when just loading the data with requestCommunityInfo
const SIGNAL_COMMUNITY_LOAD_DATA_FAILED* = "communityLoadDataFailed"
const SIGNAL_COMMUNITY_EDITED* = "communityEdited"
const SIGNAL_COMMUNITIES_UPDATE* = "communityUpdated"
const SIGNAL_COMMUNITY_CHANNEL_CREATED* = "communityChannelCreated"
const SIGNAL_COMMUNITY_CHANNEL_EDITED* = "communityChannelEdited"
const SIGNAL_COMMUNITY_CHANNEL_REORDERED* = "communityChannelReordered"
const SIGNAL_COMMUNITY_CHANNELS_REORDERED* = "communityChannelsReordered"
const SIGNAL_COMMUNITY_CHANNEL_DELETED* = "communityChannelDeleted"
const SIGNAL_COMMUNITY_CATEGORY_CREATED* = "communityCategoryCreated"
const SIGNAL_COMMUNITY_CATEGORY_EDITED* = "communityCategoryEdited"
const SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED* = "communityCategoryNameEdited"
const SIGNAL_COMMUNITY_CATEGORY_DELETED* = "communityCategoryDeleted"
const SIGNAL_COMMUNITY_CATEGORY_REORDERED* = "communityCategoryReordered"
const SIGNAL_COMMUNITY_CHANNEL_CATEGORY_CHANGED* = "communityChannelCategoryChanged"
const SIGNAL_COMMUNITY_MEMBER_APPROVED* = "communityMemberApproved"
const SIGNAL_COMMUNITY_MEMBER_REMOVED* = "communityMemberRemoved"
const SIGNAL_COMMUNITY_MEMBERS_CHANGED* = "communityMembersChanged"
const SIGNAL_COMMUNITY_KICKED* = "communityKicked"
const SIGNAL_NEW_REQUEST_TO_JOIN_COMMUNITY* = "newRequestToJoinCommunity"
const SIGNAL_REQUEST_TO_JOIN_COMMUNITY_CANCELED* = "requestToJoinCommunityCanceled"
const SIGNAL_CURATED_COMMUNITY_FOUND* = "curatedCommunityFound"
const SIGNAL_COMMUNITY_MUTED* = "communityMuted"
const SIGNAL_CATEGORY_MUTED* = "categoryMuted"
const SIGNAL_CATEGORY_UNMUTED* = "categoryUnmuted"
const SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_STARTED* = "communityHistoryArchivesDownloadStarted"
const SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_FINISHED* = "communityHistoryArchivesDownloadFinished"

const SIGNAL_DISCORD_CATEGORIES_AND_CHANNELS_EXTRACTED* = "discordCategoriesAndChannelsExtracted"
const SIGNAL_DISCORD_COMMUNITY_IMPORT_FINISHED* = "discordCommunityImportFinished"
const SIGNAL_DISCORD_COMMUNITY_IMPORT_PROGRESS* = "discordCommunityImportProgress"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATED* = "communityTokenPermissionCreated"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATION_FAILED* = "communityTokenPermissionCreationFailed"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATED* = "communityTokenPermissionUpdated"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATE_FAILED* = "communityTokenPermissionUpdateFailed"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETED* = "communityTokenPermissionDeleted"
const SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETION_FAILED* = "communityTokenPermissionDeletionFailed"
const SIGNAL_COMMUNITY_TOKEN_METADATA_ADDED* = "communityTokenMetadataAdded"

const SIGNAL_CURATED_COMMUNITIES_LOADING* = "curatedCommunitiesLoading"
const SIGNAL_CURATED_COMMUNITIES_LOADED* = "curatedCommunitiesLoaded"
const SIGNAL_CURATED_COMMUNITIES_LOADING_FAILED* = "curatedCommunitiesLoadingFailed"

const SIGNAL_ACCEPT_REQUEST_TO_JOIN_LOADING* = "acceptRequestToJoinLoading"
const SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED* = "acceptRequestToJoinFailed"
const SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED_NO_PERMISSION* = "acceptRequestToJoinFailedNoPermission"

const SIGNAL_COMMUNITY_INFO_ALREADY_REQUESTED* = "communityInfoAlreadyRequested"

const TOKEN_PERMISSIONS_ADDED = "tokenPermissionsAdded"
const TOKEN_PERMISSIONS_MODIFIED = "tokenPermissionsModified"

QtObject:
  type
    Service* = ref object of QObject
      threadpool: ThreadPool
      events: EventEmitter
      chatService: chat_service.Service
      activityCenterService: activity_center_service.Service
      messageService: message_service.Service
      communityTags: string # JSON string contraining tags map
      communities: Table[string, CommunityDto] # [community_id, CommunityDto]
      myCommunityRequests*: seq[CommunityMembershipRequestDto]
      historyArchiveDownloadTaskCommunityIds*: HashSet[string]
      requestedCommunityIds*: HashSet[string]

  # Forward declaration
  proc asyncLoadCuratedCommunities*(self: Service)
  proc asyncAcceptRequestToJoinCommunity*(self: Service, communityId: string, requestId: string)
  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto], removedChats: seq[string])
  proc handleCommunitiesSettingsUpdates(self: Service, communitiesSettings: seq[CommunitySettingsDto])
  proc pendingRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto]
  proc declinedRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto]
  proc canceledRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto]
  proc getPendingRequestIndex(self: Service, communityId: string, requestId: string): int
  proc removeMembershipRequestFromCommunityAndGetMemberPubkey*(self: Service, communityId: string, requestId: string, updatedCommunity: CommunityDto): string
  proc getUserPubKeyFromPendingRequest*(self: Service, communityId: string, requestId: string): string

  proc delete*(self: Service) =
    discard

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      chatService: chat_service.Service,
      activityCenterService: activity_center_service.Service,
      messageService: message_service.Service
      ): Service =
    result = Service()
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.chatService = chatService
    result.activityCenterService = activityCenterService
    result.messageService = messageService
    result.communityTags = newString(0)
    result.communities = initTable[string, CommunityDto]()
    result.myCommunityRequests = @[]
    result.historyArchiveDownloadTaskCommunityIds = initHashSet[string]()
    result.requestedCommunityIds = initHashSet[string]()

  proc getFilteredJoinedCommunities(self: Service): Table[string, CommunityDto] =
    result = initTable[string, CommunityDto]()
    for communityId, community in self.communities.pairs:
      if community.joined:
        result[communityId] = community

  proc getFilteredCuratedCommunities(self: Service): Table[string, CommunityDto] =
    result = initTable[string, CommunityDto]()
    for communityId, community in self.communities.pairs:
      if community.listedInDirectory:
        result[communityId] = community

  proc doConnect(self: Service) =
    self.events.on(SignalType.CommunityFound.event) do(e: Args):
      var receivedData = CommunitySignal(e)
      self.communities[receivedData.community.id] = receivedData.community
      self.events.emit(SIGNAL_COMMUNITY_DATA_IMPORTED, CommunityArgs(community: receivedData.community))

      if self.communities.contains(receivedData.community.id) and
          self.communities[receivedData.community.id].listedInDirectory and not 
          self.communities[receivedData.community.id].isAvailable:
        self.events.emit(SIGNAL_CURATED_COMMUNITY_FOUND, CommunityArgs(community: self.communities[receivedData.community.id]))

    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)
      # Handling community updates
      if (receivedData.communities.len > 0):
        # Channel added removed is notified in the chats param
        self.handleCommunityUpdates(receivedData.communities, receivedData.chats, receivedData.removedChats)

      if (receivedData.communitiesSettings.len > 0):
        self.handleCommunitiesSettingsUpdates(receivedData.communitiesSettings)

      # Handling membership requests
      if(receivedData.membershipRequests.len > 0):
        for membershipRequest in receivedData.membershipRequests:
          if (not self.communities.contains(membershipRequest.communityId)):
            error "Received a membership request for an unknown community", communityId=membershipRequest.communityId
            continue
          var community = self.communities[membershipRequest.communityId]

          case RequestToJoinType(membershipRequest.state):
          of RequestToJoinType.Pending:
            community.pendingRequestsToJoin.add(membershipRequest)
            self.communities[membershipRequest.communityId] = community
            self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))
            self.events.emit(SIGNAL_NEW_REQUEST_TO_JOIN_COMMUNITY, CommunityRequestArgs(communityRequest: membershipRequest))

          of RequestToJoinType.Canceled:
            let indexPending = self.getPendingRequestIndex(membershipRequest.communityId, membershipRequest.id)
            if (indexPending != -1):
              community.pendingRequestsToJoin.delete(indexPending)
              self.communities[membershipRequest.communityId] = community
              self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: community))
          
          of RequestToJoinType.Declined:
            break
          of RequestToJoinType.Accepted:
            break

    self.events.on(SignalType.DiscordCategoriesAndChannelsExtracted.event) do(e: Args):
      var receivedData = DiscordCategoriesAndChannelsExtractedSignal(e)
      self.events.emit(SIGNAL_DISCORD_CATEGORIES_AND_CHANNELS_EXTRACTED, DiscordCategoriesAndChannelsArgs(
        categories: receivedData.categories,
        channels: receivedData.channels,
        oldestMessageTimestamp: receivedData.oldestMessageTimestamp,
        errors: receivedData.errors,
        errorsCount: receivedData.errorsCount
      ))

    self.events.on(SignalType.DiscordCommunityImportFinished.event) do(e: Args):
      var receivedData = DiscordCommunityImportFinishedSignal(e)
      self.events.emit(SIGNAL_DISCORD_COMMUNITY_IMPORT_FINISHED, CommunityIdArgs(communityId: receivedData.communityId))

    self.events.on(SignalType.DiscordCommunityImportProgress.event) do(e: Args):
      var receivedData = DiscordCommunityImportProgressSignal(e)
      self.events.emit(SIGNAL_DISCORD_COMMUNITY_IMPORT_PROGRESS, DiscordImportProgressArgs(
        communityId: receivedData.communityId,
        communityImage: receivedData.communityImages.thumbnail,
        communityName: receivedData.communityName,
        tasks: receivedData.tasks,
        progress: receivedData.progress,
        errorsCount: receivedData.errorsCount,
        warningsCount: receivedData.warningsCount,
        stopped: receivedData.stopped,
        totalChunksCount: receivedData.totalChunksCount,
        currentChunk: receivedData.currentChunk,
      ))

    self.events.on(SignalType.ImportingHistoryArchiveMessages.event) do(e: Args):
      var receivedData = HistoryArchivesSignal(e)
      if receivedData.communityId notin self.historyArchiveDownloadTaskCommunityIds:
        self.historyArchiveDownloadTaskCommunityIds.incl(receivedData.communityId)
        self.events.emit(SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_STARTED, CommunityIdArgs(communityId: receivedData.communityId))

    self.events.on(SignalType.DownloadingHistoryArchivesFinished.event) do(e: Args):
      var receivedData = HistoryArchivesSignal(e)
      if receivedData.communityId in self.historyArchiveDownloadTaskCommunityIds:
        self.historyArchiveDownloadTaskCommunityIds.excl(receivedData.communityId)

        if self.historyArchiveDownloadTaskCommunityIds.len == 0:
          # Right now we're only emitting this signal when all download tasks have been marked as finished
          # so passing the `CommunityIdArgs` is not very useful because it'll always emit the latest community
          # id that has finished. We'll handle signals related to individual communities in the future
          # once we've figured out what this should look like in the UI
          #
          # TODO(pascal):
          # Don't just emit this signal when all communities are done downloading history data,
          # but implement a solution for individual updates
          self.events.emit(SIGNAL_COMMUNITY_HISTORY_ARCHIVES_DOWNLOAD_FINISHED, CommunityIdArgs(communityId: receivedData.communityId))

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

  proc findIndexBySymbol(symbol: string, tokenCriteria: seq[TokenCriteriaDto]): int =
    var idx = -1
    for tc in tokenCriteria:
      inc idx
      if(tc.symbol == symbol):
        return idx
    return -1

  proc findIndexById(id: string, categories: seq[Category]): int =
    var idx = -1
    for category in categories:
      inc idx
      if(category.id == id):
        return idx
    return -1

  proc findIndexBySymbol(symbol: string, tokens: seq[CommunityTokensMetadataDto]): int =
    var idx = -1
    for token in tokens:
      inc idx
      if(token.symbol == symbol):
        return idx
    return -1

  proc saveUpdatedCommunity(self: Service, community: var CommunityDto) =
    # Community data we get from the signals and responses don't contgain the pending requests
    # therefore, we must keep the old one
    community.pendingRequestsToJoin = self.communities[community.id].pendingRequestsToJoin
    community.declinedRequestsToJoin = self.communities[community.id].declinedRequestsToJoin
    community.canceledRequestsToJoin = self.communities[community.id].canceledRequestsToJoin

    # Update the joinded community list with the new data
    self.communities[community.id] = community

  proc getChatsInCategory(self: Service, community: var CommunityDto, categoryId: string): seq[ChatDto] =
    result = @[]
    for chat in community.chats:
      if (chat.categoryId == categoryId):
        # TODO: chat.id already contains community.id here but it was not expected, this requires investigation
        var chatDetails = self.chatService.getChatById(chat.id)
        result.add(chatDetails)

  proc handleCommunitiesSettingsUpdates(self: Service, communitiesSettings: seq[CommunitySettingsDto]) =
    for settings in communitiesSettings:
      if self.communities.hasKey(settings.id):
        self.communities[settings.id].settings = settings
        if self.communities[settings.id].joined:
          self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: self.communities[settings.id]))

  proc checkForCategoryPropertyUpdates(self: Service, community: CommunityDto, prev_community: CommunityDto) =
    for category in community.categories:
      # id is present
      let index = findIndexById(category.id, prev_community.categories)
      if index == -1:
        continue
      # but something is different
      let prev_category = prev_community.categories[index]

      if category.position != prev_category.position:
        self.events.emit(SIGNAL_COMMUNITY_CATEGORY_REORDERED,
          CommunityCategoryOrderArgs(
            communityId: community.id,
            categoryId: category.id,
            position: category.position))
      if category.name != prev_category.name:
        self.events.emit(SIGNAL_COMMUNITY_CATEGORY_NAME_EDITED,
          CommunityCategoryArgs(communityId: community.id, category: category))

    
  proc handleCommunityUpdates(self: Service, communities: seq[CommunityDto], updatedChats: seq[ChatDto], removedChats: seq[string]) =
    try:
      var community = communities[0]
      if not self.communities.hasKey(community.id):
        self.communities[community.id] = community
        self.events.emit(SIGNAL_COMMUNITY_ADDED, CommunityArgs(community: community))

        if (community.joined and community.isMember):
          self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: community, fromUserAction: false))
          # remove my pending requests
          keepIf(self.myCommunityRequests, request => request.communityId != community.id)

        return

      let prev_community = self.communities[community.id]

      # If there's settings without `id` it means the original
      # signal didn't include actual communitySettings, hence we
      # assign the settings we already have, otherwise we risk our
      # settings to be overridden with wrong defaults.
      if community.settings.id == "":
        community.settings = prev_community.settings

      var deletedCategories: seq[string] = @[]

      # category was added
      if(community.categories.len > prev_community.categories.len):
        for category in community.categories:
          if findIndexById(category.id, prev_community.categories) == -1:
            self.communities[community.id].categories.add(category)
            let chats = self.getChatsInCategory(community, category.id)

            self.events.emit(SIGNAL_COMMUNITY_CATEGORY_CREATED,
              CommunityCategoryArgs(communityId: community.id, category: category, chats: chats))

      # category was removed
      elif(community.categories.len < prev_community.categories.len):
        for prv_category in prev_community.categories:
          if findIndexById(prv_category.id, community.categories) == -1:
            deletedCategories.add(prv_category.id)
            self.events.emit(SIGNAL_COMMUNITY_CATEGORY_DELETED,
              CommunityCategoryArgs(communityId: community.id, category: Category(id: prv_category.id)))

      # some property has changed
      else:
        self.checkForCategoryPropertyUpdates(community, prev_community)

      # channel was added
      if(community.chats.len > prev_community.chats.len):
        for chat in community.chats:
          if findIndexById(chat.id, prev_community.chats) == -1:
            self.chatService.updateOrAddChat(chat) # we have to update chats stored in the chat service.
            let data = CommunityChatArgs(chat: chat)
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CREATED, data)

            # if the chat was created by the current user then it's already in the model and should be reordered if necessary
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED,
              CommunityChatOrderArgs(
                communityId: community.id,
                chat: chat,
              )
            )

      # channel was removed
      elif((community.chats.len-removedChats.len) < prev_community.chats.len):
        for prv_chat in prev_community.chats:
          if findIndexById(prv_chat.id, community.chats) == -1:
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_DELETED, CommunityChatIdArgs(communityId: community.id,
            chatId: prv_chat.id))
      # some property has changed
      else:
        for chat in community.chats:
          # id is present
          let index = findIndexById(chat.id, prev_community.chats)
          if index == -1:
            continue
          # but something is different
          let prev_chat = prev_community.chats[index]
          # Handle position changes
          if chat.position != prev_chat.position:
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_REORDERED,
              CommunityChatOrderArgs(
                communityId: community.id,
                chat: chat,
              )
            )

          # Handle channel was added/removed to/from category
          if chat.categoryId != prev_chat.categoryId:

            var prevCategoryDeleted = false
            if chat.categoryId == "":
              for catId in deletedCategories:
                if prev_chat.categoryId == catId:
                  prevCategoryDeleted = true
                  break

            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_CATEGORY_CHANGED,
              CommunityChatOrderArgs(
                communityId: community.id,
                chat: chat,
              )
            )

          # Handle name/description changes
          if chat.name != prev_chat.name or chat.description != prev_chat.description or chat.color != prev_chat.color or chat.emoji != prev_chat.emoji:
            var updatedChat = findChatById(chat.id, updatedChats)
            updatedChat.updateMissingFields(chat)
            self.chatService.updateOrAddChat(updatedChat) # we have to update chats stored in the chat service.

            let data = CommunityChatArgs(chat: updatedChat)
            self.events.emit(SIGNAL_COMMUNITY_CHANNEL_EDITED, data)

      # members list was changed
      if (community.isMember or community.tokenPermissions.len == 0) and community.members != prev_community.members:
        self.events.emit(SIGNAL_COMMUNITY_MEMBERS_CHANGED, 
        CommunityMembersArgs(communityId: community.id, members: community.members))

      # token metadata was added
      if community.communityTokensMetadata.len > prev_community.communityTokensMetadata.len:
        for tokenMetadata in community.communityTokensMetadata:
          if findIndexBySymbol(tokenMetadata.symbol, prev_community.communityTokensMetadata) == -1:
            self.communities[community.id].communityTokensMetadata.add(tokenMetadata)
            self.events.emit(SIGNAL_COMMUNITY_TOKEN_METADATA_ADDED,
                             CommunityTokenMetadataArgs(communityId: community.id,
                                                        tokenMetadata: tokenMetadata))

      # tokenPermission was added
      if community.tokenPermissions.len > prev_community.tokenPermissions.len:
        for id, tokenPermission in community.tokenPermissions:
          if not prev_community.tokenPermissions.hasKey(id):
            self.communities[community.id].tokenPermissions[id] = tokenPermission

            self.events.emit(SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATED,
            CommunityTokenPermissionArgs(communityId: community.id, tokenPermission: tokenPermission))
      elif community.tokenPermissions.len < prev_community.tokenPermissions.len:
        for id, prvTokenPermission in prev_community.tokenPermissions:
          if not community.tokenPermissions.hasKey(id):
            self.communities[community.id].tokenPermissions.del(id)
            self.events.emit(SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETED,
            CommunityTokenPermissionRemovedArgs(communityId: community.id, permissionId: id))

      else:
        for id, tokenPermission in community.tokenPermissions:
          if not prev_community.tokenPermissions.hasKey(id):
            continue

          let prevTokenPermission = prev_community.tokenPermissions[id]

          var permissionUpdated = false

          if tokenPermission.tokenCriteria.len != prevTokenPermission.tokenCriteria.len or
            tokenPermission.isPrivate != prevTokenPermission.isPrivate or
            tokenPermission.`type` != prevTokenPermission.`type`:

              permissionUpdated = true

          for tc in tokenPermission.tokenCriteria:
            let index = findIndexBySymbol(tc.symbol, prevTokenPermission.tokenCriteria)
            if index == -1:
              continue

            let prevTc = prevTokenPermission.tokenCriteria[index]
            if tc.amount != prevTc.amount or tc.ensPattern != prevTc.ensPattern:
              permissionUpdated = true
              break

          if permissionUpdated:
            self.events.emit(SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATED, 
              CommunityTokenPermissionArgs(communityId: community.id, tokenPermission: tokenPermission))

      let wasJoined = self.communities[community.id].joined

      self.saveUpdatedCommunity(community)

      # If the community was not joined before but is now, we signal it
      if(not wasJoined and community.joined and community.isMember):
        self.events.emit(SIGNAL_COMMUNITY_JOINED, CommunityArgs(community: community, fromUserAction: false))

      self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[community]))
      if wasJoined and not community.joined and not community.isMember:
        self.events.emit(SIGNAL_COMMUNITY_KICKED, CommunityArgs(community: community))
    
    except Exception as e:
      error "Error handling community updates", msg = e.msg

  proc init*(self: Service) =
    self.doConnect()

    try:
      let arg = AsyncLoadCommunitiesDataTaskArg(
        tptr: cast[ByteAddress](asyncLoadCommunitiesDataTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "asyncCommunitiesDataLoaded",
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error requesting communities data", msg = e.msg

  proc asyncCommunitiesDataLoaded(self: Service, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      if (responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != ""):
        error "error loading communities data", msg = responseObj{"error"}.getStr
        return

      # Tags
      var resultTags = newString(0)
      toUgly(resultTags, responseObj["tags"]["result"])
      self.communityTags = resultTags

      # All communities
      let communities = parseCommunities(responseObj["communities"])
      for community in communities:
        self.communities[community.id] = community
        if (community.admin):
          self.communities[community.id].pendingRequestsToJoin = self.pendingRequestsToJoinForCommunity(community.id)
          self.communities[community.id].declinedRequestsToJoin = self.declinedRequestsToJoinForCommunity(community.id)
          self.communities[community.id].canceledRequestsToJoin = self.canceledRequestsToJoinForCommunity(community.id)

      # Communities settings
      let communitiesSettings = parseCommunitiesSettings(responseObj["settings"])
      for settings in communitiesSettings:
        if self.communities.hasKey(settings.id):
          self.communities[settings.id].settings = settings

      # My pending requests
      let myPendingRequestResponse = responseObj["myPendingRequestsToJoin"]
      if myPendingRequestResponse{"result"}.kind != JNull:
        for jsonCommunityReqest in myPendingRequestResponse["result"]:
          let communityRequest = jsonCommunityReqest.toCommunityMembershipRequestDto()
          self.myCommunityRequests.add(communityRequest)

      self.events.emit(SIGNAL_COMMUNITY_DATA_LOADED, Args())
    except Exception as e:
      let errDesription = e.msg
      error "error loading all communities: ", errDesription

  proc getCommunityTags*(self: Service): string =
    return self.communityTags

  proc getJoinedCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.getFilteredJoinedCommunities().values)

  proc getAllCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.communities.values)

  proc getCuratedCommunities*(self: Service): seq[CommunityDto] =
    return toSeq(self.getFilteredCuratedCommunities.values)

  proc getCommunityById*(self: Service, communityId: string): CommunityDto =
    if communityId == "":
      return

    if not self.communities.hasKey(communityId):
      error "requested community doesn't exists", communityId
      return

    return self.communities[communityId]

  proc getCommunityIds*(self: Service): seq[string] =
    return toSeq(self.communities.keys)

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

  proc getCategoryById*(self: Service, communityId: string, categoryId: string): Category = 
    if(not self.communities.contains(communityId)):
      error "trying to get community categories for an unexisting community id"
      return

    let categories = self.communities[communityId].categories
    let categoryIndex = findIndexById(categoryId, categories)
    return categories[categoryIndex]

  proc getCategories*(self: Service, communityId: string, order: SortOrder = SortOrder.Ascending): seq[Category] =
    if(not self.communities.contains(communityId)):
      error "trying to get community categories for an unexisting community id"
      return

    result = self.communities[communityId].categories
    if(order == SortOrder.Ascending):
      result.sort(sortAsc[Category])
    else:
      result.sort(sortDesc[Category])

  proc getChats*(self: Service, communityId: string, categoryId = "", order = SortOrder.Ascending): seq[ChatDto] =
    ## By default returns chats which don't belong to any category, for passed `communityId`.
    ## If `categoryId` is set then only chats belonging to that category for passed `communityId` will be returned.
    ## Returned chats are sorted by position following set `order` parameter.
    if(not self.communities.contains(communityId)):
      error "trying to get community chats for an unexisting community id"
      return

    for chat in self.communities[communityId].chats:
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
    if(not self.communities.contains(communityId)):
      error "trying to get all community chats for an unexisting community id", communityId
      return

    result = self.communities[communityId].chats

    if(order == SortOrder.Ascending):
      result.sort(sortAsc[ChatDto])
    else:
      result.sort(sortDesc[ChatDto])

  proc isUserMemberOfCommunity*(self: Service, communityId: string): bool =
    if(not self.communities.contains(communityId)):
      return false
    return self.communities[communityId].joined and self.communities[communityId].isMember

  proc isUserSpectatingCommunity*(self: Service, communityId: string): bool =
    if(not self.communities.contains(communityId)):
      return false
    return self.communities[communityId].spectated

  proc userCanJoin*(self: Service, communityId: string): bool =
    if(not self.communities.contains(communityId)):
      return false
    return self.communities[communityId].canJoin

  proc processRequestsToJoinCommunity(self: Service, responseResult: JsonNode): bool =
    if responseResult{"requestsToJoinCommunity"} == nil or responseResult{"requestsToJoinCommunity"}.kind == JNull:
      return false

    for jsonCommunityReqest in responseResult["requestsToJoinCommunity"]:
      let communityRequest = jsonCommunityReqest.toCommunityMembershipRequestDto()
      self.myCommunityRequests.add(communityRequest)
      self.events.emit(SIGNAL_COMMUNITY_MY_REQUEST_ADDED, CommunityRequestArgs(communityRequest: communityRequest))

    return true

  proc spectateCommunity*(self: Service, communityId: string): string =
    result = ""
    try:
      if (self.isUserSpectatingCommunity(communityId) or self.isUserMemberOfCommunity(communityId)):
        return

      let response = status_go.spectateCommunity(communityId)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error joining community: " & error.message)

      if response.result == nil or response.result.kind == JNull:
        error "error: ", procName="spectateCommunity", errDesription = "result is nil"
        return

      if not response.result.hasKey("communities") or response.result["communities"].kind != JArray or response.result["communities"].len == 0:
        error "error: ", procName="spectateCommunity", errDesription = "no 'communities' key in response"
        return

      if not response.result.hasKey("communitiesSettings") or response.result["communitiesSettings"].kind != JArray or response.result["communitiesSettings"].len == 0:
        error "error: ", procName="spectateCommunity", errDesription = "no 'communitiesSettings' key in response"
        return

      var updatedCommunity = response.result["communities"][0].toCommunityDto()
      let communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()

      updatedCommunity.settings = communitySettings
      self.communities[communityId] = updatedCommunity
      self.chatService.loadChannelGroupById(communityId)

      self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[updatedCommunity]))
      self.events.emit(SIGNAL_COMMUNITY_SPECTATED, CommunityArgs(community: updatedCommunity, fromUserAction: true))

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
        self.messageService.asyncLoadInitialMessagesForChat(fullChatId)
    except Exception as e:
      error "Error joining the community", msg = e.msg
      result = fmt"Error joining the community: {e.msg}"

  proc canceledRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto] =
    try:
      let response = status_go.canceledRequestsToJoinForCommunity(communityId)

      result = @[]
      if response.result.kind != JNull:
        for jsonCommunityReqest in response.result:
          result.add(jsonCommunityReqest.toCommunityMembershipRequestDto())
    except Exception as e:
      error "Error fetching community requests", msg = e.msg

  proc pendingRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto] =
    try:
      let response = status_go.pendingRequestsToJoinForCommunity(communityId)

      result = @[]
      if response.result.kind != JNull:
        for jsonCommunityReqest in response.result:
          result.add(jsonCommunityReqest.toCommunityMembershipRequestDto())
    except Exception as e:
      error "Error fetching community requests", msg = e.msg

  proc declinedRequestsToJoinForCommunity*(self: Service, communityId: string): seq[CommunityMembershipRequestDto] =
    try:
      let response = status_go.declinedRequestsToJoinForCommunity(communityId)

      result = @[]
      if response.result.kind != JNull:
        for jsonCommunityReqest in response.result:
          result.add(jsonCommunityReqest.toCommunityMembershipRequestDto())
    except Exception as e:
      error "Error fetching community declined requests", msg = e.msg

  proc leaveCommunity*(self: Service, communityId: string) =
    try:
      let response = status_go.leaveCommunity(communityId)
      self.activityCenterService.parseActivityCenterResponse(response)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error leaving community: " & error.message)

      if response.result == nil or response.result.kind == JNull:
        error "error: ", procName="leaveCommunity", errDesription = "result is nil"
        return

      # Update community so that joined, member list and isMember are updated
      let updatedCommunity = response.result["communities"][0].toCommunityDto()
      self.communities[communityId] = updatedCommunity
      self.events.emit(SIGNAL_COMMUNITIES_UPDATE, CommunitiesArgs(communities: @[updatedCommunity]))

      for chat in updatedCommunity.chats:
        self.messageService.resetMessageCursor(chat.id)

      # remove related community requests
      keepIf(self.myCommunityRequests, request => request.communityId != communityId)

      self.events.emit(SIGNAL_COMMUNITY_LEFT, CommunityIdArgs(communityId: communityId))

    except Exception as e:
      error "Error leaving community", msg = e.msg, communityId

  proc requestImportDiscordCommunity*(
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
      pinMessageAllMembersEnabled: bool,
      filesToImport: seq[string],
      fromTimestamp: int) =
    try:
      var image = singletonInstance.utils.formatImagePath(imageUrl)
      var tagsString = tags
      if len(tagsString) == 0:
        tagsString = "[]"

      let response = status_go.requestImportDiscordCommunity(
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
        pinMessageAllMembersEnabled,
        filesToImport,
        fromTimestamp)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community: " & error.message)

    except Exception as e:
      error "Error creating community", msg = e.msg

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
      pinMessageAllMembersEnabled: bool,
      bannerJsonStr: string) =
    try:
      var bannerJson = bannerJsonStr.parseJson
      bannerJson{"imagePath"} = newJString(singletonInstance.utils.formatImagePath(bannerJson["imagePath"].getStr))
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
        singletonInstance.utils.formatImagePath(imageUrl),
        aX, aY, bX, bY,
        historyArchiveSupportEnabled,
        pinMessageAllMembersEnabled,
        $bannerJson)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        var community = response.result["communities"][0].toCommunityDto()
        let communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()


        community.settings = communitySettings
        # add this to the communities list and communitiesSettings
        self.communities[community.id] = community
        # add new community channel group and chats to chat service
        self.chatService.updateOrAddChannelGroup(community.toChannelGroupDto())
        for chat in community.chats: 
          self.chatService.updateOrAddChat(chat)

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
      var bannerJson = bannerJsonStr.parseJson
      bannerJson{"imagePath"} = newJString(singletonInstance.utils.formatImagePath(bannerJson["imagePath"].getStr))
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
        singletonInstance.utils.formatImagePath(logoJson["imagePath"].getStr()),
        int(cropRectJson["x"].getFloat()),
        int(cropRectJson["y"].getFloat()),
        int(cropRectJson["x"].getFloat() + cropRectJson["width"].getFloat()),
        int(cropRectJson["y"].getFloat() + cropRectJson["height"].getFloat()),
        $bannerJson,
        historyArchiveSupportEnabled,
        pinMessageAllMembersEnabled)

      if response.error != nil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error editing community: " & error.message)

      if response.result != nil and response.result.kind != JNull:
        var community = response.result["communities"][0].toCommunityDto()
        var communitySettings = response.result["communitiesSettings"][0].toCommunitySettingsDto()

        community.settings = communitySettings
        self.saveUpdatedCommunity(community)
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
      let response = status_go.createCommunityChannel(communityId, name, description, emoji, color, categoryId)

      if not response.error.isNil:
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, "Error creating community channel: " & error.message)

      if response.result.isNil or response.result.kind == JNull:
        error "response is invalid", procName="createCommunityChannel"

      var chatsJArr: JsonNode
      if(not response.result.getProp("chats", chatsJArr)):
        raise newException(RpcException, fmt"createCommunityChannel; there is no `chats` key in the response for community id: {communityId}")

      let chatsForCategory = self.getChats(communityId, categoryId)
      let maxPosition = if chatsForCategory.len > 0: chatsForCategory[^1].position else: -1

      for chatObj in chatsJArr:
        var chatDto = chatObj.toChatDto(communityId)
        chatDto.position = maxPosition + 1
        self.chatService.updateOrAddChat(chatDto)
        self.communities[communityId].chats.add(chatDto)
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
        return

      let updatedCommunity = response.result["communities"][0].toCommunityDto()

      var updatedChats: seq[ChatDto] = @[]
      for chat in updatedCommunity.chats:
        let prev_chat_idx = findIndexById(chat.id, self.communities[communityId].chats)
        if prev_chat_idx == -1:
          continue
        let prev_chat = self.communities[communityId].chats[prev_chat_idx]

        # we are free to do this cause channel must be created before we add it to a category
        var chatDetails = self.chatService.getChatById(chat.id)

        if(chat.position != prev_chat.position and chat.categoryId == categoryId):
          self.communities[communityId].chats[prev_chat_idx].position = chat.position
        elif chat.categoryId != prev_chat.categoryId:
          self.communities[communityId].chats[prev_chat_idx].categoryId = chat.categoryId
        else:
          continue

        chatDetails.updateMissingFields(self.communities[communityId].chats[prev_chat_idx])
        self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
        updatedChats.add(chat)
    
      self.events.emit(SIGNAL_COMMUNITY_CHANNELS_REORDERED,
        CommunityChatsOrderArgs(communityId: updatedCommunity.id, chats: updatedChats))

      self.communities[communityId] = updatedCommunity
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

      let idx = findIndexById(chatId, self.communities[communityId].chats)
      if (idx != -1):
        self.communities[communityId].chats.delete(idx)

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
        self.checkForCategoryPropertyUpdates(
          response.result["communityChanges"].getElems()[0]["community"].toCommunityDto,
          self.communities[communityId]
        )

        var chats: seq[ChatDto] = @[]
        for chatId, v in response.result["communityChanges"].getElems()[0]["chatsModified"].pairs():
          let fullChatId = communityId & chatId
          let idx = findIndexById(fullChatId, self.communities[communityId].chats)
          if idx > -1:
            self.communities[communityId].chats[idx].categoryId = v["CategoryModified"].getStr()
            self.communities[communityId].chats[idx].position = v["PositionModified"].getInt()
            if self.communities[communityId].chats[idx].categoryId.len > 0:
              var chatDetails = self.chatService.getChatById(fullChatId) # we are free to do this cause channel must be created before we add it to a category
              chatDetails.updateMissingFields(self.communities[communityId].chats[idx])
              self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
              chats.add(chatDetails)

        for k, v in response.result["communityChanges"].getElems()[0]["categoriesAdded"].pairs():
          let category = v.toCategory()
          self.communities[communityId].categories.add(category)
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
          let idx = findIndexById(fullChatId, self.communities[communityId].chats)
          if idx > -1:
            self.communities[communityId].chats[idx].categoryId = v["CategoryModified"].getStr()
            self.communities[communityId].chats[idx].position = v["PositionModified"].getInt()

            var chatDetails = self.chatService.getChatById(fullChatId) # we are free to do this cause channel must be created before we add it to a category
            chatDetails.updateMissingFields(self.communities[communityId].chats[idx])
            self.chatService.updateOrAddChat(chatDetails) # we have to update chats stored in the chat service.
            chats.add(chatDetails)

        # Update communities objects
        var updatedCommunity = response.result["communities"][0].toCommunityDto
        self.checkForCategoryPropertyUpdates(
          updatedCommunity,
          self.communities[communityId]
        )

        self.saveUpdatedCommunity(updatedCommunity)

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

      # Update communities objects
      var updatedCommunity = response.result["communities"][0].toCommunityDto

      self.checkForCategoryPropertyUpdates(
        updatedCommunity,
        self.communities[communityId]
      )

      self.saveUpdatedCommunity(updatedCommunity)

      self.events.emit(SIGNAL_COMMUNITY_CATEGORY_DELETED,
        CommunityCategoryArgs(
          communityId: communityId,
          category: Category(id: categoryId),
          chats: updatedCommunity.chats
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

      let updatedCommunity = response.result["communities"][0].toCommunityDto()
      # Update community categories
      self.checkForCategoryPropertyUpdates(updatedCommunity, self.communities[communityId])
      self.communities[communityId].categories = updatedCommunity.categories
    except Exception as e:
      error "Error reordering category channel", msg = e.msg, communityId, categoryId, position


  proc asyncCommunityInfoLoaded*(self: Service, communityIdAndRpcResponse: string) {.slot.} =
    let rpcResponseObj = communityIdAndRpcResponse.parseJson
    if (rpcResponseObj{"error"}.kind != JNull):
      error "Error requesting community info", msg = rpcResponseObj{"error"}
      return

    var community = rpcResponseObj{"response"}{"result"}.toCommunityDto()
    let requestedCommunityId = rpcResponseObj{"communityId"}.getStr()
    self.requestedCommunityIds.excl(requestedCommunityId)

    if community.id == "":
      community.id = requestedCommunityId
      self.events.emit(SIGNAL_COMMUNITY_LOAD_DATA_FAILED, CommunityArgs(community: community, error: "Couldn't find community info"))
      return
    
    self.communities[community.id] = community

    if rpcResponseObj{"importing"}.getBool():
      self.events.emit(SIGNAL_COMMUNITY_IMPORTED, CommunityArgs(community: community))

    self.events.emit(SIGNAL_COMMUNITY_DATA_IMPORTED, CommunityArgs(community: community))

  proc asyncRequestToJoinCommunity*(self: Service, communityId: string, ensName: string, password: string) =
    try:
      let arg = AsyncRequestToJoinCommunityTaskArg(
        tptr: cast[ByteAddress](asyncRequestToJoinCommunityTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncRequestToJoinCommunityDone",
        communityId: communityId,
        ensName: ensName,
        password: password
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error request to join community", msg = e.msg 
    
  proc onAsyncRequestToJoinCommunityDone*(self: Service, communityIdAndRpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = communityIdAndRpcResponse.parseJson
      if (rpcResponseObj{"response"}{"error"}.kind != JNull):
        let error = Json.decode($rpcResponseObj["response"]["error"], RpcError)
        error "Error requesting community info", msg = error.message
        return

      let communityId = rpcResponseObj{"communityId"}.getStr()
      let rpcResponse = Json.decode($rpcResponseObj["response"], RpcResponse[JsonNode])
      self.activityCenterService.parseActivityCenterResponse(rpcResponse)
      
      if not self.processRequestsToJoinCommunity(rpcResponse.result):
        error "error: ", procName="onAsyncRequestToJoinCommunityDone", errDesription = "no 'requestsToJoinCommunity' key in response"

    except Exception as e:
      error "Error requesting to join the community", msg = e.msg

  proc asyncAcceptRequestToJoinCommunity*(self: Service, communityId: string, requestId: string) =
    try:
      let userKey = self.getUserPubKeyFromPendingRequest(communityId, requestId)
      self.events.emit(SIGNAL_ACCEPT_REQUEST_TO_JOIN_LOADING, CommunityMemberArgs(communityId: communityId, pubKey: userKey))
      let arg = AsyncAcceptRequestToJoinCommunityTaskArg(
        tptr: cast[ByteAddress](asyncAcceptRequestToJoinCommunityTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncAcceptRequestToJoinCommunityDone",
        communityId: communityId,
        requestId: requestId
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error accepting request to join community", msg = e.msg 

  proc onAsyncAcceptRequestToJoinCommunityDone*(self: Service, response: string) {.slot.} =
    var communityId: string
    var requestId: string
    var userKey: string
    try:
      let rpcResponseObj = response.parseJson
      communityId = rpcResponseObj{"communityId"}.getStr
      requestId = rpcResponseObj{"requestId"}.getStr
      userKey = self.getUserPubKeyFromPendingRequest(communityId, requestId)
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        let errorMessage = rpcResponseObj{"error"}.getStr

        if errorMessage.contains("has no permission to join"):
          self.events.emit(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED_NO_PERMISSION, CommunityMemberArgs(communityId: communityId, pubKey: userKey, requestId: requestId))
        else:
          self.events.emit(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED, CommunityMemberArgs(communityId: communityId, pubKey: userKey, requestId: requestId))
        return
    
      discard self.removeMembershipRequestFromCommunityAndGetMemberPubkey(communityId, requestId,
        rpcResponseObj["response"]["result"]["communities"][0].toCommunityDto)

      if (userKey == ""):
        error "Did not find pubkey in the pending request"
        return

      self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: self.communities[communityId]))
      self.events.emit(SIGNAL_COMMUNITY_MEMBER_APPROVED, CommunityMemberArgs(communityId: communityId, pubKey: userKey, requestId: requestId))
      self.activityCenterService.parseActivityCenterNotifications(rpcResponseObj["response"]["result"]["activityCenterNotifications"])

    except Exception as e:
      let errMsg = e.msg
      error "error accepting request to join: ", errMsg
      self.events.emit(SIGNAL_ACCEPT_REQUEST_TO_JOIN_FAILED, CommunityMemberArgs(communityId: communityId, pubKey: userKey, requestId: requestId))

  proc asyncLoadCuratedCommunities*(self: Service) =
    self.events.emit(SIGNAL_CURATED_COMMUNITIES_LOADING, Args())
    try:
      let arg = AsyncLoadCuratedCommunitiesTaskArg(
        tptr: cast[ByteAddress](asyncLoadCuratedCommunitiesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "onAsyncLoadCuratedCommunitiesDone",
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error loading curated communities", msg = e.msg 

  proc onAsyncLoadCuratedCommunitiesDone*(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson
      if (rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != ""):
        error "Error requesting community info", msg = rpcResponseObj{"error"}.getStr
        self.events.emit(SIGNAL_CURATED_COMMUNITIES_LOADING_FAILED, Args())
        return
      let curatedCommunities = parseCuratedCommunities(rpcResponseObj["response"]["result"])
      for curatedCommunity in curatedCommunities:
        self.communities[curatedCommunity.id] = curatedCommunity
      self.events.emit(SIGNAL_CURATED_COMMUNITIES_LOADED, CommunitiesArgs(communities: self.getCuratedCommunities()))
    except Exception as e:
      let errMsg = e.msg
      error "error loading curated communities: ", errMsg
      self.events.emit(SIGNAL_CURATED_COMMUNITIES_LOADING_FAILED, Args())

  proc requestCommunityInfo*(self: Service, communityId: string, importing = false) =

    if communityId in self.requestedCommunityIds:
      info "requestCommunityInfo: skipping as already requested", communityId
      self.events.emit(SIGNAL_COMMUNITY_INFO_ALREADY_REQUESTED, Args())
      return

    self.requestedCommunityIds.incl(communityId)

    let arg = AsyncRequestCommunityInfoTaskArg(
      tptr: cast[ByteAddress](asyncRequestCommunityInfoTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncCommunityInfoLoaded",
      communityId: communityId,
      importing: importing
    )
    self.threadpool.start(arg)

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
      self.communities[communityDto.id] = communityDto

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

  proc speedupArchivesImport*() =
    try:
      let response = status_go.speedupArchivesImport()
      if (response.error != nil):
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, fmt"err: {error.message}")
    except Exception as e:
      error "Error speeding up archives import: ", msg = e.msg

  proc slowdownArchivesImport*() =
    try:
      let response = status_go.slowdownArchivesImport()
      if (response.error != nil):
        let error = Json.decode($response.error, RpcError)
        raise newException(RpcException, fmt"err: {error.message}")
    except Exception as e:
      error "Error slowing down archives import: ", msg = e.msg

  proc getPendingRequestIndex(self: Service, communityId: string, requestId: string): int =
    let community = self.communities[communityId]
    var i = 0
    for pendingRequest in community.pendingRequestsToJoin:
      if (pendingRequest.id == requestId):
        return i
      i.inc()
    return -1

  proc getDeclinedRequestIndex(self: Service, communityId: string, requestId: string): int =
    let community = self.communities[communityId]
    var i = 0
    for declinedRequest in community.declinedRequestsToJoin:
      if (declinedRequest.id == requestId):
        return i
      i.inc()
    return -1

  proc removeMembershipRequestFromCommunityAndGetMemberPubkey*(self: Service, communityId: string, requestId: string,
      updatedCommunity: CommunityDto): string =
    let indexPending = self.getPendingRequestIndex(communityId, requestId)
    let indexDeclined = self.getDeclinedRequestIndex(communityId, requestId)

    if (indexPending == -1 and indexDeclined == -1):
      raise newException(RpcException, fmt"Community request not found: {requestId}")

    var community = self.communities[communityId]

    if (indexPending != -1):
      result = community.pendingRequestsToJoin[indexPending].publicKey
      community.pendingRequestsToJoin.delete(indexPending)
    elif (indexDeclined != -1):
      result = community.declinedRequestsToJoin[indexDeclined].publicKey
      community.declinedRequestsToJoin.delete(indexDeclined)

    community.members = updatedCommunity.members
    self.communities[communityId] = community

  proc moveRequestToDeclined*(self: Service, communityId: string, requestId: string) =
    let indexPending = self.getPendingRequestIndex(communityId, requestId)
    if (indexPending == -1):
      raise newException(RpcException, fmt"Community request not found: {requestId}")

    var community = self.communities[communityId]

    let itemToMove = community.pendingRequestsToJoin[indexPending]
    community.declinedRequestsToJoin.add(itemToMove)
    community.pendingRequestsToJoin.delete(indexPending)

    self.communities[communityId] = community

  proc cancelRequestToJoinCommunity*(self: Service, communityId: string) =
    try:
      var i = 0
      for communityRequest in self.myCommunityRequests:
        if (communityRequest.communityId == communityId):
          let response = status_go.cancelRequestToJoinCommunity(communityRequest.id)
          if (not response.error.isNil):
            let msg = response.error.message & " communityId=" & communityId
            error "error while cancel membership request ", msg
            return
          self.myCommunityRequests.delete(i)
          self.activityCenterService.parseActivityCenterResponse(response)
          self.events.emit(SIGNAL_REQUEST_TO_JOIN_COMMUNITY_CANCELED, Args())
          return

        i.inc()
      
    except Exception as e:
      error "Error canceled request to join community", msg = e.msg

  proc declineRequestToJoinCommunity*(self: Service, communityId: string, requestId: string) =
    try:
      let response = status_go.declineRequestToJoinCommunity(requestId)
      self.activityCenterService.parseActivityCenterResponse(response)

      self.moveRequestToDeclined(communityId, requestId)

      self.events.emit(SIGNAL_COMMUNITY_EDITED, CommunityArgs(community: self.communities[communityId]))
    except Exception as e:
      error "Error declining request to join community", msg = e.msg

  proc inviteUsersToCommunityById*(self: Service, communityId: string, pubKeysJson: string, inviteMessage: string): string =
    try:
      let pubKeysParsed = pubKeysJson.parseJson
      var pubKeys: seq[string] = @[]
      for pubKey in pubKeysParsed:
        pubKeys.add(pubKey.getStr)
      # We no longer send invites, but merely share the community so
      # users can request access (with automatic acception)
      let response = status_go.shareCommunityToUsers(communityId, pubKeys, inviteMessage)
      discard self.chatService.processMessageUpdateAfterSend(response)
    except Exception as e:
      error "Error sharing community", msg = e.msg
      result = "Error sharing community: " & e.msg

  proc muteCategory*(self: Service, communityId: string, categoryId: string, interval: int) =
    try:
      let response = status_go.muteCategory(communityId, categoryId, interval)
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

  proc unbanUserFromCommunity*(self: Service, communityId: string, pubKey: string)  =
    try:
      discard status_go.unbanUserFromCommunity(communityId, pubKey)
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

  proc requestExtractDiscordChannelsAndCategories*(self: Service, filesToImport: seq[string]) =
    try:
      discard status_go.requestExtractDiscordChannelsAndCategories(filesToImport)
    except Exception as e:
      error "Error extracting discord channels and categories", msg = e.msg

  proc requestCancelDiscordCommunityImport*(self: Service, communityId: string) =
    try:
      discard status_go.requestCancelDiscordCommunityImport(communityId)
    except Exception as e:
      error "Error extracting discord channels and categories", msg = e.msg

  proc createOrEditCommunityTokenPermission*(self: Service, communityId: string, tokenPermission: CommunityTokenPermissionDto) =
    try:
      let editing = tokenPermission.id != ""

      var response: RpcResponse[JsonNode]

      if editing:
        response = status_go.editCommunityTokenPermission(communityId, tokenPermission.id, int(tokenPermission.`type`), Json.encode(tokenPermission.tokenCriteria), tokenPermission.isPrivate)
      else:
        response = status_go.createCommunityTokenPermission(communityId, int(tokenPermission.`type`), Json.encode(tokenPermission.tokenCriteria), tokenPermission.isPrivate)

      if response.result != nil and response.result.kind != JNull:
        var changesField = TOKEN_PERMISSIONS_ADDED
        if editing:
          changesField = TOKEN_PERMISSIONS_MODIFIED

        for permissionId, permission in response.result["communityChanges"].getElems()[0][changesField].pairs():
          let p = permission.toCommunityTokenPermissionDto()
          self.communities[communityId].tokenPermissions[permissionId] = p

          var signal = SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATED
          if editing:
            signal = SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATED

          self.events.emit(signal, CommunityTokenPermissionArgs(communityId: communityId, tokenPermission: p))
        return

      var signal = SIGNAL_COMMUNITY_TOKEN_PERMISSION_CREATION_FAILED
      if editing:
        signal = SIGNAL_COMMUNITY_TOKEN_PERMISSION_UPDATE_FAILED

      self.events.emit(signal, CommunityTokenPermissionArgs(communityId: communityId, tokenPermission: tokenPermission))
    except Exception as e:
      error "Error creating/editing community token permission", msg = e.msg

  proc deleteCommunityTokenPermission*(self: Service, communityId: string, permissionId: string) =
    try:
      let response = status_go.deleteCommunityTokenPermission(communityId, permissionId)
      if response.result != nil and response.result.kind != JNull:
        for permissionId in response.result["communityChanges"].getElems()[0]["tokenPermissionsRemoved"].getElems():
          if self.communities[communityId].tokenPermissions.hasKey(permissionId.getStr()):
            self.communities[communityId].tokenPermissions.del(permissionId.getStr())
          self.events.emit(SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETED,
        CommunityTokenPermissionRemovedArgs(communityId: communityId, permissionId: permissionId.getStr))
        return
      var tokenPermission = CommunityTokenPermissionDto()
      tokenPermission.id = permissionId
      self.events.emit(SIGNAL_COMMUNITY_TOKEN_PERMISSION_DELETION_FAILED,
        CommunityTokenPermissionArgs(communityId: communityId, tokenPermission: tokenPermission))
    except Exception as e:
      error "Error deleting community token permission", msg = e.msg

  proc getUserPubKeyFromPendingRequest*(self: Service, communityId: string, requestId: string): string =
    let indexPending = self.getPendingRequestIndex(communityId, requestId)
    if (indexPending == -1):
      raise newException(RpcException, fmt"Community request not found: {requestId}")

    let community = self.communities[communityId]
    return community.pendingRequestsToJoin[indexPending].publicKey
