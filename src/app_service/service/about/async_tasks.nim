include ../../common/json_utils
include ../../../app/core/tasks/common

type CheckForNewVersionTaskArg = ref object of QObjectTaskArg


proc getLatestVersionJSON(): string =
  var version = ""
  var url = ""

  try:
    debug "Getting latest version information"
    let latestVersion = getLatestVersion()
    version = latestVersion.version
    url = latestVersion.url
  except Exception as e:
    error "Error while getting latest version information", msg = e.msg

  result = $(%*{
    "version": version,
    "url": url
  })

const checkForUpdatesTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  debug "Check for updates - async"
  let arg = decode[CheckForNewVersionTaskArg](argEncoded)
  arg.finish(getLatestVersionJSON())