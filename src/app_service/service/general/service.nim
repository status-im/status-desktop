import nimqml, os, json, chronicles

import backend/mailservers as status_mailservers
import backend/general as status_general
import app/core/eventemitter
import app/core/tasks/[qt, threadpool]
import ../../../constants as app_constants
import ../../common/types
import status_go

from app_service/service/activity_center/service import SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_RECEIVED, ActivityCenterNotificationsArgs
from app_service/service/activity_center/dto/notification import parseActivityCenterNotifications

import ../accounts/dto/accounts

include async_tasks

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
    let response = status_general.startMessenger()
    if response.result.contains("activityCenterNotifications"):
      let notifications = JsonNode(%{"notifications": response.result["activityCenterNotifications"]})
      let activityCenterNotificationsTuple = parseActivityCenterNotifications(notifications)
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_RECEIVED,
        ActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotificationsTuple[1]))

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

  proc runTimer(self: Service) =
    let arg = TimerTaskArg(
      tptr: timerTask,
      vptr: cast[uint](self.vptr),
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

  proc asyncFetchWakuBackupMessages*(self: Service) =
    let arg = AsyncFetchBackupWakuMessagesTaskArg(
      tptr: asyncFetchWakuBackupMessagesTask,
      vptr: cast[uint](self.vptr),
      slot: "onFetchWakuBackupMessagesDone",
    )
    self.threadpool.start(arg)

  proc onFetchWakuBackupMessagesDone(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson

      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)

      if rpcResponseObj["response"]["result"].contains("activityCenterNotifications"):
        let notifications = JsonNode(%{"notifications": rpcResponseObj["response"]["result"]["activityCenterNotifications"]})
        let activityCenterNotificationsTuple = parseActivityCenterNotifications(notifications)
        self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_RECEIVED,
          ActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotificationsTuple[1]))
    except Exception as e:
      error "error:", procName="asyncFetchWakuBackupMessages", errName = e.name, errDesription = e.msg

  proc backupData*(self: Service): int64 =
    try:
      let response =  status_general.backupData()
      return response.result.getInt
    except Exception as e:
      error "error: ", procName="backupData", errName = e.name, errDesription = e.msg

  proc performLocalBackup*(self: Service): string =
    try:
      let response =  status_go.performLocalBackup()
      let rpcResponseObj = response.parseJson

      if rpcResponseObj.hasKey("error") and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)
    except Exception as e:
      error "error: ", procName="performLocalBackup", errName = e.name, errDesription = e.msg
      return e.msg

  proc asyncImportLocalBackupFile*(self: Service, filePath: string) =
    let arg = AsyncImportLocalBackupFileTaskArg(
      tptr: asyncImportLocalBackupFileTask,
      vptr: cast[uint](self.vptr),
      slot: "onImportLocalBackupFileDone",
      filePath: filePath
    )
    self.threadpool.start(arg)

  proc onImportLocalBackupFileDone(self: Service, response: string) {.slot.} =
    try:
      let rpcResponseObj = response.parseJson

      if rpcResponseObj{"error"}.kind != JNull and rpcResponseObj{"error"}.getStr != "":
        raise newException(CatchableError, rpcResponseObj{"error"}.getStr)

      let responseObj = rpcResponseObj["response"].getStr.parseJson

      if (responseObj{"error"}.kind != JNull and responseObj{"error"}.getStr != ""):
        raise newException(CatchableError, responseObj["error"].getStr)

      self.events.emit(SIGNAL_LOCAL_BACKUP_IMPORT_COMPLETED, LocalBackupImportArg(error: ""))
    except Exception as e:
      error "error:", procName="asyncImportLocalBackupFile", errName = e.name, errDesription = e.msg
      self.events.emit(SIGNAL_LOCAL_BACKUP_IMPORT_COMPLETED, LocalBackupImportArg(error: e.msg))