import NimQml, strutils, sequtils, sugar, tables, stint, chronicles, json

import ./io_interface
import ../io_interface as delegate_interface
import ./view, ./controller
import ./models/curated_community_item
import ./models/curated_community_model
import ./models/discord_category_item
import ./models/discord_categories_model
import ./models/discord_channel_item
import ./models/discord_channels_model
import ./models/discord_file_list_model
import ./models/discord_import_task_item
import ./models/discord_import_tasks_model
import app/modules/shared_models/[member_item, section_model, section_item, token_permissions_model, token_permission_item,
  token_list_item, token_list_model, token_criteria_item, token_criteria_model, token_permission_chat_list_model, keypair_model]
import app/global/global_singleton
import app/core/eventemitter
import app_service/common/types
import app_service/common/utils as common_utils
import app_service/service/community/service as community_service
import app_service/service/contacts/service as contacts_service
import app_service/service/chat/service as chat_service
import app_service/service/network/service as networks_service
import app_service/service/transaction/service as transaction_service
import app_service/service/community_tokens/service as community_tokens_service
import app_service/service/token/service as token_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/chat/dto/chat
import app_service/service/keycard/service as keycard_service
import ./tokens/module as community_tokens_module

import app/modules/shared/keypairs

export io_interface

type
  ImportCommunityState {.pure.} = enum
    Imported = 0
    ImportingInProgress
    ImportingError
    ImportingCanceled

type
  Action {.pure.} = enum
    None = 0,
    JoinCommunity
    EditSharedAddresses

type
  AddressToShareDetails = object
    keyUid: string
    address: string
    path: string
    isAirdropAddress: bool
    messageToBeSigned: string
    signature: string

type
  JoiningCommunityDetails = object
    communityId: string
    communityIdForChannelsPermisisons: string
    communityIdForRevealedAccounts: string
    ensName: string
    addressesToShare: OrderedTable[string, AddressToShareDetails] ## [address, AddressToShareDetails]
    profilePassword: string
    profilePin: string
    action: Action

proc clear(self: var JoiningCommunityDetails) =
  self = JoiningCommunityDetails()

proc allSigned(self: JoiningCommunityDetails): bool =
  for _, details in self.addressesToShare.pairs:
    if details.signature.len == 0:
      return false
  return true

type
  Module*  = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    curatedCommunitiesLoaded: bool
    communityTokensModule: community_tokens_module.AccessInterface
    checkingPermissionToJoinInProgress: bool
    checkingAllChannelPermissionsInProgress: bool
    joiningCommunityDetails: JoiningCommunityDetails

# Forward declaration
method setCommunityTags*(self: Module, communityTags: string)
method setAllCommunities*(self: Module, communities: seq[CommunityDto])
method setCuratedCommunities*(self: Module, curatedCommunities: seq[CommunityDto])

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    communityService: community_service.Service,
    contactsService: contacts_service.Service,
    communityTokensService: community_tokens_service.Service,
    networksService: networks_service.Service,
    transactionService: transaction_service.Service,
    tokensService: token_service.Service,
    chatService: chat_service.Service,
    walletAccountService: wallet_account_service.Service,
    keycardService: keycard_service.Service,
    ): Module =
  result = Module()
  result.delegate = delegate
  result.view = newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    communityService,
    contactsService,
    communityTokensService,
    networksService,
    tokensService,
    chatService,
    walletAccountService,
    keycardService,
  )
  result.communityTokensModule = community_tokens_module.newCommunityTokensModule(result, events, communityTokensService, transactionService, networksService, communityService)
  result.moduleLoaded = false
  result.curatedCommunitiesLoaded = false
  result.checkingPermissionToJoinInProgress = false
  result.checkingAllChannelPermissionsInProgress = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  self.communityTokensModule.delete

proc clean(self: Module) =
  self.joiningCommunityDetails.clear()

method load*(self: Module) =
  singletonInstance.engine.setRootContextProperty("communitiesModule", self.viewVariant)
  self.controller.init()
  self.communityTokensModule.load()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true

  self.delegate.communitiesModuleDidLoad()

method communityDataLoaded*(self: Module) =
  self.setCommunityTags(self.controller.getCommunityTags())
  self.setAllCommunities(self.controller.getAllCommunities())
  # Get all community tokens to construct the original list of collectibles and assets from communities
  self.controller.getAllCommunityTokensAsync()

method onActivated*(self: Module) =
  self.controller.asyncLoadCuratedCommunities()

method curatedCommunitiesLoaded*(self: Module, curatedCommunities: seq[CommunityDto]) =
  self.curatedCommunitiesLoaded = true
  self.setCuratedCommunities(curatedCommunities)
  self.view.setCuratedCommunitiesLoading(false)

