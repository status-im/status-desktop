import NimQml, chronicles, sequtils, sugar, json, strutils

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

# TODO: remove usage of old models
import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

import models/showcase_preferences_generic_model
import models/showcase_preferences_social_links_model
import models/profile_save_data

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

method getBio(self: Module): string =
  self.controller.getBio()

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

method getProfileShowcaseSocialLinksLimit*(self: Module): int =
  return self.controller.getProfileShowcaseSocialLinksLimit()

method getProfileShowcaseEntriesLimit*(self: Module): int =
  return self.controller.getProfileShowcaseEntriesLimit()

method setIsFirstShowcaseInteraction(self: Module) =
  singletonInstance.localAccountSettings.setIsFirstShowcaseInteraction(false)

proc storeIdentityImage*(self: Module, identityImage: IdentityImage) =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  let image = singletonInstance.utils.formatImagePath(identityImage.source)
  # FIXME the function to get the file size is messed up
  # let size = image_getFileSize(image)
  # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
  # return "Max file size is 20MB"
  self.controller.storeIdentityImage(keyUid, image, identityImage.aX, identityImage.aY, identityImage.bX, identityImage.bY)

proc deleteIdentityImage*(self: Module) =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  self.controller.deleteIdentityImage(keyUid)

method saveProfileIdentityInfo*(self: Module, identity: IdentitySaveData) =
  self.controller.setDisplayName(identity.displayName)
  discard self.controller.setBio(identity.bio)
  if identity.image != nil:
    self.storeIdentityImage(identity.image)
  else:
    self.deleteIdentityImage()

method saveProfileShowcasePreferences*(self: Module, showcase: ShowcaseSaveData) =
  # TODO: remove this check within old api
  if self.presentedPublicKey != singletonInstance.userProfile.getPubKey():
    error "Attempt to save preferences with wrong public key"
    return

  var showcasePreferences = ProfileShowcasePreferencesDto()

  for _, showcaseCommunity in showcase.communities:
    showcasePreferences.communities.add(ProfileShowcaseCommunityPreference(
      communityId: showcaseCommunity.showcaseKey,
      showcaseVisibility: showcaseCommunity.showcaseVisibility,
      order: showcaseCommunity.showcasePosition
    ))

  var revealedAddresses: seq[string]
  for _, showcaseAccount in showcase.accounts:
    showcasePreferences.accounts.add(ProfileShowcaseAccountPreference(
      address: showcaseAccount.showcaseKey,
      showcaseVisibility: showcaseAccount.showcaseVisibility,
      order: showcaseAccount.showcasePosition
    ))

    if showcaseAccount.showcaseVisibility != ProfileShowcaseVisibility.ToNoOne:
      revealedAddresses.add(showcaseAccount.showcaseKey)

  for _, showcaseCollectible in showcase.collectibles:
    let parts = showcaseCollectible.showcaseKey.split('+')
    if len(parts) == 3:
      showcasePreferences.collectibles.add(ProfileShowcaseCollectiblePreference(
        chainId: parseInt(parts[0]),
        contractAddress: parts[1],
        tokenId: parts[2],
        showcaseVisibility: showcaseCollectible.showcaseVisibility,
        order: showcaseCollectible.showcasePosition
      ))
    else:
      error "Wrong collectible combined id provided"

  for _, showcaseAsset in showcase.assets:
    # TODO: less fragile way to split verified and unverified assets
    if len(showcaseAsset.showcaseKey) == 3:
      showcasePreferences.verifiedTokens.add(ProfileShowcaseVerifiedTokenPreference(
        symbol: showcaseAsset.showcaseKey,
        showcaseVisibility: showcaseAsset.showcaseVisibility,
        order: showcaseAsset.showcasePosition
      ))
    else:
      let parts = showcaseAsset.showcaseKey.split('+')
      if len(parts) == 2:
        showcasePreferences.unverifiedTokens.add(ProfileShowcaseUnverifiedTokenPreference(
          chainId: parseInt(parts[0]),
          contractAddress: parts[1],
          showcaseVisibility: showcaseAsset.showcaseVisibility,
          order: showcaseAsset.showcasePosition
        ))
      else:
        error "Wrong unverified asset combined id provided"

  for _, showcaseSocialLink in showcase.socialLinks:
    showcasePreferences.socialLinks.add(ProfileShowcaseSocialLinkPreference(
      text: showcaseSocialLink.text,
      url: showcaseSocialLink.url,
      showcaseVisibility: showcaseSocialLink.showcaseVisibility,
      order: showcaseSocialLink.showcasePosition
    ))

  self.controller.storeProfileShowcasePreferences(showcasePreferences, revealedAddresses)

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

  var communityItems: seq[ShowcasePreferencesGenericItem] = @[]
  for community in preferences.communities:
    communityItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: community.communityId,
      showcaseVisibility: community.showcaseVisibility,
      showcasePosition: community.order
    ))
  self.view.updateProfileShowcasePreferencesCommunities(communityItems)

  var accountItems: seq[ShowcasePreferencesGenericItem] = @[]
  for account in preferences.accounts:
    accountItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: account.address,
      showcaseVisibility: account.showcaseVisibility,
      showcasePosition: account.order
    ))
  self.view.updateProfileShowcasePreferencesAccounts(accountItems)

  var collectibleItems: seq[ShowcasePreferencesGenericItem] = @[]
  for collectible in preferences.collectibles:
    collectibleItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: collectible.toCombinedCollectibleId(),
      showcaseVisibility: collectible.showcaseVisibility,
      showcasePosition: collectible.order
    ))
  self.view.updateProfileShowcasePreferencesCollectibles(collectibleItems)

  var assetItems: seq[ShowcasePreferencesGenericItem] = @[]
  for token in preferences.verifiedTokens:
    assetItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: token.symbol,
      showcaseVisibility: token.showcaseVisibility,
      showcasePosition: token.order
    ))
  for token in preferences.unverifiedTokens:
    assetItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: token.toCombinedTokenId(),
      showcaseVisibility: token.showcaseVisibility,
      showcasePosition: token.order
    ))
  self.view.updateProfileShowcasePreferencesAssets(assetItems)

  var socialLinkItems: seq[ShowcasePreferencesSocialLinkItem] = @[]
  for socialLink in preferences.socialLinks:
    socialLinkItems.add(ShowcasePreferencesSocialLinkItem(
      url: socialLink.url,
      text: socialLink.text,
      showcasePosition: socialLink.order
    ))
  self.view.updateProfileShowcasePreferencesSocialLinks(socialLinkItems)

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
  for preference in preferences.accounts:
    let account = self.controller.getAccountByAddress(preference.address)
    if account == nil:
      error "Can't find an account with address ", address=preference.address
      continue

    profileAccountItems.add(initProfileShowcaseAccountItem(
      account.address, account.name, account.emoji, account.colorId,
      preference.showcaseVisibility, preference.order))
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
