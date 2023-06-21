import NimQml, stint

import ../../../app_service/service/settings/service as settings_service
import ../../../app_service/service/node_configuration/service as node_configuration_service
import ../../../app_service/service/contacts/service as contacts_service
import ../../../app_service/service/chat/service as chat_service
import ../../../app_service/service/community/service as community_service
import ../../../app_service/service/message/service as message_service
import ../../../app_service/service/gif/service as gif_service
import ../../../app_service/service/mailservers/service as mailservers_service
import ../../../app_service/service/community_tokens/service as community_token_service
import ../../../app_service/service/wallet_account/service as wallet_account_service
import ../../../app_service/service/token/service as token_service
import ../../../app_service/service/collectible/service as collectible_service
import ../../../app_service/service/community_tokens/service as community_tokens_service
from ../../../app_service/common/types import StatusType

import ../../global/app_signals
import ../../core/eventemitter
import ../../core/notifications/details
import ../shared_models/section_item

type
  AccessInterface* {.pure inheritable.} = ref object of RootObj

method delete*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method load*(
  self: AccessInterface,
  events: EventEmitter,
  settingsService: settings_service.Service,
  nodeConfigurationService: node_configuration_service.Service,
  contactsService: contacts_service.Service,
  chatService: chat_service.Service,
  communityService: community_service.Service,
  messageService: message_service.Service,
  gifService: gif_service.Service,
  mailserversService: mailservers_service.Service)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method calculateProfileSectionHasNotification*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method appSearchDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method stickersDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activityCenterDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method profileSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method walletSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method browserSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method networkConnectionModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method nodeSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method chatSectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method communitySectionDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChannelGroupsLoaded*(
  self: AccessInterface,
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
  collectibleService: collectible_service.Service,
  communityTokensService: community_tokens_service.Service)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityDataLoaded*(
  self: AccessInterface,
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
  collectibleService: collectible_service.Service,
  communityTokensService: community_tokens_service.Service)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatsLoadingFailed*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onActiveChatChange*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNotificationsUpdated*(self: AccessInterface, sectionId: string, sectionHasUnreadMessages: bool,
  sectionNotificationCount: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNotificationsIncreased*(self: AccessInterface, sectionId: string, addedSectionNotificationCount: bool,
  sectionNotificationCount: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method getActiveSectionId*(self: AccessInterface): string {.base.} =
  raise newException(ValueError, "No implementation available")

method communitiesModuleDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitMailserverWorking*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method emitMailserverNotWorking*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activeSectionSet*(self: AccessInterface, sectionId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method toggleSection*(self: AccessInterface, sectionType: SectionType) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityJoined*(self: AccessInterface, community: CommunityDto, events: EventEmitter,
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
  collectibleService: collectible_service.Service,
  communityTokensService: community_tokens_service.Service,
  setActive: bool = false,) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityEdited*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityMuted*(self: AccessInterface, communityId: string, muted: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method communityLeft*(self: AccessInterface, communityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method resolvedENS*(self: AccessInterface, publicKey: string, address: string, uuid: string, reason: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactsStatusUpdated*(self: AccessInterface, statusUpdates: seq[StatusUpdateDto]) {.base.} =
  raise newException(ValueError, "No implementation available")

method contactUpdated*(self: AccessInterface, publicKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method mnemonicBackedUp*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method osNotificationClicked*(self: AccessInterface, details: NotificationDetails) {.base.} =
  raise newException(ValueError, "No implementation available")

method displayWindowsOsNotification*(self: AccessInterface, title: string, message: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method displayEphemeralNotification*(self: AccessInterface, title: string, subTitle: string, details: NotificationDetails)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method displayEphemeralNotification*(self: AccessInterface, title: string, subTitle: string, icon: string, loading: bool,
    ephNotifType: int, url: string, details = NotificationDetails()) {.base.} =
  raise newException(ValueError, "No implementation available")

method removeEphemeralNotification*(self: AccessInterface, id: int64) {.base.} =
  raise newException(ValueError, "No implementation available")

method ephemeralNotificationClicked*(self: AccessInterface, id: int64) {.base.} =
  raise newException(ValueError, "No implementation available")

method newCommunityMembershipRequestReceived*(self: AccessInterface, membershipRequest: CommunityMembershipRequestDto)
  {.base.} =
  raise newException(ValueError, "No implementation available")

method meMentionedCountChanged*(self: AccessInterface, allMentions: int) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkConnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onNetworkDisconnected*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method viewDidLoad*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSection*(self: AccessInterface, item: SectionItem, skipSavingInSettings: bool = false) {.base.} =
  raise newException(ValueError, "No implementation available")

method setActiveSectionById*(self: AccessInterface, id: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onChatLeft*(self: AccessInterface, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCurrentUserStatus*(self: AccessInterface, status: StatusType) {.base.} =
  raise newException(ValueError, "No implementation available")

method getChatSectionModuleAsVariant*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getCommunitySectionModule*(self: AccessInterface, communityId: string): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getAppSearchModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method getContactDetailsAsJson*(self: AccessInterface, publicKey: string, getVerificationRequest: bool): string {.base.} =
  raise newException(ValueError, "No implementation available")

method isEnsVerified*(self: AccessInterface, publicKey: string): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method communityDataImported*(self: AccessInterface, community: CommunityDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method resolveENS*(self: AccessInterface, ensName: string, uuid: string, reason: string = "") {.base.} =
  raise newException(ValueError, "No implementation available")

method rebuildChatSearchModel*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method switchTo*(self: AccessInterface, sectionId, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method isConnected*(self: AccessInterface): bool {.base.} =
  raise newException(ValueError, "No implementation available")

method onStatusUrlRequested*(self: AccessInterface, action: StatusUrlAction, communityId: string, chatId: string,
  url: string, userId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method getVerificationRequestFrom*(self: AccessInterface, publicKey: string): VerificationRequest {.base.} =
  raise newException(ValueError, "No implementation available")

method getKeycardSharedModule*(self: AccessInterface): QVariant {.base.} =
  raise newException(ValueError, "No implementation available")

method onDisplayKeycardSharedModuleFlow*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSharedKeycarModuleFlowTerminated*(self: AccessInterface, lastStepInTheCurrentFlow: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method runAuthenticationPopup*(self: AccessInterface, keyUid: string, bip44Paths: seq[string] = @[]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onMyRequestAdded*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method activateStatusDeepLink*(self: AccessInterface, statusDeepLink: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method setCommunityIdToSpectate*(self: AccessInterface, commnityId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method tryKeycardSync*(self: AccessInterface, keyUid: string, pin: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onSharedKeycarModuleKeycardSyncPurposeTerminated*(self: AccessInterface, lastStepInTheCurrentFlow: bool) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenDeployed*(self: AccessInterface, communityToken: CommunityTokenDto) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenOwnersFetched*(self: AccessInterface, communityId: string, chainId: int, contractAddress: string, owners: seq[CollectibleOwner]) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenDeployStateChanged*(self: AccessInterface, communityId: string, chainId: int, contractAddress: string, deployState: DeployState) {.base.} =
  raise newException(ValueError, "No implementation available")

method onCommunityTokenSupplyChanged*(self: AccessInterface, communityId: string, chainId: int, contractAddress: string, supply: Uint256, remainingSupply: Uint256) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAcceptRequestToJoinFailed*(self: AccessInterface, communityId: string, memberKey: string, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAcceptRequestToJoinFailedNoPermission*(self: AccessInterface, communityId: string, memberKey: string, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAcceptRequestToJoinLoading*(self: AccessInterface, communityId: string, memberKey: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onAcceptRequestToJoinSuccess*(self: AccessInterface, communityId: string, memberKey: string, requestId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method onDeactivateChatLoader*(self: AccessInterface, sectionId: string, chatId: string) {.base.} =
  raise newException(ValueError, "No implementation available")

method windowActivated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

method windowDeactivated*(self: AccessInterface) {.base.} =
  raise newException(ValueError, "No implementation available")

# This way (using concepts) is used only for the modules managed by AppController
type
  DelegateInterface* = concept c
    c.mainDidLoad()
