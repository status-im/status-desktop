import NimQml, json, sequtils, chronicles, strutils, strutils, stint, sugar

import ../../../app/core/eventemitter
import ../../../app/core/[main]
import ../../../app/core/tasks/[qt, threadpool]

import web3/ethtypes, web3/conversions, stew/byteutils, nimcrypto, json_serialization, chronicles
import json, tables, json_serialization

import ../chat/service as chat_service

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
const SIGNAL_MARK_NOTIFICATIONS_AS_READ* = "markNotificationsAsRead"
const SIGNAL_MARK_NOTIFICATIONS_AS_UNREAD* = "markNotificationsAsUnread"
const SIGNAL_MARK_NOTIFICATIONS_AS_ACCEPTED* = "markNotificationsAsAccepted"
const SIGNAL_MARK_NOTIFICATIONS_AS_DISMISSED* = "markNotificationsAsDismissed"

const DEFAULT_LIMIT = 20


QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    chatService: chat_service.Service
    cursor*: string

  # Forward declaration
  proc asyncActivityNotificationLoad*(self: Service)

  proc delete*(self: Service) =
    self.QObject.delete

  proc newService*(
      events: EventEmitter,
      threadpool: ThreadPool,
      chatService: chat_service.Service
      ): Service =
    new(result, delete)
    result.QObject.setup
    result.events = events
    result.threadpool = threadpool
    result.chatService = chatService

  proc init*(self: Service) =
    self.asyncActivityNotificationLoad()
    self.events.on(SignalType.Message.event) do(e: Args):
      var receivedData = MessageSignal(e)

      # Handling activityCenterNotifications updates
      if (receivedData.activityCenterNotifications.len > 0):
        self.events.emit(
          SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
          ActivityCenterNotificationsArgs(activityCenterNotifications: receivedData.activityCenterNotifications.filter(n => n.notificationType != ActivityCenterNotificationType.ContactRequest))
        )

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
    if(self.cursor == ""): return

    var cursorVal: JsonNode

    if self.cursor == "":
      cursorVal = newJNull()
    else:
      cursorVal = newJString(self.cursor)

    let callResult = backend.activityCenterNotifications(cursorVal, DEFAULT_LIMIT)
    let activityCenterNotificationsTuple = parseActivityCenterNotifications(callResult.result)

    self.cursor = activityCenterNotificationsTuple[0];

    result = activityCenterNotificationsTuple[1]

  proc markActivityCenterNotificationRead*(
      self: Service,
      notificationId: string,
      markAsReadProps: MarkAsReadNotificationProperties
      ): string =
    try:
      discard backend.markActivityCenterNotificationsRead(@[notificationId])
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_READ, markAsReadProps)
    except Exception as e:
      error "Error marking as read", msg = e.msg
      result = e.msg

  proc unreadActivityCenterNotificationsCount*(self: Service): int =
    try:
      let response = backend.unreadActivityCenterNotificationsCount()

      if response.result.kind != JNull:
        return response.result.getInt
    except Exception as e:
      error "Error getting unread acitvity center unread count", msg = e.msg

  proc markActivityCenterNotificationUnread*(
      self: Service,
      notificationId: string,
      markAsUnreadProps: MarkAsUnreadNotificationProperties
      ): string =
    try:
      discard backend.markActivityCenterNotificationsUnread(@[notificationId])
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_UNREAD, markAsUnreadProps)
    except Exception as e:
      error "Error marking as unread", msg = e.msg
      result = e.msg

  proc markAllActivityCenterNotificationsRead*(self: Service, initialLoad: bool = true):string  =
    try:
      discard backend.markAllActivityCenterNotificationsRead()
      # This proc should accept ActivityCenterNotificationType in order to clear all notifications
      # per type, that's why we have this part here. If we add all types to notificationsType that
      # means that we need to clear all notifications for all types.
      var types : seq[ActivityCenterNotificationType]
      for t in ActivityCenterNotificationType:
        types.add(t)

      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_READ,
        MarkAsReadNotificationProperties(notificationTypes: types, isAll: true))
    except Exception as e:
      error "Error marking all as read", msg = e.msg
      result = e.msg

  proc asyncActivityNotificationLoaded*(self: Service, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson

    if(rpcResponseObj["activityNotifications"].kind != JNull):
      let activityCenterNotificationsTuple = parseActivityCenterNotifications(rpcResponseObj["activityNotifications"])

      self.cursor = activityCenterNotificationsTuple[0]

      # Filter contact request notification til we have the UI working
      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
        ActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotificationsTuple[1].filter(n => n.notificationType != ActivityCenterNotificationType.ContactRequest)))

  proc acceptActivityCenterNotifications*(self: Service, notificationIds: seq[string]): string =
    try:
      let response = backend.acceptActivityCenterNotifications(notificationIds)

      let (chats, messages) = self.chatService.parseChatResponse(response)
      self.events.emit(chat_service.SIGNAL_CHAT_UPDATE,
        ChatUpdateArgs(messages: messages, chats: chats))

    except Exception as e:
      error "Error marking as accepted", msg = e.msg
      result = e.msg

  proc dismissActivityCenterNotifications*(self: Service, notificationIds: seq[string]): string =
    try:
      discard backend.dismissActivityCenterNotifications(notificationIds)
      self.events.emit(SIGNAL_MARK_NOTIFICATIONS_AS_DISMISSED,
        MarkAsDismissedNotificationProperties(notificationIds: notificationIds))
    except Exception as e:
      error "Error marking as dismissed", msg = e.msg
      result = e.msg


