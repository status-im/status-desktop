import NimQml, eventemitter, chronicles, tables
import ../../status/chat as chat_model
import ../../status/mailservers as mailserver_model
import ../../status/messages as messages_model
import ../../status/signals/types
import ../../status/libstatus/types as status_types
import ../../status/libstatus/settings as status_settings
import ../../status/[chat, contacts, status]
import view, views/channels_list, views/message_list

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
  self.view.obtainAvailableStickerPacks()
  let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
  self.view.pubKey = pubKey

  let recentStickers = self.status.chat.getRecentStickers()
  for sticker in recentStickers:
    self.view.addRecentStickerToList(sticker)
    self.status.chat.addStickerToRecent(sticker)
