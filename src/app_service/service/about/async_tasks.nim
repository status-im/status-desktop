include ../../common/json_utils
include ../../../app/core/tasks/common

proc getLatestVersionJSON(): string =
  var jsonObj = %*{
    "version": "",
    "url": ""
  }

  try:
    debug "Getting latest version information"

    let latestVersion = getLatestVersion()

    jsonObj["version"] = %*latestVersion.version
    jsonObj["url"] = %*latestVersion.url

  except Exception as e:
    error "Error while getting latest version information", msg = e.msg

  return $jsonObj

const checkForUpdatesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  debug "Check for updates - async"
  let arg = decode[QObjectTaskArg](argEncoded)
  let response = getLatestVersionJSON()
  arg.finish(response)
