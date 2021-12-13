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

  proc getOs*(self: UtilsView): string {.slot.} =
    if defined(windows):
      return "windows"
    elif (defined(macosx)):
      return "mac"
    elif (defined(linux)):
      return "linux"
    return "unknown"

  proc joinPath*(self: UtilsView, start: string, ending: string): string {.slot.} =
    result = os.joinPath(start, ending)

  # proc join3Paths*(self: UtilsView, start: string, middle: string, ending: string): string {.slot.} =
  #   result = os.joinPath(start, middle, ending)

  # proc getSNTAddress*(self: UtilsView): string {.slot.} =
  #   result = status_tokens.getSNTAddress()

  proc getSNTBalance*(self: UtilsView): string {.slot.} =
    let currAcct = self.status.wallet.getWalletAccounts()[0]
    result = status_tokens.getSNTBalance($currAcct.address)

  proc eth2Wei*(self: UtilsView, eth: string, decimals: int): string {.slot.} =
    let uintValue = status_utils.eth2Wei(parseFloat(eth), decimals)
    return uintValue.toString()

  proc eth2Hex*(self: UtilsView, eth: float): string {.slot.} =
    return "0x" & status_utils.eth2Wei(eth, 18).toHex()

  proc gwei2Hex*(self: UtilsView, gwei: float): string {.slot.} =
    return "0x" & status_utils.gwei2wei(gwei).toHex()

  proc getStickerMarketAddress(self: UtilsView): string {.slot.} =
    $self.status.stickers.getStickerMarketAddress

  QtProperty[string] stickerMarketAddress:
    read = getStickerMarketAddress

  proc getEnsRegisterAddress(self: UtilsView): QVariant {.slot.} =
    newQVariant($statusRegistrarAddress())

  QtProperty[QVariant] ensRegisterAddress:
    read = getEnsRegisterAddress

  proc stripTrailingZeroes(value: string): string =
    var str = value.strip(leading = false, chars = {'0'})
    if str[str.len - 1] == '.':
      add(str, "0")
    return str

  proc hex2Ascii*(self: UtilsView, value: string): string {.slot.} =
    result = string.fromBytes(hexToSeqByte(value))

  proc ascii2Hex*(self: UtilsView, value: string): string {.slot.} = 
    result = "0x" & toHex(value)

  proc hex2Eth*(self: UtilsView, value: string): string {.slot.} =
    return stripTrailingZeroes(status_utils.wei2Eth(stint.fromHex(StUint[256], value)))

  proc hex2Dec*(self: UtilsView, value: string): string {.slot.} =
    # somehow this value crashes the app
    if value == "0x0":
      return "0"
    return $stint.fromHex(StUint[256], value)

  proc urlFromUserInput*(self: UtilsView, input: string): string {.slot.} =
    result = url_fromUserInput(input)

  proc wei2Eth*(self: UtilsView, wei: string, decimals: int): string {.slot.} =
    var weiValue = wei
    if(weiValue.startsWith("0x")):
      weiValue = fromHex(Stuint[256], weiValue).toString()
    return status_utils.wei2Eth(weiValue, decimals)

  proc generateAlias*(self: UtilsView, pk: string): string {.slot.} =
    result = self.status.accounts.generateAlias(pk)

  proc generateIdenticon*(self: UtilsView, pk: string): string {.slot.} =
    result = self.status.accounts.generateIdenticon(pk)

  proc getNetworkName*(self: UtilsView): string {.slot.} =
    self.status.settings.getCurrentNetworkDetails().name

  proc getFileSize*(self: UtilsView, filename: string): string {.slot.} =
    var f: File = nil
    if f.open(filename.formatImagePath):
      try:
        result = $(f.getFileSize())
      finally:
        close(f)
    else:
      raise newException(IOError, "cannot open: " & filename)

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
  
  proc readTextFile*(self: UtilsView, filepath: string): string {.slot.} =
    try:
      return readFile(filepath)
    except:
      return ""

  proc writeTextFile*(self: UtilsView, filepath: string, text: string): bool {.slot.} =
    try:
      writeFile(filepath, text)
      return true
    except:
      return false