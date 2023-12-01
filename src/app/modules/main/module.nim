import NimQml, tables, json, sugar, sequtils, strformat, marshal, times, chronicles, stint

import io_interface, view, controller, chat_search_item, chat_search_model
import ephemeral_notification_item, ephemeral_notification_model
import ./communities/models/[pending_request_item, pending_request_model]
import ../shared_models/[user_item, member_item, member_model, section_item, section_model, section_details]
import ../shared_models/[color_hash_item, color_hash_model]
import ../shared_modules/keycard_popup/module as keycard_shared_module
import ../../global/app_sections_config as conf
import ../../global/app_signals
import ../../global/global_singleton
import ../../global/utils as utils
import ../../../constants

import chat_section/model as chat_model
import chat_section/item as chat_item
import chat_section/module as chat_section_module
import wallet_section/module as wallet_section_module
import browser_section/module as browser_section_module
import profile_section/module as profile_section_module
import app_search/module as app_search_module
import stickers/module as stickers_module
import activity_center/module as activity_center_module
import communities/module as communities_module
import node_section/module as node_section_module
import communities/tokens/models/token_item
import communities/tokens/models/token_model
import network_connection/module as network_connection_module
import shared_urls/module as shared_urls_module

import ../../../app_service/service/contacts/dto/contacts
import ../../../app_service/service/community_tokens/community_collectible_owner

import ../../../app_service/service/keychain/service as keychain_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/currency/service as currency_service
import ../../../app_service/service/transaction/service as transaction_service
import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/bookmarks/service as bookmark_service
import ../../../app_service/service/dapp_permissions/service as dapp_permissions_service
import ../../../app_service/service/provider/service as provider_service
import ../../../app_service/service/profile/service as profile_service
import ../../../app_service/service/accounts/service as accounts_service
import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/about/service as about_service
import ../../../app_service/service/language/service as language_service
import ../../../app_service/service/privacy/service as privacy_service
import ../../../app_service/service/stickers/service as stickers_service
import ../../../app_service/service/activity_center/service as activity_center_service
import ../../../app_service/service/saved_address/service as saved_address_service
import ../../../app_service/service/node/service as node_service
import ../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../app_service/service/devices/service as devices_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/ens/service as ens_service
import ../../../app_service/service/community_tokens/service as community_tokens_service
import ../../../app_service/service/network/service as network_service
import ../../../app_service/service/general/service as general_service
import ../../../app_service/service/keycard/service as keycard_service
import ../../../app_service/service/shared_urls/service as urls_service
import ../../../app_service/service/network_connection/service as network_connection_service
import ../../../app_service/service/visual_identity/service as procs_from_visual_identity_service
import ../../../app_service/common/types
import ../../../app_service/common/social_links
import ../../../app_service/common/utils as common_utils

import ../../core/notifications/details
import ../../core/eventemitter
import ../../core/custom_urls/urls_manager

export io_interface

const TOAST_MESSAGE_VISIBILITY_DURATION_IN_MS = 5000 # 5 seconds
const STATUS_URL_ENS_RESOLVE_REASON = "StatusUrl"

type
  SpectateRequest = object
    communityId*: string
    channelUuid*: string

  Module*[T: io_interface.DelegateInterface] = ref object of io_interface.AccessInterface
    delegate: T
    view: View
    viewVariant: QVariant
    controller: Controller
    channelGroupModules: OrderedTable[string, chat_section_module.AccessInterface]
    events: EventEmitter
    urlsManager: UrlsManager
    keycardService: keycard_service.Service
    settingsService: settings_service.Service
    networkService: network_service.Service
    privacyService: privacy_service.Service
    accountsService: accounts_service.Service
    walletAccountService: wallet_account_service.Service
    keychainService: keychain_service.Service
    networkConnectionService: network_connection_service.Service
    walletSectionModule: wallet_section_module.AccessInterface
    browserSectionModule: browser_section_module.AccessInterface
    profileSectionModule: profile_section_module.AccessInterface
    stickersModule: stickers_module.AccessInterface
    activityCenterModule: activity_center_module.AccessInterface
    communitiesModule: communities_module.AccessInterface
    appSearchModule: app_search_module.AccessInterface
    nodeSectionModule: node_section_module.AccessInterface
    keycardSharedModuleForAuthenticationOrSigning: keycard_shared_module.AccessInterface
    keycardSharedModuleKeycardSyncPurpose: keycard_shared_module.AccessInterface
    keycardSharedModule: keycard_shared_module.AccessInterface
    networkConnectionModule: network_connection_module.AccessInterface
    sharedUrlsModule: shared_urls_module.AccessInterface
    moduleLoaded: bool
    chatsLoaded: bool
    communityDataLoaded: bool
    pendingSpectateRequest: SpectateRequest
    statusDeepLinkToActivate: string

{.push warning[Deprecated]: off.}

# Forward declaration
method calculateProfileSectionHasNotification*[T](self: Module[T]): bool
proc switchToContactOrDisplayUserProfile[T](self: Module[T], publicKey: string)
method activateStatusDeepLink*[T](self: Module[T], statusDeepLink: string)

proc newModule*[T](
  delegate: T,
  events: EventEmitter,
  urlsManager: UrlsManager,
  keychainService: keychain_service.Service,
  accountsService: accounts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  tokenService: token_service.Service,
  currencyService: currency_service.Service,
  transactionService: transaction_service.Service,
  walletAccountService: wallet_account_service.Service,
  bookmarkService: bookmark_service.Service,
  profileService: profile_service.Service,
  settingsService: settings_service.Service,
  contactsService: contacts_service.Service,
  aboutService: about_service.Service,
  dappPermissionsService: dapp_permissions_service.Service,
  languageService: language_service.Service,
  privacyService: privacy_service.Service,
  providerService: provider_service.Service,
  stickersService: stickers_service.Service,
  activityCenterService: activity_center_service.Service,
  savedAddressService: saved_address_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  devicesService: devices_service.Service,
  mailserversService: mailservers_service.Service,
  nodeService: node_service.Service,
  gifService: gif_service.Service,
  ensService: ens_service.Service,
  communityTokensService: community_tokens_service.Service,
  networkService: network_service.Service,
  generalService: general_service.Service,
  keycardService: keycard_service.Service,
  networkConnectionService: network_connection_service.Service,
  sharedUrlsService: urls_service.Service
): Module[T] =
  result = Module[T]()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(
    result,
    events,
    settingsService,
    nodeConfigurationService,
    accountsService,
    chatService,
    communityService,
    contactsService,
    messageService,
    gifService,
    privacyService,
    mailserversService,
    nodeService,
    communityTokensService,
    walletAccountService,
    tokenService,
    networkService,
    sharedUrlsService,
  )
  result.moduleLoaded = false
  result.chatsLoaded = false
  result.communityDataLoaded = false

  result.events = events
  result.urlsManager = urlsManager
  result.keycardService = keycardService
  result.settingsService = settingsService
  result.networkService = networkService
  result.privacyService = privacyService
  result.accountsService = accountsService
  result.walletAccountService = walletAccountService
  result.keychainService = keychainService

  # Submodules
  result.channelGroupModules = initOrderedTable[string, chat_section_module.AccessInterface]()
  result.walletSectionModule = wallet_section_module.newModule(
    result, events, tokenService, currencyService,
    transactionService, walletAccountService,
    settingsService, savedAddressService, networkService, accountsService,
    keycardService, nodeService, networkConnectionService, devicesService
  )
  result.browserSectionModule = browser_section_module.newModule(
    result, events, bookmarkService, settingsService, networkService,
    dappPermissionsService, providerService, walletAccountService,
    tokenService, currencyService
  )
  result.profileSectionModule = profile_section_module.newModule(
    result, events, accountsService, settingsService, stickersService,
    profileService, contactsService, aboutService, languageService, privacyService, nodeConfigurationService,
    devicesService, mailserversService, chatService, ensService, walletAccountService, generalService, communityService,
    networkService, keycardService, keychainService, tokenService
  )
  result.stickersModule = stickers_module.newModule(result, events, stickersService, settingsService, walletAccountService,
    networkService, tokenService, keycardService)
  result.activityCenterModule = activity_center_module.newModule(result, events, activityCenterService, contactsService,
  messageService, chatService, communityService)
  result.communitiesModule = communities_module.newModule(result, events, communityService, contactsService, communityTokensService,
    networkService, transactionService, tokenService, chatService, walletAccountService, keycardService)
  result.appSearchModule = app_search_module.newModule(result, events, contactsService, chatService, communityService,
  messageService)
  result.nodeSectionModule = node_section_module.newModule(result, events, settingsService, nodeService, nodeConfigurationService)
  result.networkConnectionModule = network_connection_module.newModule(result, events, networkConnectionService)
  result.sharedUrlsModule = shared_urls_module.newModule(result, events, sharedUrlsService)