method curatedCommunitiesLoading*(self: Module) =
  self.view.setCuratedCommunitiesLoading(true)

method curatedCommunitiesLoadingFailed*(self: Module) =
  # TODO we probably want to show an error in the UI later
  self.curatedCommunitiesLoaded = true
  self.view.setCuratedCommunitiesLoading(false)

proc createMemberItem(self: Module, memberId, requestId: string, status: MembershipRequestState): MemberItem =
  let contactDetails = self.controller.getContactDetails(memberId)
  result = initMemberItem(
    pubKey = memberId,
    displayName = contactDetails.dto.displayName,
    ensName = contactDetails.dto.name,
    isEnsVerified = contactDetails.dto.ensVerified,
    localNickname = contactDetails.dto.localNickname,
    alias = contactDetails.dto.alias,
    icon = contactDetails.icon,
    colorId = contactDetails.colorId,
    colorHash = contactDetails.colorHash,
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(memberId).statusType),
    isContact = contactDetails.dto.isContact,
    isVerified = contactDetails.dto.isContactVerified(),
    requestToJoinId = requestId,
    membershipRequestState = status,
  )

method getCommunityItem(self: Module, c: CommunityDto): SectionItem =
  # TODO: unite bannedMembers, pendingMemberRequests and declinedMemberRequests
  var members: seq[MemberItem] = @[]
  for member in c.members:
    if c.pendingAndBannedMembers.hasKey(member.id):
      let communityMemberState = c.pendingAndBannedMembers[member.id]
      members.add(self.createMemberItem(member.id, "", toMembershipRequestState(communityMemberState)))

  var bannedMembers: seq[MemberItem] = @[]
  for memberId, communityMemberState in c.pendingAndBannedMembers:
    bannedMembers.add(self.createMemberItem(memberId, "", toMembershipRequestState(communityMemberState)))

  return initItem(
      c.id,
      SectionType.Community,
      c.name,
      c.memberRole,
      c.isControlNode,
      c.description,
      c.introMessage,
      c.outroMessage,
      c.images.thumbnail,
      c.images.banner,
      icon = "",
      c.color,
      c.tags,
      hasNotification = false,
      notificationsCount = 0,
      active = false,
      enabled = true,
      c.joined,
      c.canJoin,
      c.spectated,
      c.canManageUsers,
      c.canRequestAccess,
      c.isMember,
      c.permissions.access,
      c.permissions.ensOnly,
      c.muted,
      members = members,
      historyArchiveSupportEnabled = c.settings.historyArchiveSupportEnabled,
      bannedMembers = bannedMembers,
      pendingMemberRequests = c.pendingRequestsToJoin.map(proc(requestDto: CommunityMembershipRequestDto): MemberItem =
        result = self.createMemberItem(requestDto.publicKey, requestDto.id, MembershipRequestState(requestDto.state))),
      declinedMemberRequests = c.declinedRequestsToJoin.map(proc(requestDto: CommunityMembershipRequestDto): MemberItem =
        result = self.createMemberItem(requestDto.publicKey, requestDto.id, MembershipRequestState(requestDto.state))),
      encrypted = c.encrypted,
      communityTokens = @[]
    )

proc getCuratedCommunityItem(self: Module, community: CommunityDto): CuratedCommunityItem =
  var tokenPermissionsItems: seq[TokenPermissionItem] = @[]

  for id, tokenPermission in community.tokenPermissions:
    let chats = community.getCommunityChats(tokenPermission.chatIds)
    let tokenPermissionItem = buildTokenPermissionItem(tokenPermission, chats)
    tokenPermissionsItems.add(tokenPermissionItem)

  return initCuratedCommunityItem(
    community.id,
    community.name,
    community.description,
    community.isAvailable,
    community.images.thumbnail,
    community.images.banner,
    community.color,
    community.tags,
    len(community.members),
    int(community.activeMembersCount),
    community.featuredInDirectory,
    tokenPermissionsItems,
  )

proc getDiscordCategoryItem(self: Module, c: DiscordCategoryDto): DiscordCategoryItem =
  return initDiscordCategoryItem(
      c.id,
      c.name,
      true)

proc getDiscordChannelItem(self: Module, c: DiscordChannelDto): DiscordChannelItem =
  return initDiscordChannelItem(
      c.id,
      c.categoryId,
      c.name,
      c.description,
      c.filePath,
      true)

method setCommunityTags*(self: Module, communityTags: string) =
  self.view.setCommunityTags(communityTags)

method setAllCommunities*(self: Module, communities: seq[CommunityDto]) =
  for community in communities:
    self.view.addItem(self.getCommunityItem(community))

method communityAdded*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))

