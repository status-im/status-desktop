import json, chronicles
include ../../common/json_utils

logScope:
  topics = "metrics"

type CentralizedMetricsInfoDto* = object
  enabled*: bool
  userConfirmed*: bool

proc toCentralizedMetricsInfoDto*(jsonObj: JsonNode): CentralizedMetricsInfoDto =
  result = CentralizedMetricsInfoDto()
  discard jsonObj.getProp("enabled", result.enabled)
  discard jsonObj.getProp("userConfirmed", result.userConfirmed)

type CentralizedMetricDto* = object
  id*: string
  userId*: string
  eventName*: string
  eventValue*: JsonNode
  timestamp*: int64
  platform*: string
  appVersion*: string

proc toJsonNode*(self: CentralizedMetricDto): JsonNode =
  result =
    %*{
      "id": self.id,
      "userId": self.userId,
      "eventName": self.eventName,
      "eventValue": self.eventValue,
      "timestamp": self.timestamp,
      "platform": self.platform,
      "appVersion": self.appVersion,
    }
