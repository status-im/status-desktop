import NimQml, os, json, chronicles

import ../../../backend/mailservers as status_mailservers
import ../../../backend/general as status_general
import ../../../app/core/eventemitter
import ../../../app/core/tasks/[qt, threadpool]
import ../../../constants as app_constants

import ../accounts/dto/accounts

const TimerIntervalInMilliseconds = 1000 # 1 second

const SIGNAL_GENERAL_TIMEOUT* = "timeoutSignal"

logScope:
  topics = "general-app-service"

include ../../common/async_tasks

QtObject:
  type Service* = ref object of QObject
    events: EventEmitter
    threadpool: ThreadPool
    timeoutInMilliseconds: int

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(events: EventEmitter, threadpool: ThreadPool): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc init*(self: Service) =
    if not dirExists(app_constants.ROOTKEYSTOREDIR):
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
        result.add(toImage(img))
    except Exception as e:
      error "error: ", procName="generateImages", errName = e.name, errDesription = e.msg

  proc runTimer(self: Service) =
    let arg = TimerTaskArg(
      tptr: cast[ByteAddress](timerTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "onTimeout",
      timeoutInMilliseconds: TimerIntervalInMilliseconds
    )
    self.threadpool.start(arg)

  proc runTimer*(self: Service, timeoutInMilliseconds: int) =
    ## Runs timer only once. Each 1000ms we check for timeout in order to have non blocking app closing.
    self.timeoutInMilliseconds = timeoutInMilliseconds
    self.runTimer()

  proc onTimeout(self: Service, response: string) {.slot.} =
    self.timeoutInMilliseconds = self.timeoutInMilliseconds - TimerIntervalInMilliseconds
    if self.timeoutInMilliseconds <= 0:
      self.events.emit(SIGNAL_GENERAL_TIMEOUT, Args())
    else:
      self.runTimer()

  proc fetchWakuMessages*(self: Service) =
    try:
      let response = status_mailservers.requestAllHistoricMessagesWithRetries(forceFetchingBackup = true)
      if(not response.error.isNil):
        error "could not set display name"
    except Exception as e:
      error "error: ", procName="fetchWakuMessages", errName = e.name, errDesription = e.msg

  proc backupData*(self: Service): int64 =
    try:
      let response =  status_general.backupData()
      return response.result.getInt
    except Exception as e:
      error "error: ", procName="backupData", errName = e.name, errDesription = e.msg