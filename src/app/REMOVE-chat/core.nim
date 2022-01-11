import NimQml, chronicles, tables
import status/chat as chat_model
import status/messages as messages_model
import status/[chat, contacts, status, wallet, stickers, settings]
import status/types/[message, transaction, setting]
import ../core/[main]
import view, views/channels_list, views/message_list, views/reactions, views/stickers as stickers_view
import eventemitter

logScope:
  topics = "chat-controller"

type ChatController* = ref object
  view*: ChatsView
  status*: Status
  variant*: QVariant
  statusFoundation: StatusFoundation
  uriToOpen: string

proc newController*(status: Status, statusFoundation: StatusFoundation, uriToOpen: string): ChatController =
  result = ChatController()
  result.status = status
  result.statusFoundation = statusFoundation
  result.uriToOpen = uriToOpen
  result.view = newChatsView(status, statusFoundation)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.variant
  delete self.view

include event_handling
include signal_handling

proc init*(self: ChatController) =
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
    if self.uriToOpen != "":
      self.view.handleProtocolUri(self.uriToOpen)
      self.uriToOpen = ""

  self.status.events.on("contactBlocked") do(e: Args):
    let contactIdArgs = ContactIdArgs(e)
    self.view.messageView.blockContact(contactIdArgs.id)

  self.status.events.on("contactUnblocked") do(e: Args):
    let contactIdArgs = ContactIdArgs(e)
    self.view.messageView.unblockContact(contactIdArgs.id)
