import NimQml, strutils, chronicles
import ../eventemitter

import ../../global/app_signals

logScope:
  topics = "urls-manager"

const StatusInternalLink* = "status-app://"
const StatusExternalLink* = "https://status.app/"

QtObject:
  type UrlsManager* = ref object of QObject
    events: EventEmitter
    protocolUriOnStart: string
    appReady: bool

  proc setup(self: UrlsManager, urlSchemeEvent: StatusEvent,
      singleInstance: SingleInstance) =
    self.QObject.setup
    signalConnect(urlSchemeEvent, "urlActivated(QString)", self,
      "onUrlActivated(QString)", 2)
    signalConnect(singleInstance, "eventReceived(QString)", self,
      "onUrlActivated(QString)", 2)

  proc delete*(self: UrlsManager) =
    self.QObject.delete

  proc newUrlsManager*(events: EventEmitter, urlSchemeEvent: StatusEvent,
      singleInstance: SingleInstance, protocolUriOnStart: string): UrlsManager =
    new(result)
    result.setup(urlSchemeEvent, singleInstance)
    result.events = events
    result.protocolUriOnStart = protocolUriOnStart
    result.appReady = false

  proc convertInternalLinkToExternal*(self: UrlsManager, statusDeepLink: string): string =
    let idx = find(statusDeepLink, StatusInternalLink)
    result = statusDeepLink
    if idx != -1:
      result = statusDeepLink[idx + StatusInternalLink.len .. ^1]
      result = StatusExternalLink & result

  proc onUrlActivated*(self: UrlsManager, urlRaw: string) {.slot.} =
    if not self.appReady:
      self.protocolUriOnStart = urlRaw
      return

    let url = urlRaw.multiReplace((" ", ""))
      .multiReplace(("\r\n", ""))
      .multiReplace(("\n", ""))
    let data = StatusUrlArgs(url: self.convertInternalLinkToExternal(url))

    self.events.emit(SIGNAL_STATUS_URL_ACTIVATED, data)

  proc appReady*(self: UrlsManager) =
    self.appReady = true
    if self.protocolUriOnStart != "":
      self.onUrlActivated(self.protocolUriOnStart)
      self.protocolUriOnStart = ""
