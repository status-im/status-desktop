import NimQml, os, strformat, strutils, parseUtils, chronicles
import stint
import status/[status, wallet, settings, updates]
import status/stickers
import status/tokens as status_tokens
import status/utils as status_utils
import status/ens as status_ens
import status/types/[network_type]
import ../core/[main]
import ../core/tasks/[qt, threadpool]
import ../utils/image_utils
import web3/[ethtypes, conversions]
import stew/byteutils
import json

const DESKTOP_VERSION {.strdefine.} = "0.0.0"

type CheckForNewVersionTaskArg = ref object of QObjectTaskArg


QtObject:
  type UtilsView* = ref object of QObject
    status*: Status
    statusFoundation: StatusFoundation
    newVersion*: string

  proc setup(self: UtilsView) =
    self.QObject.setup
    self.newVersion = $(%*{
      "available": false,
      "version": "0.0.0",
      "url": "about:blank"
    })

  proc delete*(self: UtilsView) =
    self.QObject.delete

  proc newUtilsView*(status: Status, statusFoundation: StatusFoundation): UtilsView =
    new(result, delete)
    result = UtilsView()
    result.status = status
    result.statusFoundation = statusFoundation
    result.setup


  proc getNetworkName*(self: UtilsView): string {.slot.} =
    self.status.settings.getCurrentNetworkDetails().name

  proc getCurrentVersion*(self: UtilsView): string {.slot.} =
    return DESKTOP_VERSION

  proc newVersionChanged(self: UtilsView) {.signal.}

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

  proc asyncRequestLatestVersion[T](self: T, slot: string) =
    let arg = CheckForNewVersionTaskArg(
      tptr: cast[ByteAddress](checkForUpdatesTask),
      vptr: cast[ByteAddress](self.vptr),
      slot: slot
    )
    self.statusFoundation.threadpool.start(arg)

  proc latestVersionSuccess*(self: UtilsView, latestVersionJSON: string) {.slot.} =
    let latestVersionObj = parseJSON(latestVersionJSON)
    let latestVersion = latestVersionObj{"version"}.getStr()
    if latestVersion == "": return

    let available = isNewer(DESKTOP_VERSION, latestVersion)
    latestVersionObj["available"] = newJBool(available)
    debug "New version?", available, info=latestVersion
    
    self.newVersion = $(%*latestVersionObj)
    self.newVersionChanged()

  proc checkForUpdates*(self: UtilsView) {.slot.} =
    if self.status.settings.getCurrentNetwork() != NetworkType.Mainnet: return
    debug "Check for updates - sync"
    self.latestVersionSuccess(getLatestVersionJSON())

  proc asyncCheckForUpdates*(self: UtilsView) {.slot.} =
    if self.status.settings.getCurrentNetwork() != NetworkType.Mainnet: return
    self.asyncRequestLatestVersion("latestVersionSuccess")

  proc getNewVersion*(self: UtilsView): string {.slot.} =
    return self.newVersion

  QtProperty[string] newVersion:
    read = getNewVersion
    notify = newVersionChanged