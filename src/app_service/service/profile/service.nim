import NimQml, json, chronicles, tables, sequtils

import ../settings/service as settings_service
import ../../../app/global/global_singleton

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/accounts as status_accounts

import ../accounts/dto/accounts
import dto/profile_showcase_preferences

include async_tasks

logScope:
  topics = "profile-service"

type
  ProfileShowcasePreferencesArgs* = ref object of Args
    preferences*: ProfileShowcasePreferencesDto

# Signals which may be emitted by this service:
const SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED* = "profileShowcasePreferencesLoaded"
const SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_SUCCEEDED* = "profileShowcasePreferencesSaveSucceeded"
const SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_FAILED* = "profileShowcasePreferencesSaveFailed"

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    settingsService: settings_service.Service

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool, settingsService: settings_service.Service): Service =
    new(result, delete)
    result.QObject.setup
    result.threadpool = threadpool
    result.events = events
    result.settingsService = settingsService

  proc init*(self: Service) =
    self.events.on(SIGNAL_DISPLAY_NAME_UPDATED) do(e:Args):
      let args = SettingsTextValueArgs(e)
      singletonInstance.userProfile.setDisplayName(args.value)

  proc storeIdentityImage*(self: Service, address: string, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
    try:
      let response = status_accounts.storeIdentityImage(address, image, aX, aY, bX, bY)
      if(not response.error.isNil):
        error "could not store identity images"
        return
      if(response.result.kind != JArray):
        error "error: ", procName="storeIdentityImage", errDesription = "response is not an array"
        return
      if(response.result.len == 0):
        error "error: array of stored images is empty"
        return

      for img in response.result:
        let imageDto = toImage(img)
        result.add(imageDto)
        if(imageDto.imgType == "large"):
          singletonInstance.userProfile.setLargeImage(imageDto.uri)
        elif(imageDto.imgType == "thumbnail"):
          singletonInstance.userProfile.setThumbnailImage(imageDto.uri)

    except Exception as e:
      error "error: ", procName="storeIdentityImage", errName = e.name, errDesription = e.msg

  proc deleteIdentityImage*(self: Service, address: string): bool =
    try:
      let response = status_accounts.deleteIdentityImage(address)
      if(not response.error.isNil):
        error "could not delete identity images"
        return false
      singletonInstance.userProfile.setLargeImage("")
      singletonInstance.userProfile.setThumbnailImage("")
      return true

    except Exception as e:
      error "error: ", procName="deleteIdentityImage", errName = e.name, errDesription = e.msg
      return false

  proc setDisplayName*(self: Service, displayName: string): bool =
    try:
      let response = status_accounts.setDisplayName(displayName)
      if not response.error.isNil:
        error "could not set display name"
        return false
      if not self.settingsService.saveDisplayName(displayName):
        error "could not save display name to the settings"
        return false
      return true
    except Exception as e:
      error "error: ", procName="setDisplayName", errName = e.name, errDesription = e.msg
      return false

  proc setBio*(self: Service, bio: string): bool =
    try:
      let response = status_accounts.setBio(bio)
      if not response.error.isNil:
        error "could not set bio"
        return false
      if not self.settingsService.saveBio(bio):
        error "could not set bio to the settings"
        return false
      return true
    except Exception as e:
      error "error: ", procName="setBio", errName = e.name, errDesription = e.msg
      return false

  proc requestProfileShowcasePreferences*(self: Service) =
    let arg = QObjectTaskArg(
      tptr: cast[ByteAddress](asyncGetProfileShowcasePreferencesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncProfileShowcasePreferencesLoaded",
    )
    self.threadpool.start(arg)

  proc asyncProfileShowcasePreferencesLoaded*(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        error "Error requesting profile showcase preferences", msg = rpcResponseObj{"error"}
        return

      let preferences = rpcResponseObj["response"]["result"].toProfileShowcasePreferencesDto()

      self.events.emit(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED,
        ProfileShowcasePreferencesArgs(preferences: preferences))
    except Exception as e:
      error "Error requesting profile showcase preferences", msg = e.msg

  proc saveProfileShowcasePreferences*(self: Service, preferences: ProfileShowcasePreferencesDto) =
    let arg = SaveProfileShowcasePreferencesTaskArg(
      preferences: preferences,
      tptr: cast[ByteAddress](saveProfileShowcasePreferencesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncProfileShowcasePreferencesSaved",
    )
    self.threadpool.start(arg)

  proc asyncProfileShowcasePreferencesSaved*(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        error "Error saving profile showcase preferences", msg = rpcResponseObj{"error"}
        self.events.emit(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_FAILED, Args())
        return

      self.events.emit(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_SAVE_SUCCEEDED, Args())
      self.requestProfileShowcasePreferences()
    except Exception as e:
      error "Error saving profile showcase preferences", msg = e.msg

  proc getProfileShowcaseSocialLinksLimit*(self: Service): int =
    try:
      let response = status_accounts.getProfileShowcaseSocialLinksLimit()

      if response.result.kind != JNull:
        return response.result.getInt
    except Exception as e:
      error "Error getting unseen activity center notifications", msg = e.msg

  proc getProfileShowcaseEntriesLimit*(self: Service): int =
    try:
      let response = status_accounts.getProfileShowcaseEntriesLimit()

      if response.result.kind != JNull:
        return response.result.getInt
    except Exception as e:
      error "Error getting unseen activity center notifications", msg = e.msg