method spectateCommunity*(self: Module, communityId: string): string =
  self.controller.spectateCommunity(communityId)

method navigateToCommunity*(self: Module, communityId: string) =
  let community = self.view.model().getItemById(communityId)
  if community.isEmpty() or not (community.spectated() or community.joined()):
    discard self.controller.spectateCommunity(communityId)
  else:
    self.delegate.setActiveSectionById(communityId)

method communityEdited*(self: Module, community: CommunityDto) =
  self.view.model().editItem(self.getCommunityItem(community))
  self.view.communityChanged(community.id)

method setCuratedCommunities*(self: Module, curatedCommunities: seq[CommunityDto]) =
  for community in curatedCommunities:
    self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(community))

method curatedCommunityAdded*(self: Module, community: CommunityDto) =
  self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(community))

method curatedCommunityEdited*(self: Module, community: CommunityDto) =
  if (self.view.curatedCommunitiesModel.containsItemWithId(community.id)):
    # FIXME: CommunityDto should not contain fields not present in the stauts-go's community update,
    # otherwise the state will vanish. For instance, the `listedInDirectory` and `featuredInDirectory`
    # fields are vanished when community update is received.
    var communityCopy = community
    communityCopy.featuredInDirectory = self.view.curatedCommunitiesModel.getItemById(community.id).getFeatured()
    self.view.curatedCommunitiesModel().addItem(self.getCuratedCommunityItem(communityCopy))

method createCommunity*(self: Module, name: string,
                        description, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool,
                        bannerJsonStr: string) =
  self.controller.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled,
                                  bannerJsonStr)

method communityMuted*(self: Module, communityId: string, muted: bool) =
  self.view.model().setMuted(communityId, muted)

method communityAccessRequested*(self: Module, communityId: string) =
  self.clean()
  self.view.communityAccessRequested(communityId)

method communityAccessFailed*(self: Module, communityId, err: string) =
  error "communities: ", err
  self.clean()
  self.view.communityAccessFailed(communityId, err)

method communityEditSharedAddressesSucceeded*(self: Module, communityId: string) =
  self.clean()
  self.view.communityEditSharedAddressesSucceeded(communityId)

method communityEditSharedAddressesFailed*(self: Module, communityId, error: string) =
  self.clean()
  self.view.communityEditSharedAddressesFailed(communityId, error)

method communityHistoryArchivesDownloadStarted*(self: Module, communityId: string) =
  self.view.setDownloadingCommunityHistoryArchives(true)

method communityHistoryArchivesDownloadFinished*(self: Module, communityId: string) =
  self.view.setDownloadingCommunityHistoryArchives(false)

method discordCategoriesAndChannelsExtracted*(self: Module, categories: seq[DiscordCategoryDto], channels: seq[DiscordChannelDto], oldestMessageTimestamp: int, errors: Table[string, DiscordImportError], errorsCount: int) =

  for filePath in errors.keys:
    self.view.discordFileListModel().updateErrorState(filePath, errors[filePath].message, errors[filePath].code)

  self.view.discordFileListModel().setAllValidated()

  self.view.discordCategoriesModel().clearItems()
  self.view.discordChannelsModel().clearItems()
  self.view.setDiscordOldestMessageTimestamp(oldestMessageTimestamp)

  for discordCategory in categories:
    self.view.discordCategoriesModel().addItem(self.getDiscordCategoryItem(discordCategory))
  for discordChannel in channels:
    self.view.discordChannelsModel().addItem(self.getDiscordChannelItem(discordChannel))

  self.view.setDiscordDataExtractionInProgress(false)
  self.view.setDiscordImportErrorsCount(errorsCount)
  self.view.discordChannelsModel().hasSelectedItemsChanged()

method cancelRequestToJoinCommunity*(self: Module, communityId: string) =
  self.controller.cancelRequestToJoinCommunity(communityId)

method requestCommunityInfo*(self: Module, communityId: string, shardCluster: int, shardIndex: int, importing: bool) =
  let shard = Shard(
    cluster: shardCluster,
    index: shardIndex,
  )
  self.controller.requestCommunityInfo(communityId, shard, importing)

method requestCommunityInfo*(self: Module, communityId: string, shard: Shard, importing: bool) =
  let cluster = if shard == nil: -1 else: shard.cluster
  let index = if shard == nil: -1 else: shard.index
  self.requestCommunityInfo(communityId, cluster, index, importing)

method isUserMemberOfCommunity*(self: Module, communityId: string): bool =
  self.controller.isUserMemberOfCommunity(communityId)

method userCanJoin*(self: Module, communityId: string): bool =
  self.controller.userCanJoin(communityId)

method isMyCommunityRequestPending*(self: Module, communityId: string): bool =
  self.controller.isMyCommunityRequestPending(communityId)