method delete*[T](self: Module[T]) =
  self.controller.delete
  self.profileSectionModule.delete
  self.stickersModule.delete
  self.activityCenterModule.delete
  self.communitiesModule.delete
  for cModule in self.channelGroupModules.values:
    cModule.delete
  self.channelGroupModules.clear
  self.walletSectionModule.delete
  self.browserSectionModule.delete
  self.appSearchModule.delete
  self.nodeSectionModule.delete
  if not self.keycardSharedModuleForAuthenticationOrSigning.isNil:
    self.keycardSharedModuleForAuthenticationOrSigning.delete
  if not self.keycardSharedModuleKeycardSyncPurpose.isNil:
    self.keycardSharedModuleKeycardSyncPurpose.delete
  if not self.keycardSharedModule.isNil:
    self.keycardSharedModule.delete
  self.networkConnectionModule.delete
  self.sharedUrlsModule.delete
  self.view.delete
  self.viewVariant.delete

proc createTokenItem[T](self: Module[T], tokenDto: CommunityTokenDto) : token_item.TokenItem =
  let network = self.controller.getNetwork(tokenDto.chainId)
  let tokenOwners = self.controller.getCommunityTokenOwners(tokenDto.communityId, tokenDto.chainId, tokenDto.address)
  let ownerAddressName = if len(tokenDto.deployer) > 0: self.controller.getCommunityTokenOwnerName(tokenDto.deployer) else: ""
  let remainingSupply = if tokenDto.infiniteSupply: stint.parse("0", Uint256) else: self.controller.getRemainingSupply(tokenDto.chainId, tokenDto.address)
  let burnState = self.controller.getCommunityTokenBurnState(tokenDto.chainId, tokenDto.address)
  let remoteDestructedAddresses = self.controller.getRemoteDestructedAddresses(tokenDto.chainId, tokenDto.address)
  let destructedAmount = self.controller.getRemoteDestructedAmount(tokenDto.chainId, tokenDto.address)
  result = initTokenItem(tokenDto, network, tokenOwners, ownerAddressName, burnState, remoteDestructedAddresses, remainingSupply, destructedAmount)

proc createTokenItemImproved[T](self: Module[T], tokenDto: CommunityTokenDto, communityTokenJsonItems: JsonNode) : token_item.TokenItem =
  # These 3 values come from local caches so they can be done sync
  let network = self.controller.getNetwork(tokenDto.chainId)
  let tokenOwners = self.controller.getCommunityTokenOwners(tokenDto.communityId, tokenDto.chainId, tokenDto.address)
  let ownerAddressName = if len(tokenDto.deployer) > 0: self.controller.getCommunityTokenOwnerName(tokenDto.deployer) else: ""

  var tokenDetails: JsonNode

  for details in communityTokenJsonItems.items:
    if details["address"].getStr ==  tokenDto.address:
      tokenDetails = details
      break

  if tokenDetails.kind == JNull:
    error "Token details not found for token", name = tokenDto.name, address = tokenDto.address
    return

  let remainingSupply = tokenDetails["remainingSupply"].getStr
  let burnState = tokenDetails["burnState"].getInt
  let remoteDestructedAddresses = map(tokenDetails["remoteDestructedAddresses"].getElems(),
    proc(remoteDestructAddress: JsonNode): string = remoteDestructAddress.getStr)
  let destructedAmount = tokenDetails["destructedAmount"].getStr

  result = initTokenItem(
    tokenDto,
    network,
    tokenOwners,
    ownerAddressName,
    ContractTransactionStatus(burnState),
    remoteDestructedAddresses,
    stint.parse(remainingSupply, Uint256),
    stint.parse(destructedAmount, Uint256),
  )

method onCommunityTokensDetailsLoaded[T](self: Module[T], communityId: string,
    communityTokens: seq[CommunityTokenDto], communityTokenJsonItems: JsonNode) =
  let communityTokensItems = communityTokens.map(proc(tokenDto: CommunityTokenDto): TokenItem =
    result = self.createTokenItemImproved(tokenDto, communityTokenJsonItems)
  )
  self.view.model().setTokenItems(communityId, communityTokensItems)

proc createChannelGroupItem[T](self: Module[T], channelGroup: ChannelGroupDto): SectionItem =
  let isCommunity = channelGroup.channelGroupType == ChannelGroupType.Community
  var communityDetails: CommunityDto
  var communityTokensItems: seq[TokenItem]
  if (isCommunity):
    communityDetails = self.controller.getCommunityById(channelGroup.id)
    if communityDetails.memberRole == MemberRole.Owner or communityDetails.memberRole == MemberRole.TokenMaster:
      self.controller.getCommunityTokensDetailsAsync(channelGroup.id)

      # Get community members' revealed accounts
      # We will update the model later when we finish loading the accounts
      self.controller.asyncGetRevealedAccountsForAllMembers(channelGroup.id)

  let unviewedCount = channelGroup.unviewedMessagesCount
  let notificationsCount = channelGroup.unviewedMentionsCount
  let hasNotification = unviewedCount > 0 or notificationsCount > 0
  let active = self.getActiveSectionId() == channelGroup.id # We must pass on if the current item section is currently active to keep that property as it is


  # Add members who were kicked from the community after the ownership change for auto-rejoin after they share addresses
  var members = channelGroup.members
  for requestForAutoRejoin in communityDetails.waitingForSharedAddressesRequestsToJoin:
    var chatMember = ChatMember()
    chatMember.id = requestForAutoRejoin.publicKey
    chatMember.joined = false
    chatMember.role = MemberRole.None
    members.add(chatMember)

  result = initItem(
    channelGroup.id,
    if isCommunity: SectionType.Community else: SectionType.Chat,
    if isCommunity: channelGroup.name else: conf.CHAT_SECTION_NAME,
    channelGroup.memberRole,
    if isCommunity: communityDetails.isControlNode else: false,
    channelGroup.description,
    channelGroup.introMessage,
    channelGroup.outroMessage,
    channelGroup.images.thumbnail,
    channelGroup.images.banner,
    icon = if (isCommunity): "" else: conf.CHAT_SECTION_ICON,
    channelGroup.color,
    if isCommunity: communityDetails.tags else: "",
    hasNotification,
    notificationsCount,
    active,
    enabled = true,
    if (isCommunity): communityDetails.joined else: true,
    if (isCommunity): communityDetails.canJoin else: true,
    if (isCommunity): communityDetails.spectated else: false,
    channelGroup.canManageUsers,
    if (isCommunity): communityDetails.canRequestAccess else: true,
    if (isCommunity): communityDetails.isMember else: true,
    channelGroup.permissions.access,
    channelGroup.permissions.ensOnly,
    channelGroup.muted,
    # members
    members.map(proc(member: ChatMember): MemberItem =
      let contactDetails = self.controller.getContactDetails(member.id)
      var state = MembershipRequestState.Accepted
      if not member.joined:
        state = MembershipRequestState.AwaitingAddress

      result = initMemberItem(
        pubKey = member.id,
        displayName = contactDetails.dto.displayName,
        ensName = contactDetails.dto.name,
        isEnsVerified = contactDetails.dto.ensVerified,
        localNickname = contactDetails.dto.localNickname,
        alias = contactDetails.dto.alias,
        icon = contactDetails.icon,
        colorId = contactDetails.colorId,
        colorHash = contactDetails.colorHash,
        onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(member.id).statusType),
        isContact = contactDetails.dto.isContact,
        isVerified = contactDetails.dto.isContactVerified(),
        memberRole = member.role,
        membershipRequestState = state
      )),
    # pendingRequestsToJoin
    if (isCommunity): communityDetails.pendingRequestsToJoin.map(x => pending_request_item.initItem(
      x.id,
      x.publicKey,
      x.chatId,
      x.communityId,
      x.state,
      x.our
    )) else: @[],
    communityDetails.settings.historyArchiveSupportEnabled,
    communityDetails.adminSettings.pinMessageAllMembersEnabled,
    # bannedMembers
    channelGroup.bannedMembersIds.map(proc(bannedMemberId: string): MemberItem=
      let contactDetails = self.controller.getContactDetails(bannedMemberId)
      result = initMemberItem(
        pubKey = bannedMemberId,
        displayName = contactDetails.dto.displayName,
        ensName = contactDetails.dto.name,
        isEnsVerified = contactDetails.dto.ensVerified,
        localNickname = contactDetails.dto.localNickname,
        alias = contactDetails.dto.alias,
        icon = contactDetails.icon,
        colorId = contactDetails.colorId,
        colorHash = contactDetails.colorHash,
        onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(bannedMemberId).statusType),
        isContact = contactDetails.dto.isContact,
        isVerified = contactDetails.dto.isContactVerified(),
        membershipRequestState = MembershipRequestState.Banned,
      )
    ),
    # pendingMemberRequests
    if (isCommunity): communityDetails.pendingRequestsToJoin.map(proc(requestDto: CommunityMembershipRequestDto): MemberItem =
      let contactDetails = self.controller.getContactDetails(requestDto.publicKey)
      result = initMemberItem(
        pubKey = requestDto.publicKey,
        displayName = contactDetails.dto.displayName,
        ensName = contactDetails.dto.name,
        isEnsVerified = contactDetails.dto.ensVerified,
        localNickname = contactDetails.dto.localNickname,
        alias = contactDetails.dto.alias,
        icon = contactDetails.icon,
        colorId = contactDetails.colorId,
        colorHash = contactDetails.colorHash,
        onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(requestDto.publicKey).statusType),
        isContact = contactDetails.dto.isContact,
        isVerified = contactDetails.dto.isContactVerified(),
        requestToJoinId = requestDto.id,
        membershipRequestState = MembershipRequestState(requestDto.state),
      )
    ) else: @[],
    # declinedMemberRequests
    if (isCommunity): communityDetails.declinedRequestsToJoin.map(proc(requestDto: CommunityMembershipRequestDto): MemberItem =
      let contactDetails = self.controller.getContactDetails(requestDto.publicKey)
      result = initMemberItem(
        pubKey = requestDto.publicKey,
        displayName = contactDetails.dto.displayName,
        ensName = contactDetails.dto.name,
        isEnsVerified = contactDetails.dto.ensVerified,
        localNickname = contactDetails.dto.localNickname,
        alias = contactDetails.dto.alias,
        icon = contactDetails.icon,
        colorId = contactDetails.colorId,
        colorHash = contactDetails.colorHash,
        onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(requestDto.publicKey).statusType),
        isContact = contactDetails.dto.isContact,
        isVerified = contactDetails.dto.isContactVerified(),
        requestToJoinId = requestDto.id,
        membershipRequestState = MembershipRequestState(requestDto.state),
      )
    ) else: @[],
    channelGroup.encrypted,
    communityTokensItems,
    channelGroup.pubsubTopic,
    channelGroup.pubsubTopicKey,
    channelGroup.shard.index,
  )

