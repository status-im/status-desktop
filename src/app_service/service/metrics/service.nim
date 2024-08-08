import NimQml, json, chronicles, times
include ../../common/json_utils
import ../../../app/core/tasks/[qt, threadpool]
import ../../../app/global/global_singleton

import backend/response_type
import status_go
import constants
import ./dto

include async_tasks

logScope:
  topics = "metrics"

QtObject:
  type MetricsService* = ref object of QObject
    threadpool: ThreadPool

  proc delete*(self: MetricsService) =
    self.QObject.delete

  proc newService*(threadpool: ThreadPool): MetricsService =
    new(result, delete)
    result.QObject.setup
    result.threadpool = threadpool

    signalConnect(singletonInstance.globalEvents, "addCentralizedMetric(QString, QString)",
      result, "addCentralizedMetric(QString, QString)", 2)

  # eventValueJson is a json string
  proc addCentralizedMetric*(self: MetricsService, eventName: string, eventValueJson: string) {.slot.} =
    let arg = AsyncAddCentralizedMetricTaskArg(
      tptr: asyncAddCentralizedMetricTask,
      vptr: cast[ByteAddress](self.vptr),
      slot: "onCentralizedMetricAdded",
      eventName: eventName,
      eventValueJson: eventValueJson,
    )
    self.threadpool.start(arg)

  proc onCentralizedMetricAdded*(self: MetricsService, response: string) {.slot.} =
    try:
      let responseObj = response.parseJson
      let errorString = responseObj{"error"}.getStr()
      if errorString != "":
        error "onCentralizedMetricAdded", error=errorString
        return

      debug "onCentralizedMetricAdded", metricId=responseObj{"metricId"}.getStr()
    except Exception as e:
      error "onCentralizedMetricAdded", exceptionMsg = e.msg

  proc centralizedMetricsEnabledChaned*(self: MetricsService) {.signal.}
  proc isCentralizedMetricsEnabled*(self: MetricsService): bool {.slot.} =
    try:
      let response = status_go.centralizedMetricsInfo()
      let jsonObj = response.parseJson
      if jsonObj.hasKey("error"):
        error "isCentralizedMetricsEnabled", errorMsg=jsonObj["error"].getStr
        return false
      let metricsInfo = toCentralizedMetricsInfoDto(jsonObj)
      return metricsInfo.enabled
    except Exception:
      return false

  QtProperty[bool] isCentralizedMetricsEnabled:
    read = isCentralizedMetricsEnabled
    notify = centralizedMetricsEnabledChaned

  proc toggleCentralizedMetrics*(self: MetricsService, enabled: bool) {.slot.} =
    try:
      let isEnabled = self.isCentralizedMetricsEnabled()
      if enabled == isEnabled:
        return
      let payload = %* {"enabled": enabled}
      let response = status_go.toggleCentralizedMetrics($payload)
      let jsonObj = response.parseJson
      if jsonObj{"error"}.getStr.len > 0:
        error "toggleCentralizedMetrics", errorMsg=jsonObj["error"].getStr
      else:
        self.centralizedMetricsEnabledChaned()
    except Exception as e:
      error "toggleCentralizedMetrics", exceptionMsg = e.msg
