import os, json, chronicles

import ../../../backend/general as status_general
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

proc init*(self: Service) =
  if not existsDir(app_constants.ROOTKEYSTOREDIR):
    createDir(app_constants.ROOTKEYSTOREDIR)

proc startMessenger*(self: Service) =
  discard status_general.startMessenger()

proc logout*(self: Service) =
  discard status_general.logout()

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