proc connectForNotificationsOnly[T](self: Module[T]) =
  self.events.on(SIGNAL_WALLET_ACCOUNT_SAVED) do(e:Args):
    let args = AccountArgs(e)
    self.view.showToastAccountAdded(args.account.name)

  self.events.on(SIGNAL_WALLET_ACCOUNT_DELETED) do(e:Args):
    let args = AccountArgs(e)
    self.view.showToastAccountRemoved(args.account.name)

  self.events.on(SIGNAL_KEYPAIR_NAME_CHANGED) do(e: Args):
    let args = KeypairArgs(e)
    self.view.showToastKeypairRenamed(args.oldKeypairName, args.keypair.name)

  self.events.on(SIGNAL_NETWORK_ENDPOINT_UPDATED) do(e: Args):
    let args = NetworkEndpointUpdatedArgs(e)
    self.view.showNetworkEndpointUpdated(args.networkName, args.isTest, args.revertedToDefault)

  self.events.on(SIGNAL_KEYPAIR_DELETED) do(e: Args):
    let args = KeypairArgs(e)
    self.view.showToastKeypairRemoved(args.keyPairName)

  self.events.on(SIGNAL_IMPORTED_KEYPAIRS) do(e:Args):
    let args = KeypairsArgs(e)
    var kpName: string
    if args.keypairs.len > 0:
      kpName = args.keypairs[0].name
    self.view.showToastKeypairsImported(kpName, args.keypairs.len, args.error)

  self.events.on(SIGNAL_TRANSACTION_SENT) do(e:Args):
    let args = TransactionSentArgs(e)
    self.view.showToastTransactionSent(args.chainId, args.txHash, args.uuid, args.error)

method load*[T](
  self: Module[T],
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
) =
  singletonInstance.engine.setRootContextProperty("mainModule", self.viewVariant)
  self.controller.init()
  self.view.load()
  self.connectForNotificationsOnly()

  var activeSection: SectionItem
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()
  if (activeSectionId == ""):
    activeSectionId = singletonInstance.userProfile.getPubKey()

  # Communities Portal Section
  let communitiesPortalSectionItem = initItem(
    conf.COMMUNITIESPORTAL_SECTION_ID,
    SectionType.CommunitiesPortal,
    conf.COMMUNITIESPORTAL_SECTION_NAME,
    memberRole = MemberRole.Owner,
    description = "",
    image = "",
    icon = conf.COMMUNITIESPORTAL_SECTION_ICON,
    color = "",
    hasNotification = false,
    notificationsCount = 0,
    active = false,
    enabled = true,
  )
  self.view.model().addItem(communitiesPortalSectionItem)
  if(activeSectionId == communitiesPortalSectionItem.id):
    activeSection = communitiesPortalSectionItem

  # Wallet Section
  let walletSectionItem = initItem(
    conf.WALLET_SECTION_ID,
    SectionType.Wallet,
    conf.WALLET_SECTION_NAME,
    memberRole = MemberRole.Owner,
    description = "",
    introMessage = "",
    outroMessage = "",
    image = "",
    icon = conf.WALLET_SECTION_ICON,
    color = "",
    hasNotification = false,
    notificationsCount = 0,
    active = false,
    enabled = WALLET_ENABLED,
  )
  self.view.model().addItem(walletSectionItem)
  if(activeSectionId == walletSectionItem.id):
    activeSection = walletSectionItem

  # Browser Section
  let browserSectionItem = initItem(
    conf.BROWSER_SECTION_ID,
    SectionType.Browser,
    conf.BROWSER_SECTION_NAME,
    memberRole = MemberRole.Owner,
    description = "",
    introMessage = "",
    outroMessage = "",
    image = "",
    icon = conf.BROWSER_SECTION_ICON,
    color = "",
    hasNotification = false,
    notificationsCount = 0,
    active = false,
    enabled = singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled(),
  )
  self.view.model().addItem(browserSectionItem)
  if(activeSectionId == browserSectionItem.id):
    activeSection = browserSectionItem

  # Node Management Section
  let nodeManagementSectionItem = initItem(
    conf.NODEMANAGEMENT_SECTION_ID,
    SectionType.NodeManagement,
    conf.NODEMANAGEMENT_SECTION_NAME,
    memberRole = MemberRole.Owner,
    description = "",
    introMessage = "",
    outroMessage = "",
    image = "",
    icon = conf.NODEMANAGEMENT_SECTION_ICON,
    color = "",
    hasNotification = false,
    notificationsCount = 0,
    active = false,
    enabled = singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled(),
  )
  self.view.model().addItem(nodeManagementSectionItem)
  if(activeSectionId == nodeManagementSectionItem.id):
    activeSection = nodeManagementSectionItem

  # Profile Section
  let profileSettingsSectionItem = initItem(
    conf.SETTINGS_SECTION_ID,
    SectionType.ProfileSettings,
    conf.SETTINGS_SECTION_NAME,
    memberRole = MemberRole.Owner,
    description = "",
    introMessage = "",
    outroMessage = "",
    image = "",
    icon = conf.SETTINGS_SECTION_ICON,
    color = "",
    hasNotification = self.calculateProfileSectionHasNotification(),
    notificationsCount = 0,
    active = false,
    enabled = true,
  )
  self.view.model().addItem(profileSettingsSectionItem)
  if(activeSectionId == profileSettingsSectionItem.id):
    activeSection = profileSettingsSectionItem

  self.browserSectionModule.load()
  self.profileSectionModule.load()
  self.stickersModule.load()
  self.activityCenterModule.load()
  self.communitiesModule.load()
  self.appSearchModule.load()
  self.nodeSectionModule.load()
  # Load wallet last as it triggers events that are listened by other modules
  self.walletSectionModule.load()
  self.networkConnectionModule.load()
  self.sharedUrlsModule.load()

  # Set active section on app start
  # If section is empty or profile then open the loading section until chats are loaded
  if activeSection.isEmpty() or activeSection.sectionType == SectionType.ProfileSettings:
    # Set bogus Item as active until the chat is loaded
    let loadingItem = initItem(
      LOADING_SECTION_ID,
      SectionType.LoadingSection,
      name = "",
      memberRole = MemberRole.Owner,
      description = "",
      image = "",
      icon = "",
      color = "",
      hasNotification = false,
      notificationsCount = 0,
      active = false,
      enabled = true,
    )
    self.view.model().addItem(loadingItem)
    self.setActiveSection(loadingItem, skipSavingInSettings = true)
  else:
    self.setActiveSection(activeSection)

