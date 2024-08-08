include ../../common/json_utils
include ../../../app/core/tasks/common

type
  AsyncAddCentralizedMetricTaskArg = ref object of QObjectTaskArg
    eventName: string
    eventValueJson: string

proc asyncAddCentralizedMetricTask(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncAddCentralizedMetricTaskArg](argEncoded)
  try:
    var metric = CentralizedMetricDto()
    metric.eventName = arg.eventName
    metric.eventValue = if arg.eventValueJson.len > 0: parseJson(arg.eventValueJson) else: JsonNode()
    metric.platform = hostOS
    metric.appVersion = APP_VERSION
    let payload = %* {"metric": metric.toJsonNode}
    let response = status_go.addCentralizedMetric($payload)
    try:
      let jsonObj = response.parseJson
      if jsonObj.hasKey("error"):
        arg.finish(%* {
          "metricId": "",
          "error": jsonObj{"error"}.getStr,
        })
        return
    except Exception:
      discard

    arg.finish(%* {
      "metricId": response,
      "error": "",
    })

  except Exception as e:
    arg.finish(%* {
      "metricId": "",
      "error": e.msg,
    })
