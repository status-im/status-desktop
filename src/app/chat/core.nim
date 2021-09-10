import NimQml, chronicles, tables
import status/chat as chat_model
import status/messages as messages_model
import status/[chat, contacts, status, wallet, stickers, settings]
import status/types/[message, transaction, os_notification, setting]
import ../../app_service/[main]
import view, views/channels_list, views/message_list, views/reactions, views/stickers as stickers_view
import eventemitter

logScope:
  topics = "chat-controller"

QtObject:
  type ChatController* = ref object of QObject
    view*: ChatsView
    status*: Status
    variant*: QVariant
    appService: AppService
    uriToOpen: string
    appStarted: bool

  proc setup(self: ChatController, status: Status, appService: AppService, 
    urlSchemeEvent: StatusEventObject, uriToOpen: string) = 
    self.QObject.setup
    self.status = status
    self.appService = appService
    self.appStarted = false
    self.uriToOpen = uriToOpen
    self.view = newChatsView(status, appService)
    self.variant = newQVariant(self.view)
    signalConnect(urlSchemeEvent, "urlActivated(QString)", 
    self, "onUrlActivated(QString)", 2)

  proc delete*(self: ChatController) =
    delete self.variant
    delete self.view
    self.QObject.delete
    
  proc newController*(status: Status, appService: AppService, urlSchemeEvent: StatusEventObject, uriToOpen: string): ChatController =
    new(result, delete)
    result.setup(status, appService, urlSchemeEvent, uriToOpen)

  proc loadInitialMessagesForChannel*(self: ChatController, channelId: string)

  include event_handling
  include signal_handling

  proc handleProtocolUri*(self: ChatController) =
    if self.uriToOpen != "":
      self.view.handleProtocolUri(self.uriToOpen)
      self.uriToOpen = ""

  proc init*(self: ChatController) =
    self.handleMailserverEvents()
    self.handleChatEvents()
    self.handleSystemEvents()
    self.handleSignals()

    let pubKey = self.status.settings.getSetting[:string](Setting.PublicKey, "0x0")

    # self.view.pubKey = pubKey
    self.view.setPubKey(pubKey)
    self.status.chat.init(pubKey)
    self.status.stickers.init()
    self.view.reactions.init()
    
    self.view.asyncActivityNotificationLoad()

    let recentStickers = self.status.stickers.getRecentStickers()
    for sticker in recentStickers:
      self.view.stickers.addRecentStickerToList(sticker)
      self.status.stickers.addStickerToRecent(sticker)
    
    if self.status.network.isConnected:
      self.view.stickers.obtainAvailableStickerPacks()
    else:
      self.view.stickers.populateOfflineStickerPacks()

    self.status.events.on("network:disconnected") do(e: Args):
      self.view.stickers.clearStickerPacks()
      self.view.stickers.populateOfflineStickerPacks()

    self.status.events.on("network:connected") do(e: Args):
      self.view.stickers.clearStickerPacks()
      self.view.stickers.obtainAvailableStickerPacks()
      self.handleProtocolUri()
    
    self.appStarted = true

  proc loadInitialMessagesForChannel*(self: ChatController, channelId: string) =
    if (channelId.len == 0):
      info "empty channel id set for loading initial messages"
      return

    if(self.status.chat.isMessageCursorSet(channelId)):
      return

    if(self.status.chat.isEmojiCursorSet(channelId)):
      return

    if(self.status.chat.isPinnedMessageCursorSet(channelId)):
      return

    self.appService.chatService.loadMoreMessagesForChannel(channelId)

  proc onUrlActivated*(self: ChatController, url: string) {.slot.} =
    self.uriToOpen = url
    if (self.appStarted):
      self.handleProtocolUri()
