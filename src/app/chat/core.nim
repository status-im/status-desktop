import NimQml, eventemitter, chronicles, tables
import ../../status/chat as chat_model
import ../../status/chat/chat as chat_types
import ../../status/mailservers as mailserver_model
import ../../status/messages as messages_model
import ../../status/signals/types
import ../../status/libstatus/types as status_types
import ../../status/libstatus/settings as status_settings
import ../../status/[chat, contacts, status, wallet, stickers]
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

proc handleProtocolUri(self: ChatController, protocolUri: string) =
  let uriPart = protocolUri.replace("status-im://", "").split("/")
  case uriPart[0]:
    of "chat":
      case uriPart[1]:
        of "public":
          discard self.view.joinChat(uriPart[2], (int)chat_types.ChatType.Public)

proc init*(self: ChatController, protocolUri: string) =
  self.handleMailserverEvents()
  self.handleChatEvents()
  self.handleSignals()

  self.status.mailservers.init()
  self.status.chat.init()
  self.status.stickers.init()
  self.view.obtainAvailableStickerPacks()
  let pubKey = status_settings.getSetting[string](Setting.PublicKey, "0x0")
  self.view.pubKey = pubKey

  self.handleProtocolUri(protocolUri)

  let recentStickers = self.status.stickers.getRecentStickers()
  for sticker in recentStickers:
    self.view.addRecentStickerToList(sticker)
    self.status.stickers.addStickerToRecent(sticker)