method communityImported*(self: Module, community: CommunityDto) =
  self.view.addOrUpdateItem(self.getCommunityItem(community))
  self.view.emitImportingCommunityStateChangedSignal(community.id, ImportCommunityState.Imported.int, errorMsg = "")

method communityDataImported*(self: Module, community: CommunityDto) =
  self.view.addItem(self.getCommunityItem(community))
  self.view.emitCommunityInfoRequestCompleted(community.id, "")

method communityInfoRequestFailed*(self: Module, communityId: string, errorMsg: string) =
  self.view.emitCommunityInfoRequestCompleted(communityId, errorMsg)

method importCommunity*(self: Module, communityId: string) =
  self.view.emitImportingCommunityStateChangedSignal(communityId, ImportCommunityState.ImportingInProgress.int, errorMsg = "")
  self.controller.importCommunity(communityId)

method onImportCommunityErrorOccured*(self: Module, communityId: string, error: string) =
  self.view.emitImportingCommunityStateChangedSignal(communityId, ImportCommunityState.ImportingError.int, error)

method onImportCommunityCancelled*(self: Module, communityId: string) =
  self.view.emitImportingCommunityStateChangedSignal(communityId, ImportCommunityState.ImportingCanceled.int, errorMsg = "")

method requestExtractDiscordChannelsAndCategories*(self: Module, filesToImport: seq[string]) =
  self.view.setDiscordDataExtractionInProgress(true)
  self.controller.requestExtractDiscordChannelsAndCategories(filesToImport)

method requestImportDiscordCommunity*(self: Module, name: string, description, introMessage, outroMessage: string, access: int,
                        color: string, tags: string, imagePath: string, aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool, pinMessageAllMembersEnabled: bool, filesToImport: seq[string],
                        fromTimestamp: int) =
  self.view.setDiscordImportHasCommunityImage(imagePath != "")
  self.controller.requestImportDiscordCommunity(name, description, introMessage, outroMessage, access, color, tags, imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled, filesToImport, fromTimestamp)

method requestImportDiscordChannel*(self: Module, name: string, discordChannelId: string, communityId: string, description: string,
                        color: string, emoji: string, filesToImport: seq[string],
                        fromTimestamp: int) =
  self.controller.requestImportDiscordChannel(name, discordChannelId, communityId, description, color, emoji, filesToImport, fromTimestamp)

proc getDiscordImportTaskItem(self: Module, t: DiscordImportTaskProgress): DiscordImportTaskItem =
  return initDiscordImportTaskItem(
      t.`type`,
      t.progress,
      t.state,
      t.errors,
      t.stopped,
      t.errorsCount,
      t.warningsCount)

method discordImportProgressUpdated*(
    self: Module,
    communityId: string,
    communityName: string,
    communityImage: string,
    tasks: seq[DiscordImportTaskProgress],
    progress: float,
    errorsCount: int,
    warningsCount: int,
    stopped: bool,
    totalChunksCount: int,
    currentChunk: int
  ) =
  for task in tasks:
    if not self.view.discordImportTasksModel().hasItemByType(task.`type`):
      self.view.discordImportTasksModel().addItem(self.getDiscordImportTaskItem(task))
    else:
      self.view.discordImportTasksModel().updateItem(task)

  self.view.setDiscordImportCommunityId(communityId)
  self.view.setDiscordImportCommunityName(communityName)
  self.view.setDiscordImportCommunityImage(communityImage)
  self.view.setDiscordImportErrorsCount(errorsCount)
  self.view.setDiscordImportWarningsCount(warningsCount)
  # For some reason, exposing the global `progress` as QtProperty[float]`
  # doesn't translate well into QML.
  # That's why we pass it as integer instead.
  self.view.setDiscordImportProgress((progress*100).int)
  self.view.setDiscordImportProgressStopped(stopped)
  self.view.setDiscordImportProgressTotalChunksCount(totalChunksCount)
  self.view.setDiscordImportProgressCurrentChunk(currentChunk)
  if stopped or progress.int >= 1:
    self.view.setDiscordImportInProgress(false)

method removeCommunityChat*(self: Module, communityId: string, channelId: string) =
  self.controller.removeCommunityChat(communityId, channelId)

method discordImportChannelFinished*(self: Module, communityId: string, channelId: string) =
    self.view.setDiscordImportedChannelCommunityId(communityId)
    self.view.setDiscordImportedChannelId(channelId)
    self.view.setDiscordImportProgress(100)
    self.view.setDiscordImportProgressStopped(true)
    self.view.setDiscordImportInProgress(false)

