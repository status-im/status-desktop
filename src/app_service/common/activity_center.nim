import json, json_serialization
import ../../app/core/eventemitter

include json_utils

const SIGNAL_PARSE_RAW_ACTIVITY_CENTER_NOTIFICATIONS* = "parseRawActivityCenterNotifications"

type RawActivityCenterNotificationsArgs* = ref object of Args
  activityCenterNotifications*: JsonNode

proc checkAndEmitACNotificationsFromResponse*(events: EventEmitter, activityCenterNotifications: JsonNode) =
  if activityCenterNotifications == nil or activityCenterNotifications.kind == JNull:
    return

  events.emit(SIGNAL_PARSE_RAW_ACTIVITY_CENTER_NOTIFICATIONS,
    RawActivityCenterNotificationsArgs(activityCenterNotifications: activityCenterNotifications))