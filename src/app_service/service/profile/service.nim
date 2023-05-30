import json, chronicles

import ../settings/service as settings_service
import ../../../app/global/global_singleton

import ../../../app/core/signals/types
import ../../../app/core/eventemitter

import ../../../backend/accounts as status_accounts

import ../accounts/dto/accounts

logScope:
  topics = "profile-service"

type
  Service* = ref object of RootObj
    events: EventEmitter
    settingsService: settings_service.Service

proc delete*(self: Service) =
  discard

proc newService*(events: EventEmitter, settingsService: settings_service.Service): Service =
  result = Service()
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