method discordImportChannelCanceled*(self: Module, channelId: string) =
  if self.view.getDiscordImportChannelId() == channelId:
    self.view.setDiscordImportProgress(0)
    self.view.setDiscordImportProgressStopped(true)
    self.view.setDiscordImportInProgress(false)

method discordImportChannelProgressUpdated*(
    self: Module,
    channelId: string,
    channelName: string,
    tasks: seq[DiscordImportTaskProgress],
    progress: float,
    errorsCount: int,
    warningsCount: int,
    stopped: bool,
    totalChunksCount: int,
    currentChunk: int
  ) =
  for task in tasks:
    if not self.view.discordImportTasksModel().hasItemByType(task.`type`):
      self.view.discordImportTasksModel().addItem(self.getDiscordImportTaskItem(task))
    else:
      self.view.discordImportTasksModel().updateItem(task)

  self.view.setDiscordImportChannelId(channelId)
  self.view.setDiscordImportChannelName(channelName)
  self.view.setDiscordImportErrorsCount(errorsCount)
  self.view.setDiscordImportWarningsCount(warningsCount)
  # For some reason, exposing the global `progress` as QtProperty[float]`
  # doesn't translate well into QML.
  # That's why we pass it as integer instead.
  self.view.setDiscordImportProgress((progress*100).int)
  self.view.setDiscordImportProgressStopped(stopped)
  self.view.setDiscordImportProgressTotalChunksCount(totalChunksCount)
  self.view.setDiscordImportProgressCurrentChunk(currentChunk)
  if stopped or progress.int >= 1:
    self.view.setDiscordImportInProgress(false)

method requestCancelDiscordCommunityImport*(self: Module, id: string) =
  self.controller.requestCancelDiscordCommunityImport(id)

method requestCancelDiscordChannelImport*(self: Module, discordChannelId: string) =
  self.controller.requestCancelDiscordChannelImport(discordChannelId)

proc createCommunityTokenItem(self: Module, token: CommunityTokensMetadataDto, communityId: string, supply: string,
    infiniteSupply: bool): TokenListItem =
  result = initTokenListItem(
    key = token.symbol,
    name = token.name,
    symbol = token.symbol,
    color = "", # community tokens don't have `color`
    image = token.image,
    category = ord(TokenListItemCategory.Community),
    communityId = communityId,
    supply,
    infiniteSupply,
  )

proc buildTokensAndCollectiblesFromCommunities(self: Module, communityTokens: seq[CommunityTokenDto]) =
  var tokenListItems: seq[TokenListItem]
  var collectiblesListItems: seq[TokenListItem]

  let communities = self.controller.getAllCommunities()
  for community in communities:
    if not community.isOwner and not community.isTokenMaster:
      # No need to include those tokens, we do not manage that community
      continue

    for tokenMetadata in community.communityTokensMetadata:
      # Set fallback supply to infinite in case we don't have it
      var supply = "1"
      var infiniteSupply = true
      for communityToken in communityTokens:
        if communityToken.symbol == tokenMetadata.symbol:
          supply = communityToken.supply.toString(10)
          infiniteSupply = communityToken.infiniteSupply
          break

      var communityTokenItem = self.createCommunityTokenItem(
        tokenMetadata,
        community.id,
        supply,
        infiniteSupply,
      )

      if tokenMetadata.tokenType == TokenType.ERC20:
      # Community ERC20 tokens
        tokenListItems.add(communityTokenItem)
      else:
      # Community collectibles (ERC721 and others)
        collectiblesListItems.add(communityTokenItem)

  self.view.tokenListModel.addItems(tokenListItems)
  self.view.collectiblesListModel.addItems(collectiblesListItems)

proc buildTokensAndCollectiblesFromWallet(self: Module) =
  var tokenListItems: seq[TokenListItem]

  # Common ERC20 tokens
  let erc20Tokens = self.controller.getTokenList()
  for token in erc20Tokens:
    let tokenListItem = initTokenListItem(
      key = token.symbol,
      name = token.name,
      symbol = token.symbol,
      color = "",
      communityId = token.communityId,
      image = "",
      category = ord(TokenListItemCategory.General),
    )
    tokenListItems.add(tokenListItem)

  self.view.tokenListModel.setWalletTokenItems(tokenListItems)

method onWalletAccountTokensRebuilt*(self: Module) =
  self.buildTokensAndCollectiblesFromWallet()

method onAllCommunityTokensLoaded*(self: Module, communityTokens: seq[CommunityTokenDto]) =
  self.buildTokensAndCollectiblesFromCommunities(communityTokens)

