import json, sugar, sequtils

import io_interface

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/common/social_links

import app_service/service/profile/dto/profile_showcase_entry

import models/profile_preferences_source_item
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

# Forward declaration
proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, assets: seq[ProfileShowcaseEntryDto])

proc newController*(delegate: io_interface.AccessInterface, events: EventEmitter,
  profileService: profile_service.Service, settingsService: settings_service.Service): Controller =
  result = Controller()
  result.delegate = delegate
  result.events = events
  result.profileService = profileService
  result.settingsService = settingsService

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

proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, assets: seq[ProfileShowcaseEntryDto]) =
  let communities = communities.map(item => toProfileShowcaseSourceItem(item))
  let accounts = accounts.map(item => toProfileShowcaseSourceItem(item))
  let collectibles = collectibles.map(item => toProfileShowcaseSourceItem(item))
  let assets = assets.map(item => toProfileShowcaseSourceItem(item))

  # TODO: fetch data in c++/nim layer instead of resuing existing qmml models
  self.delegate.setProfileShowcasePreferences(communities & accounts & collectibles & assets)

