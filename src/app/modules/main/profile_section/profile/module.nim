import NimQml, chronicles, sequtils, sugar, json

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import app/global/global_singleton

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/network/service as network_service
import app_service/service/profile/dto/profile_showcase
import app_service/service/profile/dto/profile_showcase_preferences
import app_service/service/token/service as token_service
import app_service/common/social_links

import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item
import app/modules/shared_modules/collectibles/controller as collectiblesc
import app/modules/shared_models/collectibles_entry

import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

import models/profile_showcase_preferences_item

import backend/collectibles as backend_collectibles

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.Controller
    collectiblesController: collectiblesc.Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool
    presentedPublicKey: string

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    profileService: profile_service.Service,
    settingsService: settings_service.Service,
    communityService: community_service.Service,
    walletAccountService: wallet_account_service.Service,
    networkService: network_service.Service,
    tokenService: token_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, profileService, settingsService, communityService, walletAccountService, networkService, tokenService)
  result.collectiblesController = collectiblesc.newController(
    requestId = int32(backend_collectibles.CollectiblesRequestID.ProfileShowcase),
    loadType = collectiblesc.LoadType.AutoLoadSingleUpdate,
    networkService = networkService,
    events = events
  )
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete
  self.collectiblesController.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method getCollectiblesModel*(self: Module): QVariant =
  return self.collectiblesController.getModelAsVariant()

proc updateSocialLinks(self: Module, socialLinks: SocialLinks) =
  var socialLinkItems = toSocialLinkItems(socialLinks)
  self.view.socialLinksSaved(socialLinkItems)

method viewDidLoad*(self: Module) =
  self.updateSocialLinks(self.controller.getSocialLinks())
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method storeIdentityImage*(self: Module, imageUrl: string, aX: int, aY: int, bX: int, bY: int) =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  let image = singletonInstance.utils.formatImagePath(imageUrl)
  self.controller.storeIdentityImage(keyUid, image, aX, aY, bX, bY)

method deleteIdentityImage*(self: Module) =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  self.controller.deleteIdentityImage(keyUid)

method setDisplayName*(self: Module, displayName: string) =
  self.controller.setDisplayName(displayName)

method getBio(self: Module): string =
  self.controller.getBio()

method setBio(self: Module, bio: string) =
  discard self.controller.setBio(bio)

method onBioChanged*(self: Module, bio: string) =
  self.view.emitBioChangedSignal()

method saveSocialLinks*(self: Module) =
  let socialLinks = map(self.view.temporarySocialLinksModel.items(), x => SocialLink(text: x.text, url: x.url, icon: x.icon))
  self.controller.setSocialLinks(socialLinks)

method onSocialLinksUpdated*(self: Module, socialLinks: SocialLinks, error: string) =
  if error.len > 0:
    # maybe we want in future popup or somehow display an error to a user
    return
  self.updateSocialLinks(socialLinks)

method storeProfileShowcasePreferences(self: Module,
                                       communities: seq[ProfileShowcaseCommunityItem],
                                       accounts: seq[ProfileShowcaseAccountItem],
                                       collectibles: seq[ProfileShowcaseCollectibleItem],
                                       assets: seq[ProfileShowcaseAssetItem]) =
  if self.presentedPublicKey != singletonInstance.userProfile.getPubKey():
    error "Attempt to save preferences with wrong public key"
    return

  var revealedAddresses: seq[string]
  for acc in accounts:
    if acc.showcaseVisibility != ProfileShowcaseVisibility.ToNoOne:
      revealedAddresses.add(acc.address)

  var verifiedTokens: seq[ProfileShowcaseVerifiedTokenPreference] = @[]
  var unverifiedTokens: seq[ProfileShowcaseUnverifiedTokenPreference] = @[]

  for asset in assets:
    # TODO: more obvious way to check if it is verified or not
    if asset.communityId == "":
      verifiedTokens.add(asset.toShowcaseVerifiedTokenPreference())
    else:
      unverifiedTokens.add(asset.toShowcaseUnverifiedTokenPreference())

  self.controller.storeProfileShowcasePreferences(ProfileShowcasePreferencesDto(
    communities: communities.map(item => item.toShowcasePreferenceItem()),
    accounts: accounts.map(item => item.toShowcasePreferenceItem()),
    collectibles: collectibles.map(item => item.toShowcasePreferenceItem()),
    verifiedTokens: verifiedTokens,
    unverifiedTokens: unverifiedTokens
    ),
    revealedAddresses
  )

