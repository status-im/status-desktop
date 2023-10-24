import json, sugar, sequtils

import io_interface

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/service/community/service as community_service
import app_service/service/wallet_account/service as wallet_account_service
import app_service/common/social_links

import app_service/service/profile/dto/profile_showcase_entry

import models/profile_preferences_community_item
import models/profile_preferences_account_item
import models/profile_preferences_collectible_item
import models/profile_preferences_asset_item

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    profileService: profile_service.Service
    settingsService: settings_service.Service
    communityService: community_service.Service
    walletAccountService: wallet_account_service.Service

# Forward declaration
proc updateShowcasePreferences(self: Controller, communityEntries, accountEntries, collectibleEntries, assetEntries: seq[ProfileShowcaseEntryDto])

proc newController*(
    delegate: io_interface.AccessInterface,
    events: EventEmitter,
    profileService: profile_service.Service,
    settingsService: settings_service.Service,
    communityService: community_service.Service,
    walletAccountService: wallet_account_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.profileService = profileService
  result.settingsService = settingsService
  result.communityService = communityService
  result.walletAccountService = walletAccountService

proc delete*(self: Controller) =
  discard

proc init*(self: Controller) =
  self.settingsService.fetchAndStoreSocialLinks()

  self.events.on(SIGNAL_BIO_UPDATED) do(e: Args):
    let args = SettingsTextValueArgs(e)
    self.delegate.onBioChanged(args.value)

  self.events.on(SIGNAL_SOCIAL_LINKS_UPDATED) do(e: Args):
    let args = SocialLinksArgs(e)
    self.delegate.onSocialLinksUpdated(args.socialLinks, args.error)

  self.events.on(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED) do(e: Args):
    let args = ProfileShowcasePreferences(e)
    self.updateShowcasePreferences(args.communities, args.accounts, args.collectibles, args.assets)

proc storeIdentityImage*(self: Controller, address: string, image: string, aX: int, aY: int, bX: int, bY: int) =
  discard self.profileService.storeIdentityImage(address, image, aX, aY, bX, bY)

proc deleteIdentityImage*(self: Controller, address: string) =
  self.profileService.deleteIdentityImage(address)

proc setDisplayName*(self: Controller, displayName: string) =
  self.profileService.setDisplayName(displayName)

proc getSocialLinks*(self: Controller): SocialLinks =
  return self.settingsService.getSocialLinks()

proc setSocialLinks*(self: Controller, links: SocialLinks) =
  self.settingsService.setSocialLinks(links)

proc getBio*(self: Controller): string =
  self.settingsService.getBio()

proc setBio*(self: Controller, bio: string): bool =
  self.settingsService.saveBio(bio)

proc storeProfileShowcasePreferences*(self: Controller,
                                      communities: seq[ProfileShowcaseCommunityItem],
                                      accounts: seq[ProfileShowcaseAccountItem],
                                      collectibles: seq[ProfileShowcaseCollectibleItem],
                                      assets: seq[ProfileShowcaseAssetItem]) =
  let communitiesDto = communities.map(item => item.getEntryDto())
  let accountsDto = accounts.map(item => item.getEntryDto())
  let collectiblesDto = collectibles.map(item => item.getEntryDto())
  let assetsDto = assets.map(item => item.getEntryDto())

  self.profileService.setProfileShowcasePreferences(ProfileShowcasePreferences(
      communities: communitiesDto,
      accounts: accountsDto,
      collectibles: collectiblesDto,
      assets: assetsDto
  ))

proc requestProfileShowcasePreferences*(self: Controller) =
  self.profileService.requestProfileShowcasePreferences()

proc updateShowcasePreferences(self: Controller, communityEntries, accountEntries, collectibleEntries, assetEntries: seq[ProfileShowcaseEntryDto]) =
  var profileCommunityItems: seq[ProfileShowcaseCommunityItem] = @[]
  var profileAccountItems: seq[ProfileShowcaseAccountItem] = @[]
  var profileCollectibleItems: seq[ProfileShowcaseCollectibleItem] = @[]
  var profileAssetItems: seq[ProfileShowcaseAssetItem] = @[]

  for communityEntry in communityEntries:
    let community = self.communityService.getCommunityById(communityEntry.id)
    profileCommunityItems.add(initProfileShowcaseCommunityItem(community, communityEntry))

  for accountEntry in accountEntries:
    let account = self.walletAccountService.getAccountByAddress(accountEntry.id)
    profileAccountItems.add(initProfileShowcaseAccountItem(account, accountEntry))

    for assetEntry in assetEntries:
      # TODO: need wallet api to fetch token by symbol
      for token in self.walletAccountService.getTokensByAddress(account.address):
        if assetEntry.id == token.symbol:
          profileAssetItems.add(initProfileShowcaseAssetItem(token, assetEntry))

    # TODO: collectibles, need wallet api to fetch collectible by uid

  self.delegate.updateProfileShowcasePreferences(profileCommunityItems, profileAccountItems, profileCollectibleItems, profileAssetItems)
