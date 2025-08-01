import nimqml, chronicles, strutils

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import app/global/global_singleton

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/profile/dto/profile_showcase_preferences
import app_service/service/token/service as token_service

import models/showcase_preferences_generic_model
import models/showcase_preferences_social_links_model
import models/profile_save_data

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: controller.Controller
    view: View
    viewVariant: QVariant
    moduleLoaded: bool

proc newModule*(
    delegate: delegate_interface.AccessInterface,
    events: EventEmitter,
    profileService: profile_service.Service,
    settingsService: settings_service.Service,
    communityService: community_service.Service,
    walletAccountService: wallet_account_service.Service,
    tokenService: token_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, profileService, settingsService, communityService, walletAccountService, tokenService)
  result.moduleLoaded = false

method delete*(self: Module) =
  self.view.delete
  self.viewVariant.delete
  self.controller.delete

method load*(self: Module) =
  self.controller.init()
  self.view.load()

method isLoaded*(self: Module): bool =
  return self.moduleLoaded

method getModuleAsVariant*(self: Module): QVariant =
  return self.viewVariant

method viewDidLoad*(self: Module) =
  self.moduleLoaded = true
  self.delegate.profileModuleDidLoad()

method getBio(self: Module): string =
  self.controller.getBio()

method onBioChanged*(self: Module, bio: string) =
  self.view.emitBioChangedSignal()

method onProfileShowcasePreferencesSaveSucceeded*(self: Module) =
  self.view.emitProfileShowcasePreferencesSaveSucceededSignal()

method onProfileShowcasePreferencesSaveFailed*(self: Module) =
  self.view.emitProfileShowcasePreferencesSaveFailedSignal()

method getProfileShowcaseSocialLinksLimit*(self: Module): int =
  return self.controller.getProfileShowcaseSocialLinksLimit()

method getProfileShowcaseEntriesLimit*(self: Module): int =
  return self.controller.getProfileShowcaseEntriesLimit()

proc storeIdentityImage*(self: Module, identityImage: IdentityImage): bool =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  let image = singletonInstance.utils.fromPathUri(identityImage.source)
  # FIXME the function to get the file size is messed up
  # let size = image_getFileSize(image)
  # TODO find a way to i18n this (maybe send just a code and then QML sets the right string)
  # return "Max file size is 20MB"
  self.controller.storeIdentityImage(keyUid, image, identityImage.aX, identityImage.aY, identityImage.bX, identityImage.bY)

proc deleteIdentityImage*(self: Module): bool =
  let keyUid = singletonInstance.userProfile.getKeyUid()
  self.controller.deleteIdentityImage(keyUid)

method saveProfileIdentityChanges*(self: Module, identityChanges: IdentityChangesSaveData) =
  var ok = true

  # Update only the fields that have changed
  if identityChanges.displayName.isSome:
    ok = self.controller.setDisplayName(identityChanges.displayName.get)

  if identityChanges.bio.isSome:
    ok = ok and self.controller.setBio(identityChanges.bio.get)

  if identityChanges.image.isSome:
    var image = identityChanges.image.get
    # If the image source is empty, delete the image
    if image.source.isEmptyOrWhitespace:
      ok = ok and self.deleteIdentityImage()
    else:
      ok = ok and self.storeIdentityImage(image)

  if ok:
    self.view.emitProfileIdentitySaveSucceededSignal()
  else:
    self.view.emitProfileIdentitySaveFailedSignal()

method saveProfileShowcasePreferences*(self: Module, showcase: ShowcaseSaveData) =
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

  self.controller.saveProfileShowcasePreferences(showcasePreferences, revealedAddresses)

method requestProfileShowcasePreferences(self: Module) =
  self.controller.requestProfileShowcasePreferences()

method loadProfileShowcasePreferences(self: Module, preferences: ProfileShowcasePreferencesDto) =
  var communityItems: seq[ShowcasePreferencesGenericItem] = @[]
  for community in preferences.communities:
    communityItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: community.communityId,
      showcaseVisibility: community.showcaseVisibility,
      showcasePosition: community.order
    ))
  self.view.loadProfileShowcasePreferencesCommunities(communityItems)

  var accountItems: seq[ShowcasePreferencesGenericItem] = @[]
  for account in preferences.accounts:
    accountItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: account.address,
      showcaseVisibility: account.showcaseVisibility,
      showcasePosition: account.order
    ))
  self.view.loadProfileShowcasePreferencesAccounts(accountItems)

  var collectibleItems: seq[ShowcasePreferencesGenericItem] = @[]
  for collectible in preferences.collectibles:
    collectibleItems.add(ShowcasePreferencesGenericItem(
      showcaseKey: collectible.toCombinedCollectibleId(),
      showcaseVisibility: collectible.showcaseVisibility,
      showcasePosition: collectible.order
    ))
  self.view.loadProfileShowcasePreferencesCollectibles(collectibleItems)

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
  self.view.loadProfileShowcasePreferencesAssets(assetItems)

  var socialLinkItems: seq[ShowcasePreferencesSocialLinkItem] = @[]
  for socialLink in preferences.socialLinks:
    socialLinkItems.add(ShowcasePreferencesSocialLinkItem(
      url: socialLink.url,
      text: socialLink.text,
      showcasePosition: socialLink.order
    ))
  self.view.loadProfileShowcasePreferencesSocialLinks(socialLinkItems)