method setIsFirstShowcaseInteraction(self: Module) =
  singletonInstance.localAccountSettings.setIsFirstShowcaseInteraction(false)

method requestProfileShowcasePreferences(self: Module) =
  let myPublicKey = singletonInstance.userProfile.getPubKey()
  if self.presentedPublicKey != myPublicKey:
    self.view.clearModels()
  self.presentedPublicKey = myPublicKey

  self.controller.requestProfileShowcasePreferences()

method requestProfileShowcase*(self: Module, publicKey: string) =
  if publicKey == singletonInstance.userProfile.getPubKey():
    self.requestProfileShowcasePreferences()
    return

  if self.presentedPublicKey != publicKey:
    self.view.clearModels()
  self.presentedPublicKey = publicKey

  self.controller.requestProfileShowcaseForContact(publicKey)

method fetchProfileShowcaseAccountsByAddress*(self: Module, address: string) =
  self.controller.fetchProfileShowcaseAccountsByAddress(address)

method onProfileShowcaseAccountsByAddressFetched*(self: Module, accounts: seq[ProfileShowcaseAccount]) =
  let jsonObj = % accounts
  self.view.emitProfileShowcaseAccountsByAddressFetchedSignal($jsonObj)

method updateProfileShowcase(self: Module, profileShowcase: ProfileShowcaseDto) =
  if self.presentedPublicKey != profileShowcase.contactId:
    return

  # Communities for a contact
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  for communityProfile in profileShowcase.communities:
    let community = self.controller.getCommunityById(communityProfile.communityId)
    if community.id == "":
      # Fetch the community, however, we do not the shard info, so hopefully we can fetch it
      self.controller.requestCommunityInfo(communityProfile.communityId, shard = nil)
      profileCommunityItems.add(initProfileShowcaseCommunityLoadingItem(
        communityProfile.communityId, ProfileShowcaseVisibility.ToEveryone, communityProfile.order))
    else:
      profileCommunityItems.add(initProfileShowcaseCommunityItem(
        community, ProfileShowcaseVisibility.ToEveryone, communityProfile.order))
  self.view.updateProfileShowcaseCommunities(profileCommunityItems)

  # Accounts for a contact, reuse addresses for collectibles and token balances
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var accountAddresses: seq[string] = @[]
  for account in profileShowcase.accounts:
    profileAccountItems.add(initProfileShowcaseAccountItem(
      account.address, account.name, account.emoji, account.colorId,
      ProfileShowcaseVisibility.ToEveryone, account.order))
    accountAddresses.add(account.address)
  self.view.updateProfileShowcaseAccounts(profileAccountItems)

  # Collectibles for a contact
  let chainIds = self.controller.getChainIds()
  self.collectiblesController.setFilterAddressesAndChains(accountAddresses, chainIds)

  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  for collectibleProfile in profileShowcase.collectibles:
    let collectible = self.collectiblesController.getItemForData(collectibleProfile.tokenId, collectibleProfile.contractAddress, collectibleProfile.chainId)
    if collectible != nil:
      profileCollectibleItems.add(initProfileShowcaseCollectibleItem(
        collectible, ProfileShowcaseVisibility.ToEveryone, collectibleProfile.order))
  self.view.updateProfileShowcaseCollectibles(profileCollectibleItems)

  # Verified tokens for a contact
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]
  for tokenProfile in profileShowcase.verifiedTokens:
    # NOTE: not yet working for external wallet accounts
    for token in self.controller.getTokenBySymbolList():
      if tokenProfile.symbol == token.symbol:
        profileAssetItems.add(initProfileShowcaseVerifiedToken(token, ProfileShowcaseVisibility.ToEveryone, tokenProfile.order))

  # TODO: Unverified tokens for a contact
  self.view.updateProfileShowcaseAssets(profileAssetItems)

