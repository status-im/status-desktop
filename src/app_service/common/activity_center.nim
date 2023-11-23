import json

import ../../app/core/eventemitter

const SIGNAL_PARSE_RAW_ACTIVITY_CENTER_NOTIFICATIONS* = "parseRawActivityCenterNotifications"

type RawActivityCenterNotificationsArgs* = ref object of Args
  activityCenterNotifications*: JsonNode