method onChannelGroupsLoaded*[T](
  self: Module[T],
  channelGroups: seq[ChannelGroupDto],
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  walletAccountService: wallet_account_service.Service,
  tokenService: token_service.Service,
  communityTokensService: community_tokens_service.Service,
  sharedUrlsService: urls_service.Service,
) =
  self.chatsLoaded = true
  if not self.communityDataLoaded:
    return
  var activeSection: SectionItem
  var activeSectionId = singletonInstance.localAccountSensitiveSettings.getActiveSection()
  if activeSectionId == "":
    activeSectionId = singletonInstance.userProfile.getPubKey()

  for channelGroup in channelGroups:
    self.channelGroupModules[channelGroup.id] = chat_section_module.newModule(
      self,
      events,
      channelGroup.id,
      isCommunity = channelGroup.channelGroupType == ChannelGroupType.Community,
      settingsService,
      nodeConfigurationService,
      contactsService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService,
      walletAccountService,
      tokenService,
      communityTokensService,
      sharedUrlsService,
    )
    let channelGroupItem = self.createChannelGroupItem(channelGroup)
    self.view.model().addItem(channelGroupItem)
    if activeSectionId == channelGroupItem.id:
      activeSection = channelGroupItem

    self.channelGroupModules[channelGroup.id].load()

  # Set active section if it is one of the channel sections
  if not activeSection.isEmpty():
    self.setActiveSection(activeSection)

  # Remove old loading section
  self.view.model().removeItem(LOADING_SECTION_ID)

  self.view.sectionsLoaded()
  if self.statusDeepLinkToActivate != "":
    self.activateStatusDeepLink(self.statusDeepLinkToActivate)

method onCommunityDataLoaded*[T](
  self: Module[T],
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  walletAccountService: wallet_account_service.Service,
  tokenService: token_service.Service,
  communityTokensService: community_tokens_service.Service,
  sharedUrlsService: urls_service.Service,
) =
  self.communityDataLoaded = true
  if not self.chatsLoaded:
    return

  self.onChannelGroupsLoaded(
    self.controller.getChannelGroups(),
    events,
    settingsService,
    nodeConfigurationService,
    contactsService,
    chatService,
    communityService,
    messageService,
    gifService,
    mailserversService,
    walletAccountService,
    tokenService,
    communityTokensService,
    sharedUrlsService,
  )

method onChatsLoadingFailed*[T](self: Module[T]) =
  self.view.chatsLoadingFailed()

proc checkIfModuleDidLoad [T](self: Module[T]) =
  if self.moduleLoaded:
    return

  for cModule in self.channelGroupModules.values:
    if(not cModule.isLoaded()):
      return

#  if (not self.communitiesPortalSectionModule.isLoaded()):
#    return

  if (not self.walletSectionModule.isLoaded()):
    return

  if(not self.browserSectionModule.isLoaded()):
    return

  if(not self.nodeSectionModule.isLoaded()):
    return

  if(not self.profileSectionModule.isLoaded()):
    return

  if(not self.stickersModule.isLoaded()):
    return

  if(not self.activityCenterModule.isLoaded()):
    return

  if(not self.communitiesModule.isLoaded()):
    return

  if(not self.appSearchModule.isLoaded()):
    return

  if(not self.networkConnectionModule.isLoaded()):
    return

  self.moduleLoaded = true
  self.delegate.mainDidLoad()

method chatSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitySectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method appSearchDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method stickersDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method activityCenterDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method communitiesModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

#method communitiesPortalSectionDidLoad*[T](self: Module[T]) =
#  self.checkIfModuleDidLoad()

method walletSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method browserSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method profileSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method nodeSectionDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method networkConnectionModuleDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method viewDidLoad*[T](self: Module[T]) =
  self.checkIfModuleDidLoad()

method emitMailserverWorking*[T](self: Module[T]) =
  self.view.emitMailserverWorking()

method emitMailserverNotWorking*[T](self: Module[T]) =
  self.view.emitMailserverNotWorking()

method setCommunityIdToSpectate*[T](self: Module[T], communityId: string) =
  self.pendingSpectateRequest.communityId = communityId
  self.pendingSpectateRequest.channelUuid = ""

method getActiveSectionId*[T](self: Module[T]): string =
  return self.controller.getActiveSectionId()

method setActiveSection*[T](self: Module[T], item: SectionItem, skipSavingInSettings: bool = false) =
  if(item.isEmpty()):
    echo "section is empty and cannot be made as active one"
    return
  self.controller.setActiveSection(item.id, skipSavingInSettings)

method setActiveSectionById*[T](self: Module[T], id: string) =
  let item = self.view.model().getItemById(id)
  self.setActiveSection(item)

proc notifySubModulesAboutChange[T](self: Module[T], sectionId: string) =
  for cModule in self.channelGroupModules.values:
    cModule.onActiveSectionChange(sectionId)

  # If there is a need other section may be notified the same way from here...

method activeSectionSet*[T](self: Module[T], sectionId: string) =
  if self.view.activeSection.getId() == sectionId:
    return
  let item = self.view.model().getItemById(sectionId)

  if(item.isEmpty()):
    # should never be here
    echo "main-module, incorrect section id: ", sectionId
    return

  case sectionId:
    of conf.COMMUNITIESPORTAL_SECTION_ID:
      self.communitiesModule.onActivated()
    of conf.BROWSER_SECTION_ID:
      self.browserSectionModule.onActivated()

  self.view.model().setActiveSection(sectionId)
  self.view.activeSectionSet(item)

  self.notifySubModulesAboutChange(sectionId)

proc setSectionAvailability[T](self: Module[T], sectionType: SectionType, available: bool) =
  if(available):
    self.view.model().enableSection(sectionType)
  else:
    self.view.model().disableSection(sectionType)

method toggleSection*[T](self: Module[T], sectionType: SectionType) =
  if (sectionType == SectionType.Browser):
    let enabled = singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setIsBrowserEnabled(not enabled)
  elif (sectionType == SectionType.NodeManagement):
    let enabled = singletonInstance.localAccountSensitiveSettings.getNodeManagementEnabled()
    self.setSectionAvailability(sectionType, not enabled)
    singletonInstance.localAccountSensitiveSettings.setNodeManagementEnabled(not enabled)

method setCurrentUserStatus*[T](self: Module[T], status: StatusType) =
  self.controller.setCurrentUserStatus(status)

proc getChatSectionModule*[T](self: Module[T]): chat_section_module.AccessInterface =
  return self.channelGroupModules[singletonInstance.userProfile.getPubKey()]

