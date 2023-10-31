import NimQml, chronicles, sequtils, sugar

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import app/global/global_singleton

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/contacts/service as contacts_service
import app_service/service/profile/dto/profile_showcase_preferences
import app_service/common/social_links

import app/modules/shared_models/social_links_model
import app/modules/shared_models/social_link_item

import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

export io_interface

logScope:
  topics = "profile-section-profile-module"

type
  Module* = ref object of io_interface.AccessInterface
    delegate: delegate_interface.AccessInterface
    controller: Controller
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
    contactsService: contacts_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, profileService, settingsService, communityService, walletAccountService, contactsService)
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
  self.controller.storeProfileShowcasePreferences(ProfileShowcasePreferencesDto(
    communities: communities.map(item => item.toShowcasePreferenceItem()),
    accounts: accounts.map(item => item.toShowcasePreferenceItem()),
    collectibles: collectibles.map(item => item.toShowcasePreferenceItem()),
    assets: assets.map(item => item.toShowcasePreferenceItem())
  ))

method requestProfileShowcasePreferences(self: Module) =
  self.controller.requestProfileShowcasePreferences()

method requestProfileShowcase*(self: Module, publicKey: string) =
  let contact = self.controller.getContactById(publicKey)

  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]

  for communityEntry in contact.profileShowcase.communities:
    # TODO: what if we don't know such community?
    let community = self.controller.getCommunityById(communityEntry.communityId)
    profileCommunityItems.add(initProfileShowcaseCommunityItem(
      community, ProfileShowcaseVisibility.ToEveryone, communityEntry.order))

  for account in contact.profileShowcase.accounts:
    profileAccountItems.add(initProfileShowcaseAccountItem(
      account.address,
      account.name,
      account.emoji,
      account.colorId,
      ProfileShowcaseVisibility.ToEveryone,
      account.order
    ))

    for assetEntry in contact.profileShowcase.assets:
      # TODO: need wallet api to fetch token by symbol
      for token in self.controller.getTokensByAddress(account.address):
        if assetEntry.symbol == token.symbol:
          # NOTE: here can be intersections
          profileAssetItems.add(initProfileShowcaseAssetItem(token,
            ProfileShowcaseVisibility.ToEveryone, assetEntry.order))

    # TODO: collectibles, need wallet api to fetch collectible by uid
  self.view.updateProfileShowcasePreferences(profileCommunityItems, profileAccountItems, profileCollectibleItems, profileAssetItems)

method updateProfileShowcasePreferences(self: Module, preferences: ProfileShowcasePreferencesDto) =
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]

  for communityEntry in preferences.communities:
    let community = self.controller.getCommunityById(communityEntry.communityId)
    profileCommunityItems.add(initProfileShowcaseCommunityItem(community, communityEntry.showcaseVisibility, communityEntry.order))

  for account in preferences.accounts:
    profileAccountItems.add(initProfileShowcaseAccountItem(
      account.address,
      account.name,
      account.emoji,
      account.colorId,
      account.showcaseVisibility,
      account.order
    ))

    for assetEntry in preferences.assets:
      # TODO: need wallet api to fetch token by symbol
      for token in self.controller.getTokensByAddress(account.address):
        if assetEntry.symbol == token.symbol:
          # NOTE: here can be intersections
          profileAssetItems.add(initProfileShowcaseAssetItem(token, assetEntry.showcaseVisibility, assetEntry.order))

    # TODO: collectibles, need wallet api to fetch collectible by uid

  self.view.updateProfileShowcasePreferences(profileCommunityItems, profileAccountItems, profileCollectibleItems, profileAssetItems)
