import NimQml, strutils, chronicles
import ../eventemitter

import ../../global/app_signals

logScope:
  topics = "urls-manager"

const UriFormatBrowserShort = "status-im://b/"
const UriFormatBrowserLong = "status-im://browser/"

const UriFormatUserProfileShort = "status-im://u/"
const UriFormatUserProfileLong = "status-im://user/"

const UriFormatPrivateChatShort = "status-im://pm/"
const UriFormatPrivateChatLong = "status-im://private-message/"

const UriFormatPublicChatShort = "status-im://p/"
const UriFormatPublicChatLong = "status-im://public/"

const UriFormatGroupChatShort = "status-im://g/"
const UriFormatGroupChatLong = "status-im://group/"

const UriFormatCommunityRequestsShort = "status-im://cr/"
const UriFormatCommunityRequestsLong = "status-im://community-requests/"

const UriFormatCommunityShort = "status-im://c/"
const UriFormatCommunityLong = "status-im://community/"

const UriFormatCommunityChannelShort = "status-im://cc/"
const UriFormatCommunityChannelLong = "status-im://community-channel/"

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

  proc prepareGroupChatDetails(self: UrlsManager, urlQuery: string,
       data: var StatusUrlArgs) =
    var urlParams = rsplit(urlQuery, "/u/")
    if(urlParams.len > 0):
      data.groupName = urlParams[0]
      urlParams.delete(0)
      data.listOfUserIds = urlParams
    else:
      info "wrong url format for group chat"

  proc onUrlActivated*(self: UrlsManager, urlRaw: string) {.slot.} =
    if not self.loggedIn:
      self.protocolUriOnStart = urlRaw
      return

    var data = StatusUrlArgs()
    let url = urlRaw.multiReplace((" ", ""))
      .multiReplace(("\r\n", ""))
      .multiReplace(("\n", ""))

    # Open `url` in the app's browser
    if url.startsWith(UriFormatBrowserShort):
      data.action = StatusUrlAction.OpenLinkInBrowser
      data.url = url[UriFormatBrowserShort.len .. url.len-1]
    elif url.startsWith(UriFormatBrowserLong):
      data.action = StatusUrlAction.OpenLinkInBrowser
      data.url = url[UriFormatBrowserLong.len .. url.len-1]
    
    # Display user profile popup for user with `user_pk` or `ens_name`
    elif url.startsWith(UriFormatUserProfileShort):
      data.action = StatusUrlAction.DisplayUserProfile
      data.userId = url[UriFormatUserProfileShort.len .. url.len-1]
    elif url.startsWith(UriFormatUserProfileLong):
      data.action = StatusUrlAction.DisplayUserProfile
      data.userId = url[UriFormatUserProfileLong.len .. url.len-1]
    
    # Open or create 1:1 chat with user with `user_pk` or `ens_name`
    elif url.startsWith(UriFormatPrivateChatShort):
      data.action = StatusUrlAction.OpenOrCreatePrivateChat
      data.chatId = url[UriFormatPrivateChatShort.len .. url.len-1]
    elif url.startsWith(UriFormatPrivateChatLong):
      data.action = StatusUrlAction.OpenOrCreatePrivateChat
      data.chatId = url[UriFormatPrivateChatLong.len .. url.len-1]

    # Open public chat with `chat_key`
    elif url.startsWith(UriFormatPublicChatShort):
      data.action = StatusUrlAction.OpenOrJoinPublicChat
      data.chatId = url[UriFormatPublicChatShort.len .. url.len-1]
    elif url.startsWith(UriFormatPublicChatLong):
      data.action = StatusUrlAction.OpenOrJoinPublicChat
      data.chatId = url[UriFormatPublicChatLong.len .. url.len-1]

    # Open a group chat with named `group_name`, adding up to 19 participants with their `user_pk` or `ens_name`. 
    # Group chat may have up to 20 participants including the admin of a group
    elif url.startsWith(UriFormatGroupChatShort):
      data.action = StatusUrlAction.OpenOrCreateGroupChat
      let urlQuery = url[UriFormatGroupChatShort.len .. url.len-1]
      self.prepareGroupChatDetails(urlQuery, data)
    elif url.startsWith(UriFormatGroupChatLong):
      data.action = StatusUrlAction.OpenOrCreateGroupChat
      let urlQuery = url[UriFormatGroupChatLong.len .. url.len-1]
      self.prepareGroupChatDetails(urlQuery, data)

    # Send a join community request to a community with `community_key`
    elif url.startsWith(UriFormatCommunityRequestsShort):
      data.action = StatusUrlAction.RequestToJoinCommunity
      data.communityId = url[UriFormatCommunityRequestsShort.len .. url.len-1]
    elif url.startsWith(UriFormatCommunityRequestsLong):
      data.action = StatusUrlAction.RequestToJoinCommunity
      data.communityId = url[UriFormatCommunityRequestsLong.len .. url.len-1]

    # Open community with `community_key`
    elif url.startsWith(UriFormatCommunityShort):
      data.action = StatusUrlAction.OpenCommunity
      data.communityId = url[UriFormatCommunityShort.len .. url.len-1]
    elif url.startsWith(UriFormatCommunityLong):
      data.action = StatusUrlAction.OpenCommunity
      data.communityId = url[UriFormatCommunityLong.len .. url.len-1]

    # Open community which has a channel with `channel_key` and makes that channel active
    elif url.startsWith(UriFormatCommunityChannelShort):
      data.action = StatusUrlAction.OpenCommunityChannel
      data.chatId = url[UriFormatCommunityChannelShort.len .. url.len-1]
    elif url.startsWith(UriFormatCommunityChannelLong):
      data.action = StatusUrlAction.OpenCommunityChannel
      data.chatId = url[UriFormatCommunityChannelLong.len .. url.len-1]

    else:
      info "Unsupported deep link structure: ", url
      return

    self.events.emit(SIGNAL_STATUS_URL_REQUESTED, data)

  proc userLoggedIn*(self: UrlsManager) =
    self.loggedIn = true
    if self.protocolUriOnStart != "":
      self.onUrlActivated(self.protocolUriOnStart)
      self.protocolUriOnStart = ""