method onCommunityTokenMetadataAdded*(self: Module, communityId: string, tokenMetadata: CommunityTokensMetadataDto) =
  let communityTokens = self.controller.getCommunityTokens(communityId)
  var tokenListItem: TokenListItem
  # Set fallback supply to infinite in case we don't have it
  var supply = "1"
  var infiniteSupply = true
  for communityToken in communityTokens:
    if communityToken.symbol == tokenMetadata.symbol:
      supply = communityToken.supply.toString(10)
      infiniteSupply = communityToken.infiniteSupply
      break
  tokenListItem = self.createCommunityTokenItem(
    tokenMetadata,
    communityId,
    supply,
    infiniteSupply,
  )

  if tokenMetadata.tokenType == TokenType.ERC721 and
      not self.view.collectiblesListModel().hasItem(tokenMetadata.symbol):
    self.view.collectiblesListModel.addItems(@[tokenListItem])
    return

  if tokenMetadata.tokenType == TokenType.ERC20 and
      not self.view.tokenListModel().hasItem(tokenMetadata.symbol):
    self.view.tokenListModel.addItems(@[tokenListItem])

method shareCommunityUrlWithChatKey*(self: Module, communityId: string): string =
  return self.controller.shareCommunityUrlWithChatKey(communityId)

method shareCommunityUrlWithData*(self: Module, communityId: string): string =
  return self.controller.shareCommunityUrlWithData(communityId)

method shareCommunityChannelUrlWithChatKey*(self: Module, communityId: string, chatId: string): string =
  return self.controller.shareCommunityChannelUrlWithChatKey(communityId, chatId)

method shareCommunityChannelUrlWithData*(self: Module, communityId: string, chatId: string): string =
  return self.controller.shareCommunityChannelUrlWithData(communityId, chatId)

proc signRevealedAddressesThatBelongToRegularKeypairs(self: Module): bool =
  var signingParams: seq[SignParamsDto]
  for address, details in self.joiningCommunityDetails.addressesToShare.pairs:
    if details.signature.len > 0:
      continue
    let keypair = self.controller.getKeypairByAccountAddress(address)
    if keypair.isNil:
      self.communityAccessFailed(self.joiningCommunityDetails.communityId, "cannot resolve keypair for address" & address)
      return false
    if keypair.migratedToKeycard():
      continue
    signingParams.add(
      SignParamsDto(
        address: address,
        data: details.messageToBeSigned,
        password: common_utils.hashPassword(self.joiningCommunityDetails.profilePassword),
      )
    )
  if signingParams.len == 0:
    return true
  # signatures are returned in the same order as signingParams
  let signatures = self.controller.signCommunityRequests(self.joiningCommunityDetails.communityId, signingParams)
  for i in 0 ..< len(signingParams):
    self.joiningCommunityDetails.addressesToShare[signingParams[i].address].signature = signatures[i]
  return true

method onUserAuthenticated*(self: Module, pin: string, password: string, keyUid: string) =
  if password == "" and pin == "":
    info "unsuccesful authentication"
    self.clean()
    return

  self.joiningCommunityDetails.profilePassword = password
  self.joiningCommunityDetails.profilePin = pin
  if self.signRevealedAddressesThatBelongToRegularKeypairs():
    self.view.sendSharedAddressesForAllNonKeycardKeypairsSignedSignal()

method onDataSigned*(self: Module, keyUid: string, path: string, r: string, s: string, v: string, pin: string) =
  if keyUid.len == 0 or path.len == 0 or r.len == 0 or s.len == 0 or v.len == 0 or pin.len == 0:
    # being here is not an error
    return

  for address, details in self.joiningCommunityDetails.addressesToShare.pairs:
    if details.keyUid != keyUid or details.path != path:
      continue
    self.joiningCommunityDetails.addressesToShare[address].signature = "0x" & r & s & v
    break
  self.signSharedAddressesForKeypair(keyUid, pin)

