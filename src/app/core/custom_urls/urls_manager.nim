import NimQml, strutils, chronicles
import ../eventemitter

import ../../global/app_signals

logScope:
  topics = "urls-manager"

const UriFormatUserProfile = "status-im://u/"

const UriFormatCommunity = "status-im://c/"

const UriFormatCommunityChannel = "status-im://cc/"

const UriFormatGroupChat = "status-im://g/"

const UriFormatBrowser = "status-im://b/"

QtObject:
  type UrlsManager* = ref object of QObject
    events: EventEmitter
    protocolUriOnStart: string
    loggedIn: bool

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
    result.loggedIn = false

  proc onUrlActivated*(self: UrlsManager, urlRaw: string) {.slot.} =
    if not self.loggedIn:
      self.protocolUriOnStart = urlRaw
      return

    var data = StatusUrlArgs()
    let url = urlRaw.multiReplace((" ", ""))
      .multiReplace(("\r\n", ""))
      .multiReplace(("\n", ""))

    # Display user profile popup for user with `user_pk` or `ens_name`
    if url.startsWith(UriFormatUserProfile):
      data.action = StatusUrlAction.DisplayUserProfile
      data.userId = url[UriFormatUserProfile.len .. url.len-1]

    # Open community with `community_key`
    elif url.startsWith(UriFormatCommunity):
      data.action = StatusUrlAction.OpenCommunity
      data.communityId = url[UriFormatCommunity.len .. url.len-1]

    # Open community which has a channel with `channel_key` and makes that channel active
    elif url.startsWith(UriFormatCommunityChannel):
      data.action = StatusUrlAction.OpenCommunityChannel
      data.chatId = url[UriFormatCommunityChannel.len .. url.len-1]

    # Open `url` in the app's browser
    # Enable after MVP
    #elif url.startsWith(UriFormatBrowser):
    #  data.action = StatusUrlAction.OpenLinkInBrowser
    #  data.url = url[UriFormatBrowser.len .. url.len-1]

    else:
      info "Unsupported deep link structure: ", url
      return

    self.events.emit(SIGNAL_STATUS_URL_REQUESTED, data)

  proc userLoggedIn*(self: UrlsManager) =
    self.loggedIn = true
    if self.protocolUriOnStart != "":
      self.onUrlActivated(self.protocolUriOnStart)
      self.protocolUriOnStart = ""