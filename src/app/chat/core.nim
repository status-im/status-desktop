import NimQml, eventemitter, chronicles, tables
import ../../status/chat as chat_model
import ../../status/mailservers as mailserver_model
import ../../status/messages as messages_model
import ../../signals/types
import ../../status/libstatus/types as status_types
import ../../status/libstatus/wallet as status_wallet
import ../../status/[chat, contacts, status]
import view, views/channels_list, views/message_list

from eth/common/utils import parseAddress

logScope:
  topics = "chat-controller"

type ChatController* = ref object of SignalSubscriber
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
  self.status.mailservers.init()
  self.status.chat.init()

  let currAcct = status_wallet.getWalletAccounts()[0] # TODO: make generic
  let currAddr = parseAddress(currAcct.address)

  let installedStickerPacks = self.status.chat.getInstalledStickerPacks()

  let purchasedStickerPacks = self.status.chat.getPurchasedStickerPacks(currAddr)

  # TODO: getting available stickers should be done in a separate thread as there
  # a long wait for contract response, decoded, downloading from IPFS, EDN decoding,
  # etc
  let availableStickerPacks = self.status.chat.getAvailableStickerPacks()
  for packId, stickerPack in availableStickerPacks.pairs:
    let isInstalled = installedStickerPacks.hasKey(packId)
    let isBought = purchasedStickerPacks.contains(packId)
    self.view.addStickerPackToList(stickerPack, isInstalled, isBought)

  let recentStickers = self.status.chat.getRecentStickers()
  for sticker in recentStickers:
    self.view.addRecentStickerToList(sticker)
    self.status.chat.addStickerToRecent(sticker)

method onSignal(self: ChatController, data: Signal) =
  case data.signalType: 
  of SignalType.Message: handleMessage(self, MessageSignal(data))
  of SignalType.DiscoverySummary: handleDiscoverySummary(self, DiscoverySummarySignal(data))
  of SignalType.EnvelopeSent: handleEnvelopeSent(self, EnvelopeSentSignal(data))
  of SignalType.EnvelopeExpired: handleEnvelopeExpired(self, EnvelopeExpiredSignal(data))
  else:
    warn "Unhandled signal received", signalType = data.signalType
