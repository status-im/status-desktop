import json, chronicles

import ../../../backend/general as status_general
import ../../../backend/keycard as status_keycard

import ../../../constants as app_constants


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
