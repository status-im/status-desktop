import NimQml, json, chronicles, tables, sugar, sequtils, json_serialization

import ../settings/service as settings_service
import ../../../app/global/global_singleton

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/accounts as status_accounts

import ../accounts/dto/accounts
import dto/profile_showcase_entry

include async_tasks

logScope:
  topics = "profile-service"

type
  ProfileShowcasePreferencesArgs* = ref object of Args
    communities*: Table[string, ProfileShowcaseEntryDto]
    accounts*: Table[string, ProfileShowcaseEntryDto]
    collectibles*: Table[string, ProfileShowcaseEntryDto]
    assets*: Table[string, ProfileShowcaseEntryDto]

# Signals which may be emitted by this service:
const SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED* = "profileShowcasePreferencesLoaded"

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

  # Forward declaration
  proc requestProfileShowcasePreferences*(self: Service)

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

  proc deleteIdentityImage*(self: Service, address: string) =
    try:
      let response = status_accounts.deleteIdentityImage(address)
      if(not response.error.isNil):
        error "could not delete identity images"
        return
      singletonInstance.userProfile.setLargeImage("")
      singletonInstance.userProfile.setThumbnailImage("")

    except Exception as e:
      error "error: ", procName="deleteIdentityImage", errName = e.name, errDesription = e.msg

  proc setDisplayName*(self: Service, displayName: string) =
    try:
      let response =  status_accounts.setDisplayName(displayName)
      if(not response.error.isNil):
        error "could not set display name"
        return
      if(not self.settingsService.saveDisplayName(displayName)):
        error "could save display name to the settings"
        return
    except Exception as e:
      error "error: ", procName="setDisplayName", errName = e.name, errDesription = e.msg

  proc requestProfileShowcasePreferences*(self: Service) =
    try:
      let arg = QObjectTaskArg(
        tptr: cast[ByteAddress](asyncGetProfileShowcasePreferencesTask),
        vptr: cast[ByteAddress](self.vptr),
        slot: "asyncProfileShowcaseLoaded",
      )
      self.threadpool.start(arg)
    except Exception as e:
      error "Error requesting profile showcase preferences", msg = e.msg

  proc asyncProfileShowcaseLoaded*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson
    if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
      error "Error requesting profile showcase preferences", msg = rpcResponseObj{"error"}
      return

    let result =  rpcResponseObj{"response"}{"result"}

    var communities = result{"communities"}.parseProfileShowcaseEntries()
    var accounts = result{"accounts"}.parseProfileShowcaseEntries()
    var collectibles = result{"collectibles"}.parseProfileShowcaseEntries()
    var assets = result{"assets"}.parseProfileShowcaseEntries()

    self.events.emit(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_LOADED,
      ProfileShowcasePreferencesArgs(
        communities: communities,
        accounts: accounts,
        collectibles: collectibles,
        assets: assets
    ))
