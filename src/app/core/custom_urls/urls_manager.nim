import NimQml, strutils, chronicles
import ../eventemitter

import ../../global/app_signals
import ../../../app_service/common/conversion
import ../../../app_service/service/accounts/utils

logScope:
  topics = "urls-manager"

const StatusInternalLink* = "status-app"
const StatusExternalLink* = "status.app"

const profileLinkPrefix* = "/u/"

const UriFormatUserProfile = StatusInternalLink & ":/" & profileLinkPrefix

const UriFormatCommunity = StatusInternalLink & "://c/"

const UriFormatCommunityChannel = StatusInternalLink & "://cc/"

# enable after MVP
#const UriFormatGroupChat = StatusInternalLink & "://g/"
#const UriFormatBrowser = StatusInternalLink & "://b/"

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

  proc prepareCommunityId(self: UrlsManager, communityId: string): string =
    if isCompressedPubKey(communityId):
      return changeCommunityKeyCompression(communityId)
    return communityId

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
      data.communityId = self.prepareCommunityId(url[UriFormatCommunity.len .. url.len-1])

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

  proc convertExternalLinkToInternal*(self: UrlsManager, statusDeepLink: string): string =
    let idx = find(statusDeepLink, StatusExternalLink)
    result = statusDeepLink
    if idx != -1:
      result = statusDeepLink[idx + StatusExternalLink.len .. ^1]
      result = StatusInternalLink & ":/" & result