method prepareKeypairsForSigning*(self: Module, communityId, ensName: string, addresses: string,
  airdropAddress: string, editMode: bool) =
  var addressesToShare: seq[string]
  try:
    addressesToShare = map(parseJson(addresses).getElems(), proc(x:JsonNode):string = x.getStr())
  except Exception as e:
    self.communityAccessFailed(communityId, "error parsing addresses: " & e.msg)
    return

  let allKeypairs = keypairs.buildKeyPairsList(self.controller.getKeypairs(), excludeAlreadyMigratedPairs = false,
    excludePrivateKeyKeypairs = false)
  for it in allKeypairs:
    let addressesToRemove = it.getAccountsModel().getItems()
      .map(x => x.getAddress())
      .filter(x => addressesToShare.filter(y => cmpIgnoreCase(y, x) == 0).len == 0)
    for address in addressesToRemove:
      it.removeAccountByAddress(address)
  let keypairsForSigning = allKeypairs.filter(x => x.getAccountsModel().getCount() > 0)
  self.view.setKeypairsSigningModelItems(keypairsForSigning)

  self.joiningCommunityDetails.communityId = communityId

  var signingParams: seq[SignParamsDto]
  if editMode:
    self.joiningCommunityDetails.action = Action.EditSharedAddresses
    signingParams = self.controller.generateEditCommunityRequestsForSigning(
      singletonInstance.userProfile.getPubKey(), communityId, addressesToShare)
  else:
    self.joiningCommunityDetails.action = Action.JoinCommunity
    self.joiningCommunityDetails.ensName = ensName
    signingParams = self.controller.generateJoiningCommunityRequestsForSigning(
      singletonInstance.userProfile.getPubKey(), communityId, addressesToShare)

  let findKeyUidAndPathForAddress = proc (items: seq[KeyPairItem], address: string): tuple[keyUid: string, path: string] =
    for it in items:
      for acc in it.getAccountsModel().getItems():
        if cmpIgnoreCase(acc.getAddress(), address) == 0:
          return (it.getKeyUid(), acc.getPath())
    return ("", "")

  for param in signingParams:
    let (keyUid, path) = findKeyUidAndPathForAddress(keypairsForSigning, param.address)
    let details = AddressToShareDetails(
      keyUid: keyUid,
      address: param.address,
      path: path,
      isAirdropAddress: if cmpIgnoreCase(param.address, airdropAddress) == 0: true else: false,
      messageToBeSigned: param.data
    )
    self.joiningCommunityDetails.addressesToShare[param.address] = details

method signSharedAddressesForAllNonKeycardKeypairs*(self: Module) =
  self.controller.authenticate()

# if pin is provided we're signing on a keycard silently
method signSharedAddressesForKeypair*(self: Module, keyUid: string, pin: string) =
  let keypair = self.controller.getKeypairByKeyUid(keyUid)
  if keypair.isNil:
    self.communityAccessFailed(self.joiningCommunityDetails.communityId, "cannot resolve keypair for keyUid " & keyUid)
    return
  for acc in keypair.accounts:
    for address, details in self.joiningCommunityDetails.addressesToShare.pairs:
      if cmpIgnoreCase(address, acc.address) != 0:
        continue
      if details.signature.len > 0:
        continue
      self.controller.runSigningOnKeycard(keyUid, details.path, details.messageToBeSigned, pin)
      return
  self.view.keypairsSigningModel().setOwnershipVerified(keyUid, true)

method joinCommunityOrEditSharedAddresses*(self: Module) =
  if not self.joiningCommunityDetails.allSigned():
    self.communityAccessFailed(self.joiningCommunityDetails.communityId, "unexpected call to join community function before all addresses are signed")
    return
  var
    addressesToShare: seq[string]
    airdropAddress: string
    signatures: seq[string]

  for _, details in self.joiningCommunityDetails.addressesToShare.pairs:
    addressesToShare.add(details.address)
    if details.isAirdropAddress:
      airdropAddress = details.address
    signatures.add(details.signature)

  if self.joiningCommunityDetails.action == Action.JoinCommunity:
    self.controller.asyncRequestToJoinCommunity(self.joiningCommunityDetails.communityId,
      self.joiningCommunityDetails.ensName,
      addressesToShare,
      airdropAddress,
      signatures)
    return
  if self.joiningCommunityDetails.action == Action.EditSharedAddresses:
    self.controller.asyncEditSharedAddresses(self.joiningCommunityDetails.communityId,
      addressesToShare,
      airdropAddress,
      signatures)
    return
  self.communityAccessFailed(self.joiningCommunityDetails.communityId, "unexpected action")

method getCommunityPublicKeyFromPrivateKey*(self: Module, communityPrivateKey: string): string =
  result = self.controller.getCommunityPublicKeyFromPrivateKey(communityPrivateKey)

method checkPermissions*(self: Module, communityId: string, sharedAddresses: seq[string]) =
  self.joiningCommunityDetails.communityIdForChannelsPermisisons = communityId
  self.controller.asyncCheckPermissionsToJoin(communityId, sharedAddresses)
  self.controller.asyncCheckAllChannelsPermissions(communityId, sharedAddresses)
  self.view.setCheckingPermissionsInProgress(inProgress = true)

method prepareTokenModelForCommunity*(self: Module, communityId: string) =
  self.joiningCommunityDetails.communityIdForRevealedAccounts = communityId
  self.controller.asyncGetRevealedAccountsForMember(communityId, singletonInstance.userProfile.getPubKey())

  let community = self.controller.getCommunityById(communityId)
  var tokenPermissionsItems: seq[TokenPermissionItem] = @[]

  for id, tokenPermission in community.tokenPermissions:
    let chats = community.getCommunityChats(tokenPermission.chatIds)
    let tokenPermissionItem = buildTokenPermissionItem(tokenPermission, chats)
    tokenPermissionsItems.add(tokenPermissionItem)

  self.view.spectatedCommunityPermissionModel.setItems(tokenPermissionsItems)
  self.checkPermissions(communityId, @[])