method getChatSectionModuleAsVariant*[T](self: Module[T]): QVariant =
  return self.getChatSectionModule().getModuleAsVariant()

method getCommunitySectionModule*[T](self: Module[T], communityId: string): QVariant =
  if(not self.channelGroupModules.contains(communityId)):
    echo "main-module, unexisting community key: ", communityId
    return

  return self.channelGroupModules[communityId].getModuleAsVariant()

method rebuildChatSearchModel*[T](self: Module[T]) =
  var items: seq[chat_search_item.Item] = @[]
  for chat in self.controller.getAllChats():
    var chatName = chat.name
    var chatImage = chat.icon
    var colorHash: ColorHashDto = @[]
    var colorId: int = 0
    var sectionId = self.view.model().getItemBySectionType(SectionType.Chat).id()
    var sectionName = self.view.model().getItemBySectionType(SectionType.Chat).name()
    if chat.chatType == ChatType.OneToOne:
      let contactDetails = self.controller.getContactDetails(chat.id)
      chatName = contactDetails.defaultDisplayName
      chatImage = contactDetails.icon
      if not contactDetails.dto.ensVerified:
        colorHash = self.controller.getColorHash(chat.id)
      colorId = self.controller.getColorId(chat.id)
    elif chat.chatType == ChatType.CommunityChat:
      sectionId = chat.communityId
      sectionName = self.view.model().getItemById(sectionId).name()
    items.add(chat_search_item.initItem(
      chat.id,
      chatName,
      chat.color,
      colorId,
      chatImage,
      colorHash.toJson(),
      sectionId,
      sectionName,
    ))

  self.view.chatSearchModel().setItems(items)

method switchTo*[T](self: Module[T], sectionId, chatId: string) =
  self.controller.switchTo(sectionId, chatId, "")

method onActiveChatChange*[T](self: Module[T], sectionId: string, chatId: string) =
  self.appSearchModule.onActiveChatChange(sectionId, chatId)

method onChatLeft*[T](self: Module[T], chatId: string) =
  self.appSearchModule.updateSearchLocationIfPointToChatWithId(chatId)

method onNotificationsUpdated[T](self: Module[T], sectionId: string, sectionHasUnreadMessages: bool,
    sectionNotificationCount: int) =
  self.view.model().updateNotifications(sectionId, sectionHasUnreadMessages, sectionNotificationCount)

method onNetworkConnected[T](self: Module[T]) =
  self.view.setConnected(true)

method onNetworkDisconnected[T](self: Module[T]) =
  self.view.setConnected(false)

method isConnected[T](self: Module[T]): bool =
  self.controller.isConnected()

method getAppSearchModule*[T](self: Module[T]): QVariant =
  self.appSearchModule.getModuleAsVariant()

method communitySpectated*[T](self: Module[T], communityId: string) =
  if self.pendingSpectateRequest.communityId != communityId:
    return
  self.pendingSpectateRequest.communityId = ""
  if self.pendingSpectateRequest.channelUuid == "":
    return
  let chatId = communityId & self.pendingSpectateRequest.channelUuid
  self.pendingSpectateRequest.channelUuid = ""
  self.controller.switchTo(communityId, chatId, "")

method communityJoined*[T](
  self: Module[T],
  community: CommunityDto,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service,
  walletAccountService: wallet_account_service.Service,
  tokenService: token_service.Service,
  communityTokensService: community_tokens_service.Service,
  sharedUrlsService: urls_service.Service,
  setActive: bool = false,
) =
  if self.channelGroupModules.contains(community.id):
    # The community is already spectated
    return
  var firstCommunityJoined = false
  if (self.channelGroupModules.len == 1): # First one is personal chat section
    firstCommunityJoined = true
  self.channelGroupModules[community.id] = chat_section_module.newModule(
      self,
      events,
      community.id,
      isCommunity = true,
      settingsService,
      nodeConfigurationService,
      contactsService,
      chatService,
      communityService,
      messageService,
      gifService,
      mailserversService,
      walletAccountService,
      tokenService,
      communityTokensService,
      sharedUrlsService,
    )
  let channelGroup = community.toChannelGroupDto()
  self.channelGroupModules[community.id].load()

  let communitySectionItem = self.createChannelGroupItem(channelGroup)
  if (firstCommunityJoined):
    # If there are no other communities, add the first community after the Chat section in the model so that the order is respected
    self.view.model().addItem(communitySectionItem,
      self.view.model().getItemIndex(singletonInstance.userProfile.getPubKey()) + 1)
  else:
    self.view.model().addItem(communitySectionItem)

  if setActive:
    self.setActiveSection(communitySectionItem)
    if(channelGroup.chats.len > 0):
      let chatId = channelGroup.chats[0].id
      self.channelGroupModules[community.id].setActiveItem(chatId)

method communityLeft*[T](self: Module[T], communityId: string) =
  if(not self.channelGroupModules.contains(communityId)):
    echo "main-module, unexisting community key to leave: ", communityId
    return

  self.channelGroupModules.del(communityId)

  self.view.model().removeItem(communityId)

  singletonInstance.localAccountSensitiveSettings.removeSectionChatRecord(communityId)

  if (self.controller.getActiveSectionId() == communityId):
    let item = self.view.model().getItemById(singletonInstance.userProfile.getPubKey())
    self.setActiveSection(item)

  var moduleToDelete: chat_section_module.AccessInterface
  discard self.channelGroupModules.pop(communityId, moduleToDelete)
  moduleToDelete.delete
  moduleToDelete = nil

method communityEdited*[T](
    self: Module[T],
    community: CommunityDto) =
  let channelGroup = community.toChannelGroupDto()
  var channelGroupItem = self.createChannelGroupItem(channelGroup)
  # We need to calculate the unread counts because the community update doesn't come with it
  let (unviewedMessagesCount, unviewedMentionsCount) = self.controller.sectionUnreadMessagesAndMentionsCount(
    channelGroupItem.id
  )
  channelGroupItem.setHasNotification(unviewedMessagesCount > 0)
  channelGroupItem.setNotificationsCount(unviewedMentionsCount)
  self.view.editItem(channelGroupItem)

method onCommunityMuted*[T](
    self: Module[T],
    communityId: string,
    muted: bool) =
  self.view.model.setMuted(communityId, muted)

method getVerificationRequestFrom*[T](self: Module[T], publicKey: string): VerificationRequest =
  self.controller.getVerificationRequestFrom(publicKey)

method getContactDetailsAsJson*[T](self: Module[T], publicKey: string, getVerificationRequest: bool, getOnlineStatus: bool): string =
  let contact = self.controller.getContact(publicKey)
  var requestStatus = 0
  if getVerificationRequest:
    requestStatus = self.getVerificationRequestFrom(publicKey).status.int
  var onlineStatus = OnlineStatus.Inactive
  if getOnlineStatus:
    onlineStatus = toOnlineStatus(self.controller.getStatusForContactWithId(publicKey).statusType)
  let jsonObj = %* {
    "displayName": contact.displayName,
    "displayIcon": contact.image.thumbnail,
    "publicKey": contact.id,
    "name": contact.name,
    "ensVerified": contact.ensVerified,
    "alias": contact.alias,
    "lastUpdated": contact.lastUpdated,
    "lastUpdatedLocally": contact.lastUpdatedLocally,
    "localNickname": contact.localNickname,
    "thumbnailImage": contact.image.thumbnail,
    "largeImage": contact.image.large,
    "isContact": contact.isContact,
    "isBlocked": contact.blocked,
    "requestReceived": contact.hasAddedUs,
    "isAdded": contact.isContactRequestSent,
    "isSyncing": contact.isSyncing,
    "removed": contact.removed,
    "trustStatus": contact.trustStatus.int,
    # TODO rename verificationStatus to outgoingVerificationStatus
    "contactRequestState": contact.contactRequestState.int,
    "verificationStatus": contact.verificationStatus.int,
    "incomingVerificationStatus": requestStatus,
    "hasAddedUs": contact.hasAddedUs,
    "socialLinks": $contact.socialLinks.toJsonNode(),
    "bio": contact.bio,
    "onlineStatus": onlineStatus.int
  }
  return $jsonObj

