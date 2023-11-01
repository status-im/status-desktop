import NimQml, chronicles, sequtils, sugar

import ./io_interface, ./view, ./controller
import ../io_interface as delegate_interface
import app/global/global_singleton

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/service/profile/dto/profile_showcase_entry
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
    walletAccountService: wallet_account_service.Service): Module =
  result = Module()
  result.delegate = delegate
  result.view = view.newView(result)
  result.viewVariant = newQVariant(result.view)
  result.controller = controller.newController(result, events, profileService, settingsService, communityService, walletAccountService)
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
  let communitiesDto = communities.map(item => item.getEntryDto())
  let accountsDto = accounts.map(item => item.getEntryDto())
  let collectiblesDto = collectibles.map(item => item.getEntryDto())
  let assetsDto = assets.map(item => item.getEntryDto())
  self.controller.storeProfileShowcasePreferences(communitiesDto, accountsDto, collectiblesDto, assetsDto)

method requestProfileShowcasePreferences(self: Module) =
  self.controller.requestProfileShowcasePreferences()

method updateProfileShowcasePreferences(self: Module, communityEntries, accountEntries, collectibleEntries, assetEntries: seq[ProfileShowcaseEntryDto]) =
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]

  for communityEntry in communityEntries:
    let community = self.controller.getCommunityById(communityEntry.id)
    profileCommunityItems.add(initProfileShowcaseCommunityItem(community, communityEntry))

  for accountEntry in accountEntries:
    let account = self.controller.getAccountByAddress(accountEntry.id)
    profileAccountItems.add(initProfileShowcaseAccountItem(account, accountEntry))

    for assetEntry in assetEntries:
      # TODO: need wallet api to fetch token by symbol
      for token in self.controller.getTokensByAddress(account.address):
        if assetEntry.id == token.symbol:
          profileAssetItems.add(initProfileShowcaseAssetItem(token, assetEntry))

    # TODO: collectibles, need wallet api to fetch collectible by uid

  self.view.updateProfileShowcasePreferences(profileCommunityItems, profileAccountItems, profileCollectibleItems, profileAssetItems)
