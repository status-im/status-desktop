import NimQml, json, sequtils, chronicles, strutils, strutils, stint

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

  RemoveActivityCenterNotificationsArgs* = ref object of Args
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
const SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_REMOVED* = "activityCenterNotificationsRemoved"

const DEFAULT_LIMIT = 20

# NOTE: temporary disable Transactions and System and we don't count All group
const ACTIVITY_GROUPS = @[
  ActivityCenterGroup.Mentions,
  ActivityCenterGroup.Replies,
  ActivityCenterGroup.Membership,
  ActivityCenterGroup.Admin,
  ActivityCenterGroup.ContactRequests,
  ActivityCenterGroup.IdentityVerification
]

QtObject:
  type Service* = ref object of QObject
    threadpool: ThreadPool
    events: EventEmitter
    cursor*: string
    activeGroup: ActivityCenterGroup
    readType: ActivityCenterReadType

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
    result.cursor = ""
    result.activeGroup = ActivityCenterGroup.All
    result.readType = ActivityCenterReadType.All

  proc handleNewNotificationsLoaded(self: Service, activityCenterNotifications: seq[ActivityCenterNotificationDto]) =
    # For now status-go notify about every notification update regardless active group so we need filter manulay on the desktop side
    let groupTypes = activityCenterNotificationTypesByGroup(self.activeGroup)
    let filteredNotifications = filter(activityCenterNotifications, proc(notification: ActivityCenterNotificationDto): bool =
      return (self.readType == ActivityCenterReadType.All or not notification.read) and groupTypes.contains(notification.notificationType.int)
    )
    let removedNotifications = filter(activityCenterNotifications, proc(notification: ActivityCenterNotificationDto): bool =
      return notification.deleted
    )

    if (filteredNotifications.len > 0):
      self.events.emit(
        SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_LOADED,
        ActivityCenterNotificationsArgs(activityCenterNotifications: filteredNotifications)
      )
    
    if (removedNotifications.len > 0):
      var notificationIds: seq[string]
      for notification in removedNotifications:
        notificationIds.add(notification.id)

      self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_REMOVED, RemoveActivityCenterNotificationsArgs(
          notificationIds: notificationIds
          ))
    # NOTE: this signal must fire even we have no new notifications to show
    self.events.emit(SIGNAL_ACTIVITY_CENTER_NOTIFICATIONS_COUNT_MAY_HAVE_CHANGED, Args())

  proc init*(self: Service) =
    self.events.on(SignalType.Message.event) do(e: Args):
      let receivedData = MessageSignal(e)
      if (receivedData.activityCenterNotifications.len > 0):
        self.handleNewNotificationsLoaded(receivedData.activityCenterNotifications)

  proc parseActivityCenterNotifications*(self: Service, notificationsJson: JsonNode) =
    var activityCenterNotifications: seq[ActivityCenterNotificationDto] = @[]
    for notificationJson in notificationsJson:
      activityCenterNotifications.add(notificationJson.toActivityCenterNotificationDto)
    self.handleNewNotificationsLoaded(activityCenterNotifications)

  proc parseActivityCenterResponse*(self: Service, response: RpcResponse[JsonNode]) =
    if response.result{"activityCenterNotifications"} != nil:
      self.parseActivityCenterNotifications(response.result["activityCenterNotifications"])

  proc setActiveNotificationGroup*(self: Service, group: ActivityCenterGroup) =
    self.activeGroup = group

  proc getActiveNotificationGroup*(self: Service): ActivityCenterGroup =
    return self.activeGroup

  proc setActivityCenterReadType*(self: Service, readType: ActivityCenterReadType) =
    self.readType = readType

  proc getActivityCenterReadType*(self: Service): ActivityCenterReadType =
    return self.readType

  proc resetCursor*(self: Service) =
    self.cursor = ""

  proc hasMoreToShow*(self: Service): bool =
    return self.cursor != ""

  proc asyncActivityNotificationLoad*(self: Service) =
    let arg = AsyncActivityNotificationLoadTaskArg(
      tptr: cast[ByteAddress](asyncActivityNotificationLoadTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: "asyncActivityNotificationLoaded",
      cursor: self.cursor,
      limit: DEFAULT_LIMIT,
      group: self.activeGroup,
      readType: self.readType
    )
    self.threadpool.start(arg)

  proc getActivityCenterNotifications*(self: Service): seq[ActivityCenterNotificationDto] =
    try:
      let activityTypes = activityCenterNotificationTypesByGroup(self.activeGroup)
      let response = backend.activityCenterNotifications(
        backend.ActivityCenterNotificationsRequest(
          cursor: self.cursor,
          limit: DEFAULT_LIMIT,
          activityTypes: activityTypes,
          readType: self.readType.int
        )
      )
      let activityCenterNotificationsTuple = parseActivityCenterNotifications(response.result)

      self.cursor = activityCenterNotificationsTuple[0];
      result = activityCenterNotificationsTuple[1]

    except Exception as e:
      error "Error getting activity center notifications", msg = e.msg

  proc getActivityCenterNotificationsCounters(self: Service, activityTypes: seq[int], readType: ActivityCenterReadType): Table[int, int] =
    try:
      let response = backend.activityCenterNotificationsCount(
        backend.ActivityCenterCountRequest(
          activityTypes: activityTypes,
          readType: readType.int,
        )
      )
      var counters = initTable[int, int]()
      if response.result.kind != JNull:
        for activityType in activityTypes:
          if response.result.contains($activityType):
            counters[activityType] = response.result[$activityType].getInt
      return counters
    except Exception as e:
      error "Error getting unread activity center notifications count", msg = e.msg

  proc getActivityGroupCounters*(self: Service): Table[ActivityCenterGroup, int] =
    let allActivityTypes = activityCenterNotificationTypesByGroup(ActivityCenterGroup.All)
    let counters = self.getActivityCenterNotificationsCounters(allActivityTypes, self.readType)
    var groupCounters = initTable[ActivityCenterGroup, int]()
    for group in ACTIVITY_GROUPS:
      var groupTotal = 0
      for activityType in activityCenterNotificationTypesByGroup(group):
        groupTotal = groupTotal + counters.getOrDefault(activityType, 0)
      groupCounters[group] = groupTotal
    return groupCounters

  proc getUnreadActivityCenterNotificationsCount*(self: Service): int =
    let activityTypes = activityCenterNotificationTypesByGroup(ActivityCenterGroup.All)
    let counters = self.getActivityCenterNotificationsCounters(activityTypes, ActivityCenterReadType.Unread)
    var total = 0
    for activityType in activityTypes:
      total = total + counters.getOrDefault(activityType, 0)
    return total

  proc getHasUnseenActivityCenterNotifications*(self: Service): bool =
    try:
      let response = backend.hasUnseenActivityCenterNotifications()

      if response.result.kind != JNull:
        return response.result.getBool
    except Exception as e:
      error "Error getting unseen activity center notifications", msg = e.msg

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

  proc markAsSeenActivityCenterNotifications*(self: Service) =
    try:
      discard backend.markAsSeenActivityCenterNotifications()
    except Exception as e:
      error "Error marking as seen", msg = e.msg

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
