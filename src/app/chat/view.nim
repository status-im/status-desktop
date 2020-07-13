import NimQml, Tables, json, sequtils, chronicles

import ../../status/status
import ../../status/accounts as status_accounts
import ../../status/chat as status_chat
import ../../status/contacts as status_contacts
import ../../status/ens as status_ens
import ../../status/chat/[chat, message]
import ../../status/libstatus/types
import ../../status/profile/profile

import ../../status/threads

import views/channels_list, views/message_list, views/chat_item, views/sticker_pack_list, views/sticker_list

logScope:
  topics = "chats-view"

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      chats*: ChannelsList
      callResult: string
      messageList: Table[string, ChatMessageList]
      activeChannel*: ChatItemView
      stickerPacks*: StickerPackList
      recentStickers*: StickerList
      replyTo: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) = 
    self.chats.delete
    self.activeChannel.delete
    for msg in self.messageList.values:
      msg.delete
    self.messageList = initTable[string, ChatMessageList]()
    self.QAbstractListModel.delete

  proc newChatsView*(status: Status): ChatsView =
    new(result, delete)
    result.status = status
    result.chats = newChannelsList(status)
    result.activeChannel = newChatItemView(status)
    result.messageList = initTable[string, ChatMessageList]()
    result.stickerPacks = newStickerPackList()
    result.recentStickers = newStickerList()
    result.setup()

  proc addStickerPackToList*(self: ChatsView, stickerPack: StickerPack, isInstalled, isBought: bool) =
    self.stickerPacks.addStickerPackToList(stickerPack, newStickerList(stickerPack.stickers), isInstalled, isBought)
  
  proc getStickerPackList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.stickerPacks)

  QtProperty[QVariant] stickerPacks:
    read = getStickerPackList

  proc getChatsList(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats)

  QtProperty[QVariant] chats:
    read = getChatsList

  proc getChannelColor*(self: ChatsView, channel: string): string {.slot.} =
    self.chats.getChannelColor(channel)

  proc sendMessage*(self: ChatsView, message: string, replyTo: string) {.slot.} =
    self.status.chat.sendMessage(self.activeChannel.id, message, replyTo)

  proc activeChannelChanged*(self: ChatsView) {.signal.}

  proc userNameOrAlias*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.contacts.hasKey(pubKey):
      return status_ens.userNameOrAlias(self.status.chat.contacts[pubKey])
    generateAlias(pubKey)

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    if(self.chats.chats.len == 0): return
    var response = self.status.chat.markAllChannelMessagesRead(self.activeChannel.id)
    if not response.hasKey("error"):
      self.chats.clearUnreadMessagesCount(self.activeChannel.chatItem)
    let selectedChannel = self.chats.getChannel(index)
    if self.activeChannel.id == selectedChannel.id: return

    if selectedChannel.chatType.isOneToOne:
      selectedChannel.name = self.userNameOrAlias(selectedChannel.id)

    self.activeChannel.setChatItem(selectedChannel)
    self.status.chat.setActiveChannel(selectedChannel.id)
    self.activeChannelChanged()

  proc getActiveChannelIdx(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.chats.chats.findIndexById(self.activeChannel.id))

  QtProperty[QVariant] activeChannelIndex:
    read = getActiveChannelIdx
    write = setActiveChannelByIndex
    notify = activeChannelChanged

  proc installStickerPack*(self: ChatsView, packId: int) {.slot.} =
    self.status.chat.installStickerPack(packId)
    self.stickerPacks.updateStickerPackInList(packId, true)
  
  proc uninstallStickerPack*(self: ChatsView, packId: int) {.slot.} =
    self.status.chat.uninstallStickerPack(packId)
    self.status.chat.removeRecentStickers(packId)
    self.stickerPacks.updateStickerPackInList(packId, false)
    self.recentStickers.removeStickersFromList(packId)

  proc getRecentStickerList*(self: ChatsView): QVariant {.slot.} =
    result = newQVariant(self.recentStickers)

  QtProperty[QVariant] recentStickers:
    read = getRecentStickerList

  proc setActiveChannel*(self: ChatsView, channel: string) {.slot.} =
    if(channel == ""): return
    self.activeChannel.setChatItem(self.chats.getChannel(self.chats.chats.findIndexById(channel)))
    self.activeChannelChanged()

  proc getActiveChannel*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.activeChannel)

  QtProperty[QVariant] activeChannel:
    read = getActiveChannel
    write = setActiveChannel
    notify = activeChannelChanged

  proc upsertChannel(self: ChatsView, channel: string) =
    if not self.messageList.hasKey(channel):
      self.messageList[channel] = newChatMessageList(channel, self.status)
      # If there is only one channel, set is as active
      # if (self.activeChannel.chatItem == nil and self.chats.rowCount() == 1):
      #  self.setActiveChannelByIndex(0)
      # RRAMOS: commented because it was hanging the app on login
  
  proc messagePushed*(self: ChatsView) {.signal.}

  proc messageNotificationPushed*(self: ChatsView, chatId: string, text: string) {.signal.}

  proc messagesCleared*(self: ChatsView) {.signal.}

  proc clearMessages*(self: ChatsView, id: string) =
    self.messageList[id].clear()
    self.messagesCleared()

  proc pushMessages*(self:ChatsView, messages: var seq[Message]) =
    for msg in messages.mitems:
      self.upsertChannel(msg.chatId)
      msg.alias = self.status.chat.getUserName(msg.fromAuthor, msg.alias)
      self.messageList[msg.chatId].add(msg)
      self.messagePushed()
      if msg.chatId != self.activeChannel.id:
        self.messageNotificationPushed(msg.chatId, msg.text)

  proc updateUsernames*(self:ChatsView, contacts: seq[Profile]) =
    if contacts.len > 0:
      # Updating usernames for all the messages list
      for k in self.messageList.keys:
        self.messageList[k].updateUsernames(contacts)

  proc markMessageAsSent*(self:ChatsView, chat: string, messageId: string) =
    self.messageList[chat].markMessageAsSent(messageId)

  proc getMessageList(self: ChatsView): QVariant {.slot.} =
    self.upsertChannel(self.activeChannel.id)
    return newQVariant(self.messageList[self.activeChannel.id])

  QtProperty[QVariant] messageList:
    read = getMessageList
    notify = activeChannelChanged

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.chats.addChatItemToList(chatItem)
    self.messagePushed()

  proc addRecentStickerToList*(self: ChatsView, sticker: Sticker) =
    self.recentStickers.addStickerToList(sticker)
  
  proc copyToClipboard*(self: ChatsView, content: string) {.slot.} =
    setClipBoardText(content)

  proc sendSticker*(self: ChatsView, hash: string, pack: int) {.slot.} =
    let sticker = Sticker(hash: hash, packId: pack)
    self.addRecentStickerToList(sticker)
    self.status.chat.sendSticker(self.activeChannel.id, sticker)

  proc joinChat*(self: ChatsView, channel: string, chatTypeInt: int): int {.slot.} =
    self.status.chat.join(channel, ChatType(chatTypeInt))

  proc joinGroup*(self: ChatsView) {.slot.} =
    self.status.chat.confirmJoiningGroup(self.activeChannel.id)

  proc messagesLoaded*(self: ChatsView) {.signal.}

  proc loadMoreMessages*(self: ChatsView) {.slot.} =
    trace "Loading more messages", chaId = self.activeChannel.id
    self.status.chat.chatMessages(self.activeChannel.id, false)
    self.messagesLoaded();

  proc leaveActiveChat*(self: ChatsView) {.slot.} =
    self.status.chat.leave(self.activeChannel.id)

  proc removeChat*(self: ChatsView, chatId: string) = 
    discard self.chats.removeChatItemFromList(chatId)
    self.messageList[chatId].delete
    self.messageList.del(chatId)

  proc clearChatHistory*(self: ChatsView, id: string) {.slot.} =
    self.status.chat.clearHistory(id)

  proc updateChats*(self: ChatsView, chats: seq[Chat]) =
    for chat in chats:
      self.upsertChannel(chat.id)
      self.chats.updateChat(chat)
      if(self.activeChannel.id == chat.id):
        self.activeChannel.setChatItem(chat)
        self.activeChannelChanged()

  proc renameGroup*(self: ChatsView, newName: string) {.slot.} =
    self.status.chat.renameGroup(self.activeChannel.id, newName)

  proc blockContact*(self: ChatsView, id: string): string {.slot.} =
    return self.status.contacts.blockContact(id)

  proc addContact*(self: ChatsView, id: string): string {.slot.} =
    return self.status.contacts.addContact(id)

  proc removeContact*(self: ChatsView, id: string) {.slot.} =
    self.status.contacts.removeContact(id)

  proc createGroup*(self: ChatsView, groupName: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.createGroup(groupName, pubKeysSeq)

  proc addGroupMembers*(self: ChatsView, chatId: string, pubKeys: string) {.slot.} =
    let pubKeysSeq = map(parseJson(pubKeys).getElems(), proc(x:JsonNode):string = x.getStr)
    self.status.chat.addGroupMembers(chatId, pubKeysSeq)

  proc kickGroupMember*(self: ChatsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.kickGroupMember(chatId, pubKey)

  proc makeAdmin*(self: ChatsView, chatId: string, pubKey: string) {.slot.} =
    self.status.chat.makeAdmin(chatId, pubKey)

  proc isEnsVerified*(self: ChatsView, id: string): bool {.slot.} =
    if id == "": return false
    let contact = self.status.contacts.getContactByID(id)
    if contact == nil:
      return false
    result = contact.ensVerified
    

  proc formatENSUsername*(self: ChatsView, username: string): string {.slot.} =
    result = status_ens.addDomain(username)

  proc generateIdenticon*(self: ChatsView, pk: string): string {.slot.} =
    result = status_accounts.generateIdenticon(pk)

  # Resolving a ENS name
  proc resolveENS*(self: ChatsView, ens: string) {.slot.} =
    spawnAndSend(self, "ensResolved") do: # Call self.ensResolved(string) when ens is resolved
      status_ens.pubkey(ens)

  proc ensWasResolved*(self: ChatsView, resolvedPubKey: string) {.signal.}

  proc ensResolved(self: ChatsView, pubKey: string) {.slot.} =
    self.ensWasResolved(pubKey)