# used in FinaliseOwnershipPopup in UI
method getOwnerTokenAsJson*[T](self: Module[T], communityId: string): string =
  let item = self.view.model().getItemById(communityId)
  if item.id == "":
    return
  let tokensModel = item.communityTokens()
  let ownerToken = tokensModel.getOwnerToken()
  let jsonObj = %* {
    "symbol": ownerToken.tokenDto.symbol,
    "chainName": ownerToken.chainName,
    "accountName": ownerToken.accountName,
    "accountAddress": ownerToken.tokenDto.deployer,
    "contractUniqueKey": common_utils.contractUniqueKey(ownerToken.tokenDto.chainId, ownerToken.tokenDto.address)
  }
  return $jsonObj

method isEnsVerified*[T](self: Module[T], publicKey: string): bool =
  return self.controller.getContact(publicKey).ensVerified

method communityDataImported*[T](self: Module[T], community: CommunityDto) =
  if community.id == self.pendingSpectateRequest.communityId:
    discard self.communitiesModule.spectateCommunity(community.id)

method resolveENS*[T](self: Module[T], ensName: string, uuid: string, reason: string = "") =
  if ensName.len == 0:
    echo "error: cannot do a lookup for empty ens name"
    return
  self.controller.resolveENS(ensName, uuid, reason)

method resolvedENS*[T](self: Module[T], publicKey: string, address: string, uuid: string, reason: string) =
  if(reason.len > 0 and publicKey.len == 0):
    self.displayEphemeralNotification("Unexisting contact", "Wrong public key or ens name", "", false, EphemeralNotificationType.Default.int, "")
    return

  if(reason == STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.DisplayUserProfile):
    self.switchToContactOrDisplayUserProfile(publicKey)
  else:
    self.view.emitResolvedENSSignal(publicKey, address, uuid)

method onCommunityTokenDeploymentStarted*[T](self: Module[T], communityToken: CommunityTokenDto) =
  let item = self.view.model().getItemById(communityToken.communityId)
  if item.id != "":
    item.appendCommunityToken(self.createTokenItem(communityToken))

method onOwnerTokensDeploymentStarted*[T](self: Module[T], ownerToken: CommunityTokenDto, masterToken: CommunityTokenDto) =
  let item = self.view.model().getItemById(ownerToken.communityId)
  if item.id != "":
    item.appendCommunityToken(self.createTokenItem(ownerToken))
    item.appendCommunityToken(self.createTokenItem(masterToken))

method onCommunityTokenRemoved*[T](self: Module[T], communityId: string, chainId: int, address: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.removeCommunityToken(chainId, address)

method onCommunityTokenOwnersFetched*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string, owners: seq[CommunityCollectibleOwner]) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.setCommunityTokenOwners(chainId, contractAddress, owners)

method onCommunityTokenDeployStateChanged*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string, deployState: DeployState) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updateCommunityTokenDeployState(chainId, contractAddress, deployState)

method onFinaliseOwnershipStatusChanged*[T](self: Module[T], isPending: bool, communityId: string) =
  self.view.model().updateIsPendingOwnershipRequest(communityId, isPending)

method onOwnerTokenDeployStateChanged*[T](self: Module[T], communityId: string, chainId: int, ownerContractAddress: string, masterContractAddress: string, deployState: DeployState, transactionHash: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    # update temporary master contract address first
    if transactionHash != "":
      item.updateCommunityTokenAddress(chainId, temporaryMasterContractAddress(transactionHash), masterContractAddress)
      item.updateCommunityTokenAddress(chainId, temporaryOwnerContractAddress(transactionHash), ownerContractAddress)
    # then update states
    item.updateCommunityTokenDeployState(chainId, ownerContractAddress, deployState)
    item.updateCommunityTokenDeployState(chainId, masterContractAddress, deployState)

method onCommunityTokenSupplyChanged*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string, supply: Uint256, remainingSupply: Uint256, destructedAmount: Uint256) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updateCommunityTokenSupply(chainId, contractAddress, supply, destructedAmount)
    item.updateCommunityRemainingSupply(chainId, contractAddress, remainingSupply)

method onBurnStateChanged*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string, burnState: ContractTransactionStatus) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updateBurnState(chainId, contractAddress, burnState)

method onRemoteDestructed*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string, addresses: seq[string]) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updateRemoteDestructedAddresses(chainId, contractAddress, addresses)

method onRequestReevaluateMembersPermissionsIfRequired*[T](self: Module[T], communityId: string, chainId: int, contractAddress: string) =
  let communityDto = self.controller.getCommunityById(communityId)
  for _, tokenPermission in communityDto.tokenPermissions.pairs:
    if tokenPermission.type != TokenPermissionType.BecomeTokenOwner:
      for tokenCriteria in tokenPermission.tokenCriteria:
        if tokenCriteria.contractAddresses.hasKey(chainId):
          let actualAddress = tokenCriteria.contractAddresses[chainId]
          if actualAddress == contractAddress:
            self.controller.asyncReevaluateCommunityMembersPermissions(communityId)
            return

