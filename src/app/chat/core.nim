import NimQml, chronicles, tables
import ../../status/chat as chat_model
import ../../status/mailservers as mailserver_model
import ../../status/messages as messages_model
import ../../status/signals/types
import ../../status/libstatus/types as status_types
import ../../status/[chat, contacts, status, wallet, stickers]
import view, views/channels_list, views/message_list, views/reactions, views/stickers as stickers_view
import ../../eventemitter

logScope:
  topics = "chat-controller"

type ChatController* = ref object
  view*: ChatsView
  status*: Status
  variant*: QVariant

proc newController*(status: Status): ChatController =
  result = ChatController()
  result.status = status
  result.view = newChatsView(status)
  result.variant = newQVariant(result.view)

proc delete*(self: ChatController) =
  delete self.variant
  delete self.view

include event_handling
include signal_handling

proc init*(self: ChatController) =
  self.handleMailserverEvents()
  self.handleChatEvents()
  self.handleSignals()

  self.status.mailservers.init()
  self.status.chat.init()
  self.status.stickers.init()
  self.view.reactions.init()

  let recentStickers = self.status.stickers.getRecentStickers()
  for sticker in recentStickers:
    self.view.stickers.addRecentStickerToList(sticker)
    self.status.stickers.addStickerToRecent(sticker)
  self.view.stickers.obtainAvailableStickerPacks()