proc applyPermissionResponse*(self: Module, communityId: string, permissions: Table[string, CheckPermissionsResultDto]) =
  let community = self.controller.getCommunityById(communityId)
  for id, criteriaResult in permissions:
    if not community.tokenPermissions.hasKey(id):
      warn "unknown permission", id
      continue

    let tokenPermissionItem = self.view.spectatedCommunityPermissionModel.getItemById(id)
    if tokenPermissionItem.id == "":
      warn "no permission in model", id
      continue

    var updatedTokenCriteriaItems: seq[TokenCriteriaItem] = @[]
    var permissionSatisfied = true

    for index, tokenCriteriaItem in tokenPermissionItem.getTokenCriteria().getItems():

      let updatedTokenCriteriaItem = initTokenCriteriaItem(
        tokenCriteriaItem.symbol,
        tokenCriteriaItem.name,
        tokenCriteriaItem.amount,
        tokenCriteriaItem.`type`,
        tokenCriteriaItem.ensPattern,
        criteriaResult.criteria[index]
      )

      if criteriaResult.criteria[index] == false:
        permissionSatisfied = false

      updatedTokenCriteriaItems.add(updatedTokenCriteriaItem)

    let updatedTokenPermissionItem = initTokenPermissionItem(
        tokenPermissionItem.id,
        tokenPermissionItem.`type`,
        updatedTokenCriteriaItems,
        tokenPermissionItem.getChatList().getItems(),
        tokenPermissionItem.isPrivate,
        permissionSatisfied,
        tokenPermissionItem.state
    )
    self.view.spectatedCommunityPermissionModel.updateItem(id, updatedTokenPermissionItem)

proc updateCheckingPermissionsInProgressIfNeeded(self: Module, inProgress = false) =
  if self.checkingPermissionToJoinInProgress != self.checkingAllChannelPermissionsInProgress:
    # Wait until both join and channel permissions have returned to update the loading
    return
  self.view.setCheckingPermissionsInProgress(inProgress)

method onCommunityCheckPermissionsToJoinFailed*(self: Module, communityId: string, error: string) =
  # TODO show error
  self.checkingPermissionToJoinInProgress = false
  self.updateCheckingPermissionsInProgressIfNeeded(inProgress = false)

method onCommunityCheckAllChannelPermissionsFailed*(self: Module, communityId: string, error: string) =
  # TODO show error
  self.checkingAllChannelPermissionsInProgress = false
  self.updateCheckingPermissionsInProgressIfNeeded(inProgress = false)

method onCommunityCheckPermissionsToJoinResponse*(self: Module, communityId: string,
    checkPermissionsToJoinResponse: CheckPermissionsToJoinResponseDto) =
  if self.joiningCommunityDetails.communityId != communityId:
    return
  self.applyPermissionResponse(communityId, checkPermissionsToJoinResponse.permissions)
  self.checkingPermissionToJoinInProgress = false
  self.updateCheckingPermissionsInProgressIfNeeded(inProgress = false)

method onCommunityCheckAllChannelsPermissionsResponse*(self: Module, communityId: string,
    checkChannelPermissionsResponse: CheckAllChannelsPermissionsResponseDto) =
  if self.joiningCommunityDetails.communityIdForChannelsPermisisons != communityId:
    return
  self.checkingAllChannelPermissionsInProgress = false
  self.updateCheckingPermissionsInProgressIfNeeded(inProgress = false)
  for _, channelPermissionResponse in checkChannelPermissionsResponse.channels:
    self.applyPermissionResponse(
      communityId,
      channelPermissionResponse.viewOnlyPermissions.permissions,
    )
    self.applyPermissionResponse(
      communityId,
      channelPermissionResponse.viewAndPostPermissions.permissions,
    )

method onCommunityMemberRevealedAccountsLoaded*(self: Module, communityId, memberPubkey: string,
    revealedAccounts: seq[RevealedAccount]) =
  if self.joiningCommunityDetails.communityIdForRevealedAccounts != communityId:
    return
  if memberPubkey == singletonInstance.userProfile.getPubKey():
    var addresses: seq[string] = @[]
    var airdropAddress = ""
    for revealedAccount in revealedAccounts:
      addresses.add(revealedAccount.address)
      if revealedAccount.isAirdropAddress:
        airdropAddress = revealedAccount.address

    self.view.setMyRevealedAddressesForCurrentCommunity($(%*addresses), airdropAddress)
