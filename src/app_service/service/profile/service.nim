import NimQml, json, chronicles, tables

import ../settings/service as settings_service
import ../../../app/global/global_singleton

import ../../../app/core/signals/types
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]

import ../../../backend/accounts as status_accounts

import ../accounts/dto/accounts
import dto/profile_showcase
import dto/profile_showcase_preferences

include async_tasks

logScope:
  topics = "profile-service"

type
  ProfileShowcasePreferencesArgs* = ref object of Args
    preferences*: ProfileShowcasePreferencesDto

  ProfileShowcaseForContactArgs* = ref object of Args
    profileShowcase*: ProfileShowcaseDto

# Signals which may be emitted by this service:
const SIGNAL_PROFILE_SHOWCASE_PREFERENCES_UPDATED* = "profileShowcasePreferencesUpdated"
const SIGNAL_PROFILE_SHOWCASE_FOR_CONTACT_UPDATED* = "profileShowcaseForContactUpdated"

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

    self.events.on(SignalType.Message.event) do(e: Args):
      let receivedData = MessageSignal(e)
      if receivedData.updatedProfileShowcases.len > 0:
        for profileShowcase in receivedData.updatedProfileShowcases:
          self.events.emit(SIGNAL_PROFILE_SHOWCASE_FOR_CONTACT_UPDATED,
            ProfileShowcaseForContactArgs(profileShowcase: profileShowcase))

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

  proc requestProfileShowcaseForContact*(self: Service, contactId: string) =
    let arg = AsyncGetProfileShowcaseForContactTaskArg(
      pubkey: contactId,
      tptr: cast[ByteAddress](asyncGetProfileShowcaseForContactTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncProfileShowcaseForContactLoaded",
    )
    self.threadpool.start(arg)

  proc asyncProfileShowcaseForContactLoaded*(self: Service, rpcResponse: string) {.slot.} =
    try:
      let rpcResponseObj = rpcResponse.parseJson
      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        error "Error requesting profile showcase preferences", msg = rpcResponseObj{"error"}
        return

      let profileShowcase = rpcResponseObj["response"]["result"].toProfileShowcaseDto()

      self.events.emit(SIGNAL_PROFILE_SHOWCASE_FOR_CONTACT_UPDATED,
        ProfileShowcaseForContactArgs(profileShowcase: profileShowcase))
    except Exception as e:
      error "Error requesting profile showcase for a contact", msg = e.msg

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

      self.events.emit(SIGNAL_PROFILE_SHOWCASE_PREFERENCES_UPDATED,
        ProfileShowcasePreferencesArgs(preferences: preferences))
    except Exception as e:
      error "Error requesting profile showcase preferences", msg = e.msg

  proc setProfileShowcasePreferences*(self: Service, preferences: ProfileShowcasePreferencesDto) =
    try:
      let response = status_accounts.setProfileShowcasePreferences(preferences.toJsonNode())
      if not response.error.isNil:
        error "error saving profile showcase preferences"
    except Exception as e:
      error "error: ", procName="setProfileShowcasePreferences", errName = e.name, errDesription = e.msg
