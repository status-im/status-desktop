import json, chronicles

import ../../../backend/general as status_general
import ../../../backend/keycard as status_keycard
import ../../../backend/accounts as status_accounts
import ../../../constants as app_constants

import ../profile/dto/profile as profile_dto
export profile_dto

logScope:
  topics = "general-app-service"

type
  Service* = ref object of RootObj

proc delete*(self: Service) =
  discard

proc newService*(): Service =
  result = Service()

proc initKeycard(self: Service) =
  ## This should not be part of the "general service", but part of the "keystore service", but since we don't have
  ## keycard in place for the refactored part yet but `status-go` part requires keycard to be initialized on the app
  ## start. This call is added as a part of the "global service".
  try:
    discard status_keycard.initKeycard(app_constants.KEYSTOREDIR)
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc init*(self: Service) =
  self.initKeycard()

proc startMessenger*(self: Service) =
  try:
    discard status_general.startMessenger()
  except Exception as e:
    let errDesription = e.msg
    error "error: ", errDesription
    return

proc getPasswordStrengthScore*(self: Service, password, userName: string): int =
  try:    
    let response = status_general.getPasswordStrengthScore(password, @[userName])
    if(response.result.contains("error")):
      let errMsg = response.result["error"].getStr()
      error "error: ", methodName="getPasswordStrengthScore", errDesription = errMsg
      return

    return response.result["score"].getInt()
  except Exception as e:
    error "error: ", methodName="getPasswordStrengthScore", errName = e.name, errDesription = e.msg

proc generateImages*(self: Service, image: string, aX: int, aY: int, bX: int, bY: int): seq[Image] =
  try:
    let response = status_general.generateImages(image, aX, aY, bX, bY)
    if(response.result.kind != JArray):
      error "error: ", procName="generateImages", errDesription = "response is not an array"
      return

    for img in response.result:
      result.add(profile_dto.toImage(img))
  except Exception as e:
    error "error: ", procName="generateImages", errName = e.name, errDesription = e.msg