method onAcceptRequestToJoinLoading*[T](self: Module[T], communityId: string, memberKey: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updatePendingRequestLoadingState(memberKey, true)

method onAcceptRequestToJoinFailed*[T](self: Module[T], communityId: string, memberKey: string, requestId: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updatePendingRequestLoadingState(memberKey, false)

method onAcceptRequestToJoinFailedNoPermission*[T](self: Module[T], communityId: string, memberKey: string, requestId: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updatePendingRequestLoadingState(memberKey, false)

method onAcceptRequestToJoinSuccess*[T](self: Module[T], communityId: string, memberKey: string, requestId: string) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updatePendingRequestLoadingState(memberKey, false)

method onMembershipStatusUpdated*[T](self: Module[T], communityId: string, memberPubkey: string, status: MembershipRequestState) =
  let item = self.view.model().getItemById(communityId)
  if item.id != "":
    item.updateMembershipStatus(memberPubkey, status)

method calculateProfileSectionHasNotification*[T](self: Module[T]): bool =
  return not self.controller.isMnemonicBackedUp()

method mnemonicBackedUp*[T](self: Module[T]) =
  self.view.model().updateNotifications(
    conf.SETTINGS_SECTION_ID,
    self.calculateProfileSectionHasNotification(),
    notificationsCount = 0)

method displayWindowsOsNotification*[T](self: Module[T], title: string,
    message: string) =
  self.view.displayWindowsOsNotification(title, message)

method osNotificationClicked*[T](self: Module[T], details: NotificationDetails) =
  if(details.notificationType == NotificationType.NewContactRequest):
    self.controller.switchTo(details.sectionId, "", "")
    self.view.emitOpenActivityCenterSignal()
  elif(details.notificationType == NotificationType.JoinCommunityRequest):
    self.controller.switchTo(details.sectionId, "", "")
    self.view.emitOpenCommunityMembershipRequestsViewSignal(details.sectionId)
  elif(details.notificationType == NotificationType.MyRequestToJoinCommunityAccepted):
    self.controller.switchTo(details.sectionId, "", "")
  elif(details.notificationType == NotificationType.MyRequestToJoinCommunityRejected):
    echo "There is no particular action clicking on a notification informing you about rejection to join community"

method newCommunityMembershipRequestReceived*[T](self: Module[T], membershipRequest: CommunityMembershipRequestDto) =
  let (contactName, _, _) = self.controller.getContactNameAndImage(membershipRequest.publicKey)
  let community =  self.controller.getCommunityById(membershipRequest.communityId)
  singletonInstance.globalEvents.newCommunityMembershipRequestNotification("New membership request",
  fmt "{contactName} asks to join {community.name}", community.id)

method meMentionedCountChanged*[T](self: Module[T], allMentions: int) =
  singletonInstance.globalEvents.meMentionedIconBadgeNotification(allMentions)

method displayEphemeralNotification*[T](self: Module[T], title: string, subTitle: string, icon: string, loading: bool,
  ephNotifType: int, url: string, details = NotificationDetails()) =
  let now = getTime()
  let id = now.toUnix * 1000000000 + now.nanosecond
  var finalEphNotifType = EphemeralNotificationType.Default
  if(ephNotifType == EphemeralNotificationType.Success.int):
    finalEphNotifType = EphemeralNotificationType.Success
  elif(ephNotifType == EphemeralNotificationType.Danger.int):
    finalEphNotifType = EphemeralNotificationType.Danger

  let item = ephemeral_notification_item.initItem(id, title, TOAST_MESSAGE_VISIBILITY_DURATION_IN_MS, subTitle, icon, "",
  loading, finalEphNotifType, url, 0, "", details)
  self.view.ephemeralNotificationModel().addItem(item)

# TO UNIFY with the one above.
# Further refactor will be done in a next step
method displayEphemeralWithActionNotification*[T](self: Module[T], title: string, subTitle: string, icon: string, iconColor: string, loading: bool,
  ephNotifType: int, actionType: int, actionData: string, details = NotificationDetails()) =
  let now = getTime()
  let id = now.toUnix * 1000000000 + now.nanosecond
  var finalEphNotifType = EphemeralNotificationType.Default
  if(ephNotifType == EphemeralNotificationType.Success.int):
    finalEphNotifType = EphemeralNotificationType.Success
  elif(ephNotifType == EphemeralNotificationType.Danger.int):
    finalEphNotifType = EphemeralNotificationType.Danger

  let item = ephemeral_notification_item.initItem(id, title, TOAST_MESSAGE_VISIBILITY_DURATION_IN_MS, subTitle, icon, iconColor,
  loading, finalEphNotifType, "", actionType, actionData, details)
  self.view.ephemeralNotificationModel().addItem(item)

method displayEphemeralNotification*[T](self: Module[T], title: string, subTitle: string, details: NotificationDetails) =
  if(details.notificationType == NotificationType.NewMessage or
    details.notificationType == NotificationType.NewMessageWithPersonalMention or
    details.notificationType == NotificationType.CommunityTokenPermissionCreated or
    details.notificationType == NotificationType.CommunityTokenPermissionUpdated or
    details.notificationType == NotificationType.CommunityTokenPermissionDeleted or
    details.notificationType == NotificationType.CommunityTokenPermissionCreationFailed or
    details.notificationType == NotificationType.CommunityTokenPermissionUpdateFailed or
    details.notificationType == NotificationType.CommunityTokenPermissionDeletionFailed or
    details.notificationType == NotificationType.NewMessageWithGlobalMention):
    self.displayEphemeralNotification(title, subTitle, "", false, EphemeralNotificationType.Default.int, "", details)

  elif(details.notificationType == NotificationType.NewContactRequest or
    details.notificationType == NotificationType.IdentityVerificationRequest or
    details.notificationType == NotificationType.ContactRemoved):
    self.displayEphemeralNotification(title, subTitle, "contact", false, EphemeralNotificationType.Default.int, "", details)

  elif(details.notificationType == NotificationType.AcceptedContactRequest):
    self.displayEphemeralNotification(title, subTitle, "checkmark-circle", false, EphemeralNotificationType.Success.int, "", details)

method removeEphemeralNotification*[T](self: Module[T], id: int64) =
  self.view.ephemeralNotificationModel().removeItemWithId(id)

method ephemeralNotificationClicked*[T](self: Module[T], id: int64) =
  let item = self.view.ephemeralNotificationModel().getItemWithId(id)
  if(item.details.isEmpty()):
    return
  if(item.details.notificationType == NotificationType.NewMessage or
    item.details.notificationType == NotificationType.NewMessageWithPersonalMention or
    item.details.notificationType == NotificationType.NewMessageWithGlobalMention):
    self.controller.switchTo(item.details.sectionId, item.details.chatId, item.details.messageId)
  else:
    self.osNotificationClicked(item.details)

method onMyRequestAdded*[T](self: Module[T]) =
    self.displayEphemeralNotification("Your Request has been submitted", "" , "checkmark-circle", false, EphemeralNotificationType.Success.int, "")


proc switchToContactOrDisplayUserProfile[T](self: Module[T], publicKey: string) =
  let contact = self.controller.getContact(publicKey)
  if contact.isContact:
    self.getChatSectionModule().switchToOrCreateOneToOneChat(publicKey)
  else:
    self.view.emitDisplayUserProfileSignal(publicKey)

method onStatusUrlRequested*[T](self: Module[T], action: StatusUrlAction, communityId: string, channelId: string,
    url: string, userId: string, shard: Shard) =

  case action:
    of StatusUrlAction.DisplayUserProfile:
      if singletonInstance.utils().isCompressedPubKey(userId):
        let contactPk = singletonInstance.utils().getDecompressedPk(userId)
        self.switchToContactOrDisplayUserProfile(contactPk)
      else:
        self.resolveENS(userId, "", STATUS_URL_ENS_RESOLVE_REASON & $StatusUrlAction.DisplayUserProfile)

    of StatusUrlAction.OpenCommunity:
      let item = self.view.model().getItemById(communityId)
      if item.isEmpty():
        # request community info and then spectate
        self.pendingSpectateRequest.communityId = communityId
        self.pendingSpectateRequest.channelUuid = ""
        self.communitiesModule.requestCommunityInfo(communityId, shard, importing = false)
        return

      self.controller.switchTo(communityId, "", "")

    of StatusUrlAction.OpenCommunityChannel:
      let chatId = communityId & channelId
      let item = self.view.model().getItemById(communityId)

      if item.isEmpty():
        self.pendingSpectateRequest.communityId = communityId
        self.pendingSpectateRequest.channelUuid = channelId
        self.communitiesModule.requestCommunityInfo(communityId, shard, importing = false)
        return

      self.controller.switchTo(communityId, chatId, "")

    else:
      return

  # enable after MVP
  #else(action == StatusUrlAction.OpenLinkInBrowser and singletonInstance.localAccountSensitiveSettings.getIsBrowserEnabled()):
  #  let item = self.view.model().getItemById(conf.BROWSER_SECTION_ICON)
  #  self.setActiveSection(item)
  #  self.browserSectionModule.openUrl(url)

################################################################################
## keycard shared module - authentication/sign purpose
################################################################################
proc isSharedKeycardModuleForAuthenticationOrSigningRunning[T](self: Module[T]): bool =
  return not self.keycardSharedModuleForAuthenticationOrSigning.isNil

method getKeycardSharedModuleForAuthenticationOrSigning*[T](self: Module[T]): QVariant =
  if self.isSharedKeycardModuleForAuthenticationOrSigningRunning():
    return self.keycardSharedModuleForAuthenticationOrSigning.getModuleAsVariant()

proc createSharedKeycardModuleForAuthenticationOrSigning[T](self: Module[T], identifier: string) =
  self.keycardSharedModuleForAuthenticationOrSigning = keycard_shared_module.newModule[Module[T]](self, identifier,
    self.events, self.keycardService, self.settingsService, self.networkService, self.privacyService, self.accountsService,
    self.walletAccountService, self.keychainService)

method onSharedKeycarModuleForAuthenticationOrSigningTerminated*[T](self: Module[T], lastStepInTheCurrentFlow: bool) =
  if self.isSharedKeycardModuleForAuthenticationOrSigningRunning():
    self.view.emitDestroyKeycardSharedModuleForAuthenticationOrSigning()
    self.keycardSharedModuleForAuthenticationOrSigning.delete
    self.keycardSharedModuleForAuthenticationOrSigning = nil

method runAuthenticationOrSigningPopup*[T](self: Module[T], flow: keycard_shared_module.FlowType, keyUid: string,
  bip44Paths: seq[string] = @[], dataToSign = "") =
  var identifier = UNIQUE_MAIN_MODULE_AUTHENTICATE_KEYPAIR_IDENTIFIER
  if flow == keycard_shared_module.FlowType.Sign:
    identifier = UNIQUE_MAIN_MODULE_SIGNING_DATA_IDENTIFIER
  self.createSharedKeycardModuleForAuthenticationOrSigning(identifier)
  if self.keycardSharedModuleForAuthenticationOrSigning.isNil:
    return
  self.keycardSharedModuleForAuthenticationOrSigning.runFlow(flow, keyUid, bip44Paths, dataToSign)

method onDisplayKeycardSharedModuleForAuthenticationOrSigning*[T](self: Module[T]) =
  self.view.emitDisplayKeycardSharedModuleForAuthenticationOrSigning()
################################################################################

################################################################################
## keycard shared module - keycard syncing purpose
################################################################################
method onSharedKeycarModuleKeycardSyncPurposeTerminated*[T](self: Module[T], lastStepInTheCurrentFlow: bool) =
  if not self.keycardSharedModuleKeycardSyncPurpose.isNil:
    self.keycardSharedModuleKeycardSyncPurpose.delete
    self.keycardSharedModuleKeycardSyncPurpose = nil

method tryKeycardSync*[T](self: Module[T], keyUid: string, pin: string) =
  self.keycardSharedModuleKeycardSyncPurpose = keycard_shared_module.newModule[Module[T]](self, UNIQUE_MAIN_MODULE_KEYCARD_SYNC_IDENTIFIER,
    self.events, self.keycardService, self.settingsService, self.networkService, self.privacyService, self.accountsService,
    self.walletAccountService, self.keychainService)
  if self.keycardSharedModuleKeycardSyncPurpose.isNil:
    return
  self.keycardSharedModuleKeycardSyncPurpose.syncKeycardBasedOnAppState(keyUid, pin)
################################################################################

################################################################################
## keycard shared module - general purpose
################################################################################
method getKeycardSharedModule*[T](self: Module[T]): QVariant =
  if not self.keycardSharedModule.isNil:
    return self.keycardSharedModule.getModuleAsVariant()

method onSharedKeycarModuleFlowTerminated*[T](self: Module[T], lastStepInTheCurrentFlow: bool, nextFlow: keycard_shared_module.FlowType,
  forceFlow: bool, nextKeyUid: string, returnToFlow: keycard_shared_module.FlowType) =
  if not self.keycardSharedModule.isNil:
    if nextFlow == keycard_shared_module.FlowType.General:
      self.view.emitDestroyKeycardSharedModuleFlow()
      self.keycardSharedModule.delete
      self.keycardSharedModule = nil
      return
    self.keycardSharedModule.runFlow(nextFlow, nextKeyUid, bip44Paths = @[], txHash = "", forceFlow, returnToFlow)

method onDisplayKeycardSharedModuleFlow*[T](self: Module[T]) =
  self.view.emitDisplayKeycardSharedModuleFlow()

proc runStopUsingKeycardForProfilePopup[T](self: Module[T]) =
  if not self.keycardSharedModule.isNil:
    info "shared keycard module is already running, cannot run stop using keycard flow"
    return
  self.keycardSharedModule = keycard_shared_module.newModule[Module[T]](self, UNIQUE_MAIN_MODULE_SHARED_KEYCARD_MODULE_IDENTIFIER,
    self.events, self.keycardService, self.settingsService, self.networkService, self.privacyService, self.accountsService,
    self.walletAccountService, self.keychainService)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.MigrateFromKeycardToApp,
    singletonInstance.userProfile.getKeyUid(), bip44Paths = @[], txHash = "", forceFlow = true)

proc runStartUsingKeycardForProfilePopup[T](self: Module[T]) =
  if not self.keycardSharedModule.isNil:
    info "shared keycard module is already running, cannot run start using keycard flow"
    return
  self.keycardSharedModule = keycard_shared_module.newModule[Module[T]](self, UNIQUE_MAIN_MODULE_SHARED_KEYCARD_MODULE_IDENTIFIER,
    self.events, self.keycardService, self.settingsService, self.networkService, self.privacyService, self.accountsService,
    self.walletAccountService, self.keychainService)
  self.keycardSharedModule.runFlow(keycard_shared_module.FlowType.MigrateFromAppToKeycard,
    singletonInstance.userProfile.getKeyUid(), bip44Paths = @[], txHash = "", forceFlow = true)
################################################################################

method checkAndPerformProfileMigrationIfNeeded*[T](self: Module[T]) =
  let migrationNeeded = self.settingsService.getProfileMigrationNeeded()
  let profileKeypair = self.walletAccountService.getKeypairByKeyUid(singletonInstance.userProfile.getKeyUid())
  if profileKeypair.isNil:
    info "quit the app because of unresolved profile keypair"
    quit() # quit the app
  if not migrationNeeded:
    if not self.keycardSharedModule.isNil:
      let currentFlow = self.keycardSharedModule.getCurrentFlowType()
      if currentFlow == FlowType.MigrateFromKeycardToApp or
        currentFlow == FlowType.MigrateFromAppToKeycard:
          self.keycardSharedModule.onCancelActionClicked()
    return
  if profileKeypair.migratedToKeycard():
    if not self.keycardSharedModule.isNil:
      let currentFlow = self.keycardSharedModule.getCurrentFlowType()
      if currentFlow == FlowType.MigrateFromKeycardToApp:
        return
      self.keycardSharedModule.onCancelActionClicked()
    info "run stop using keycard flow for the profile, cause profile was migrated on paired device"
    self.runStopUsingKeycardForProfilePopup()
    return
  if not self.keycardSharedModule.isNil:
    let currentFlow = self.keycardSharedModule.getCurrentFlowType()
    if currentFlow == FlowType.MigrateFromAppToKeycard:
      return
    self.keycardSharedModule.onCancelActionClicked()
  info "run migrate to a Keycard flow for the profile, cause profile was migrated on paired device"
  self.runStartUsingKeycardForProfilePopup()


method activateStatusDeepLink*[T](self: Module[T], statusDeepLink: string) =
  if not self.chatsLoaded:
    self.statusDeepLinkToActivate = statusDeepLink
    return
  let urlData = self.sharedUrlsModule.parseSharedUrl(statusDeepLink)
  if urlData.channel.uuid != "":
    self.onStatusUrlRequested(StatusUrlAction.OpenCommunityChannel, urlData.community.communityId, urlData.channel.uuid,
      url="", userId="", urlData.community.shard)
    return
  if urlData.community.communityId != "":
    self.onStatusUrlRequested(StatusUrlAction.OpenCommunity, urlData.community.communityId, channelId="", url="", userId="", urlData.community.shard)
    return
  if urlData.contact.publicKey != "":
    self.onStatusUrlRequested(StatusUrlAction.DisplayUserProfile, communityId="", channelId="", url="",
      urlData.contact.publicKey, urlData.community.shard)
    return

method onDeactivateChatLoader*[T](self: Module[T], sectionId: string, chatId: string) =
  if (sectionId.len > 0 and self.channelGroupModules.contains(sectionId)):
    self.channelGroupModules[sectionId].onDeactivateChatLoader(chatId)

method windowActivated*[T](self: Module[T]) =
  self.controller.slowdownArchivesImport()

method windowDeactivated*[T](self: Module[T]) =
  self.controller.speedupArchivesImport()

method communityMembersRevealedAccountsLoaded*[T](self: Module[T], communityId: string, membersRevealedAccounts: MembersRevealedAccounts) =
  var  communityMembersAirdropAddress: Table[string, string]
  for pubkey, revealedAccounts in membersRevealedAccounts.pairs:
    for revealedAccount in revealedAccounts:
      if revealedAccount.isAirdropAddress:
        communityMembersAirdropAddress[pubkey] = revealedAccount.address
        discard

  self.view.model.setMembersAirdropAddress(communityId, communityMembersAirdropAddress)

## Used in test env only, for testing keycard flows
method registerMockedKeycard*[T](self: Module[T], cardIndex: int, readerState: int, keycardState: int,
  mockedKeycard: string, mockedKeycardHelper: string) =
  self.keycardService.registerMockedKeycard(cardIndex, readerState, keycardState, mockedKeycard, mockedKeycardHelper)

method pluginMockedReaderAction*[T](self: Module[T]) =
  self.keycardService.pluginMockedReaderAction()

method unplugMockedReaderAction*[T](self: Module[T]) =
  self.keycardService.unplugMockedReaderAction()

method insertMockedKeycardAction*[T](self: Module[T], cardIndex: int) =
  self.keycardService.insertMockedKeycardAction(cardIndex)

method removeMockedKeycardAction*[T](self: Module[T]) =
  self.keycardService.removeMockedKeycardAction()

method fakeLoadingScreenFinished*[T](self: Module[T]) =
  self.events.emit(FAKE_LOADING_SCREEN_FINISHED, Args())

{.pop.}
