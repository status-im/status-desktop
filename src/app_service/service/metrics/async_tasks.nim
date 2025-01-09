include ../../common/json_utils
include ../../../app/core/tasks/common

type AsyncAddCentralizedMetricIfEnabledTaskArg = ref object of QObjectTaskArg
  eventName: string
  eventValueJson: string

proc asyncAddCentralizedMetricIfEnabledTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncAddCentralizedMetricIfEnabledTaskArg](argEncoded)
  try:
    let metricsEnabled = getIsCentralizedMetricsEnabled()
    if not metricsEnabled:
      arg.finish(%*{"metricId": "", "metricsDisabled": true, "error": ""})
      return

    debug "Add metric for ",
      eventName = arg.eventName, eventValueJson = arg.eventValueJson
    var metric = CentralizedMetricDto()
    metric.eventName = arg.eventName
    metric.eventValue =
      if arg.eventValueJson.len > 0:
        parseJson(arg.eventValueJson)
      else:
        JsonNode()
    metric.platform = hostOS
    metric.appVersion = APP_VERSION
    let payload = %*{"metric": metric.toJsonNode}
    let response = status_go.addCentralizedMetric($payload)
    try:
      let jsonObj = response.parseJson
      if jsonObj.hasKey("error"):
        arg.finish(
          %*{"metricId": "", "metricsDisabled": false, "error": jsonObj{"error"}.getStr}
        )
        return
    except Exception:
      discard

    arg.finish(%*{"metricId": response, "metricsDisabled": false, "error": ""})
  except Exception as e:
    arg.finish(%*{"metricId": "", "error": e.msg})
