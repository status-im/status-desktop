import json

import ../../app/core/eventemitter

const SIGNAL_RAW_ACTIVITY_CENTER_NOTIFICATIONS* = "rawActivityCenterNotifications"

type RawActivityCenterNotificationsArgs* = ref object of Args
  activityCenterNotifications*: JsonNode