method updateProfileShowcasePreferences(self: Module, preferences: ProfileShowcasePreferencesDto) =
  if self.presentedPublicKey != singletonInstance.userProfile.getPubKey():
    return

  var communityItems: seq[ProfileShowcasePreferencesItem] = @[]
  for community in preferences.communities:
    communityItems.add(initProfileShowcasePreferencesItem(community.communityId, community.showcaseVisibility, community.order))
  self.view.updateProfileShowcasePreferencesCommunities(communityItems)

  var accountItems: seq[ProfileShowcasePreferencesItem] = @[]
  for account in preferences.accounts:
    accountItems.add(initProfileShowcasePreferencesItem(account.address, account.showcaseVisibility, account.order))
  self.view.updateProfileShowcasePreferencesAccounts(accountItems)

  var collectibleItems: seq[ProfileShowcasePreferencesItem] = @[]
  for collectible in preferences.collectibles:
    collectibleItems.add(initProfileShowcasePreferencesItem(collectible.toCombinedCollectibleId(), collectible.showcaseVisibility, collectible.order))
  self.view.updateProfileShowcasePreferencesCollectibles(collectibleItems)

  var assetItems: seq[ProfileShowcasePreferencesItem] = @[]
  for token in preferences.verifiedTokens:
    assetItems.add(initProfileShowcasePreferencesItem(token.symbol, token.showcaseVisibility, token.order))
  self.view.updateProfileShowcasePreferencesAssets(assetItems)

  # TODO: unverified tokens, social links

  # TODO: remove the code for old models
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  for communityProfile in preferences.communities:
    let community = self.controller.getCommunityById(communityProfile.communityId)
    if community.id == "":
      warn "Unknown community added to our own profile showcase" , communityId = communityProfile.communityId
    else:
      profileCommunityItems.add(initProfileShowcaseCommunityItem(
        community, communityProfile.showcaseVisibility, communityProfile.order))
  self.view.updateProfileShowcaseCommunities(profileCommunityItems)

  # For profile preferences we are using all the addresses for colletibles and token balances
  # TODO: add wallet accounts model instance here to remove QML dependency from the wallet module
  let accountAddresses = self.controller.getWalletAccounts().map(acc => acc.address) # filter(acc => acc.walletType != WalletTypeWatch).

  # Accounts profile preferences
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  for account in preferences.accounts:
    profileAccountItems.add(initProfileShowcaseAccountItem(
      account.address, account.name, account.emoji, account.colorId,
      account.showcaseVisibility, account.order))
  self.view.updateProfileShowcaseAccounts(profileAccountItems)

  # Collectibles profile preferences
  let chainIds = self.controller.getChainIds()
  self.collectiblesController.setFilterAddressesAndChains(accountAddresses, chainIds)

  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  for collectibleProfile in preferences.collectibles:
    let collectible = self.collectiblesController.getItemForData(collectibleProfile.tokenId, collectibleProfile.contractAddress, collectibleProfile.chainId)
    if collectible != nil:
      profileCollectibleItems.add(initProfileShowcaseCollectibleItem(
        collectible, collectibleProfile.showcaseVisibility, collectibleProfile.order))
  self.view.updateProfileShowcaseCollectibles(profileCollectibleItems)

  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]
  for tokenProfile in preferences.verifiedTokens:
    for token in self.controller.getTokenBySymbolList():
      if tokenProfile.symbol == token.symbol:
        profileAssetItems.add(initProfileShowcaseVerifiedToken(token, tokenProfile.showcaseVisibility, tokenProfile.order))
  self.view.updateProfileShowcaseAssets(profileAssetItems)

method onCommunitiesUpdated*(self: Module, communities: seq[CommunityDto]) =
  var profileCommunityItems = self.view.getProfileShowcaseCommunities()

  for community in communities:
    for item in profileCommunityItems:
      if item.id == community.id:
        item.patchFromCommunity(community)

  self.view.updateProfileShowcaseCommunities(profileCommunityItems)
