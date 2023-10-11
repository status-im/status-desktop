import json, sugar, sequtils

import io_interface

import app/core/eventemitter
import app_service/service/profile/service as profile_service
import app_service/service/settings/service as settings_service
import app_service/common/social_links

import app_service/service/profile/dto/profile_showcase_entry
import models/profile_preferences_item

type
  Controller* = ref object of RootObj
    delegate: io_interface.AccessInterface
    events: EventEmitter
    profileService: profile_service.Service
    settingsService: settings_service.Service

  # Forward declaration
proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, tokens: seq[ProfileShowcaseEntryDto])

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
    let args = ProfileShowcasePreferencesArgs(e)
    self.updateShowcasePreferences(args.communities, args.accounts, args.collectibles, args.tokens)

proc updateShowcasePreferences(self: Controller, communities, accounts, collectibles, tokens: seq[ProfileShowcaseEntryDto]) =
  let items = (communities & accounts & collectibles & tokens).map(item => initProfileShowcasePreferencesItem(item))
  self.delegate.setShowcasePreferences(items)

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
