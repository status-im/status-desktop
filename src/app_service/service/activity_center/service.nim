import NimQml, json, sequtils, chronicles, strutils, strutils, stint, sugar

import ../../../app/core/eventemitter
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization

import ../../../backend/backend
import ../../../backend/response_type
import ./dto/notification

export notification

include async_tasks

logScope:
  topics = "activity-center-service"

type
  ActivityCenterNotificationsArgs* = ref object of Args
    activityCenterNotifications*: seq[ActivityCenterNotificationDto]

  MarkAsAcceptedNotificationProperties* = ref object of Args
    notificationIds*: seq[string]

  MarkAsDismissedNotificationProperties* = ref object of Args
    notificationIds*: seq[string]

  MarkAsReadNotificationProperties* = ref object of Args
    isAll*: bool
    notificationIds*: seq[string]
    communityId*: string
    channelId*: string
    notificationTypes*: seq[ActivityCenterNotificationType]

  MarkAsUnreadNotificationProperties* = ref object of Args
    notificationIds*: seq[string]
    communityId*: string
    channelId*: string
    notificationTypes*: seq[ActivityCenterNotificationType]

# Signals which may be emitted by this service:
const SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED* = "activityCenterNotificationsLoaded"
const SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED* = "activityCenterNotificationsCountMayChanged"
const SIGNAL_MARK_NOTIFICATIONS_AS_READ* = "markNotificationsAsRead"
const SIGNAL_MARK_NOTIFICATIONS_AS_UNREAD* = "markNotificationsAsUnread"
const SIGNAL_MARK_NOTIFICATIONS_AS_ACCEPTED* = "markNotificationsAsAccepted"
const SIGNAL_MARK_NOTIFICATIONS_AS_DISMISSED* = "markNotificationsAsDismissed"

const DEFAULT_LIMIT = 20


QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    cursor*: string

  # Forward declaration
  proc asyncActivityNotificationLoad*(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool

  proc init*(self: Service) =
    self.asyncActivityNotificationLoad()
    self.events.on(SignalType.Message.event) do(e: Args):
      let receivedData = MessageSignal(e)

      # Handling activityCenterNotifications updates
      if (receivedData.activityCenterNotifications.len > 0):
        self.events.emit(
          SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
          ActivityCenterNotificationsArgs(activityCenterNotifications: receivedData.activityCenterNotifications)
        )
        self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())

  proc parseACNotificationResponse*(self: Service, response: RpcResponse[JsonNode]) =
    var activityCenterNotifications: seq[ActivityCenterNotificationDto] = @[]
    if response.result{"activityCenterNotifications"} != nil:
      for jsonMsg in response.result["activityCenterNotifications"]:
        activityCenterNotifications.add(jsonMsg.toActivityCenterNotificationDto)

      if (activityCenterNotifications.len > 0):
        self.events.emit(
          SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
          ActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotifications)
        )
        self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())

  proc hasMoreToShow*(self: Service): bool =
    return self.cursor != ""

  proc asyncActivityNotificationLoad*(self: Service) =
    let arg = AsyncActivityNotificationLoadTaskArg(
      tptr: cast[ByteAddress](asyncActivityNotificationLoadTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncActivityNotificationLoaded",
      cursor: "",
      limit: DEFAULT_LIMIT
    )
    self.threadpool.start(arg)

  proc getActivityCenterNotifications*(self: Service): seq[ActivityCenterNotificationDto] =
    var cursorVal: JsonNode

    if self.cursor == "":
      cursorVal = newJNull()
    else:
      cursorVal = newJString(self.cursor)

    let callResult = backend.activityCenterNotifications(cursorVal, DEFAULT_LIMIT)
    let activityCenterNotificationsTuple = parseActivityCenterNotifications(callResult.result)

    self.cursor = activityCenterNotificationsTuple[0];
    result = activityCenterNotificationsTuple[1]

  proc getUnreadActivityCenterNotificationsCount*(self: Service): int =
    try:
      let response = backend.unreadActivityCenterNotificationsCount()

      if response.result.kind != JNull:
        return response.result.getInt
    except Exception as e:
      error "Error getting unread activity center unread count", msg = e.msg

  proc markActivityCenterNotificationRead*(
      self: Service,
      notificationId: string,
      markAsReadProps: MarkAsReadNotificationProperties
      ): string =
    try:
      discard backend.markActivityCenterNotificationsRead(@[notificationId])
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_READ, markAsReadProps)
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())
    except Exception as e:
      error "Error marking as read", msg = e.msg
      result = e.msg

  proc markActivityCenterNotificationUnread*(
      self: Service,
      notificationId: string,
      markAsUnreadProps: MarkAsUnreadNotificationProperties
      ): string =
    try:
      discard backend.markActivityCenterNotificationsUnread(@[notificationId])
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_UNREAD, markAsUnreadProps)
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())
    except Exception as e:
      error "Error marking as unread", msg = e.msg
      result = e.msg

  proc markAllActivityCenterNotificationsRead*(self: Service, initialLoad: bool = true):string  =
    try:
      discard backend.markAllActivityCenterNotificationsRead()

      # Accroding specs: Clicking the "Mark all as read" MUST mark mentions and replies items as read in the selected category
      var types : seq[ActivityCenterNotificationType]
      types.add(ActivityCenterNotificationType.Mention)
      types.add(ActivityCenterNotificationType.Reply)

      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_READ,
        MarkAsReadNotificationProperties(notificationTypes: types, isAll: true))
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())
    except Exception as e:
      error "Error marking all as read", msg = e.msg
      result = e.msg

  proc asyncActivityNotificationLoaded*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson

    if(rpcResponseObj["activityNotifications"].kind != JNull):
      let activityCenterNotificationsTuple = parseActivityCenterNotifications(rpcResponseObj["activityNotifications"])

      self.cursor = activityCenterNotificationsTuple[0]

      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
        ActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotificationsTuple[1]))

  proc acceptActivityCenterNotifications*(self: Service, notificationIds: seq[string]): string =
    try:
      discard backend.acceptActivityCenterNotifications(notificationIds)
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_ACCEPTED,
        MarkAsDismissedNotificationProperties(notificationIds: notificationIds))
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())
    except Exception as e:
      error "Error marking as accepted", msg = e.msg
      result = e.msg

  proc dismissActivityCenterNotifications*(self: Service, notificationIds: seq[string]): string =
    try:
      discard backend.dismissActivityCenterNotifications(notificationIds)
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_DISMISSED,
        MarkAsDismissedNotificationProperties(notificationIds: notificationIds))
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())
    except Exception as e:
      error "Error marking as dismissed", msg = e.msg
      result = e.msg


