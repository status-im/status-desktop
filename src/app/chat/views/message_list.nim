import NimQml, Tables, sets, json, sugar, chronicles, sequtils
import ../../../status/status
import ../../../status/accounts
import ../../../status/chat as status_chat
import ../../../status/chat/[stickers,chat]
import ../../../status/profile/profile
import ../../../status/ens
import ../../../status/types/[message]
import strutils
import message_format
import user_list

type
  ChatMessageRoles {.pure.} = enum
    UserName = UserRole + 1,
    Message = UserRole + 2,
    Timestamp = UserRole + 3
    Identicon = UserRole + 4
    IsCurrentUser = UserRole + 5
    ContentType = UserRole + 6
    Sticker = UserRole + 7
    FromAuthor = UserRole + 8
    Clock = UserRole + 9
    ChatId = UserRole + 10
    SectionIdentifier = UserRole + 11
    Id = UserRole + 12
    OutgoingStatus = UserRole + 13
    ResponseTo = UserRole + 14
    PlainText = UserRole + 15
    Index = UserRole + 16
    Timeout = UserRole + 18
    Image = UserRole + 19
    Audio = UserRole + 20
    AudioDurationMs = UserRole + 21
    EmojiReactions = UserRole + 22
    CommandParameters = UserRole + 23
    LinkUrls = UserRole + 24
    Alias = UserRole + 25
    LocalName = UserRole + 26
    CommunityId = UserRole + 27
    HasMention = UserRole + 28
    StickerPackId = UserRole + 29
    IsPinned = UserRole + 30
    PinnedBy = UserRole + 31
    GapFrom = UserRole + 32
    GapTo = UserRole + 33
    Replace = UserRole + 34
    IsEdited = UserRole + 35

QtObject:
  type
    ChatMessageList* = ref object of QAbstractListModel
      messages*: seq[Message]
      status: Status
      id*: string
      messageIndex: Table[string, int]
      isEdited*: Table[string, bool]
      messageReactions*: Table[string, string]
      timedoutMessages: HashSet[string]
      userList*: UserListView
      loadingHistoryMessages: bool
      initialMessagesLoaded: bool

  proc delete*(self: ChatMessageList) =
    self.messages = @[]
    self.isEdited = initTable[string, bool]()
    self.messageIndex = initTable[string, int]()
    self.timedoutMessages = initHashSet[string]()
    self.QAbstractListModel.delete

  proc fetchMoreMessagesButton(self: ChatMessageList): Message =
    result = Message()
    result.contentType = ContentType.FetchMoreMessagesButton;

  proc chatIdentifier(self: ChatMessageList, chatId:string): Message =
    result = Message()
    result.contentType = ContentType.ChatIdentifier;
    result.chatId = chatId

  proc addFakeMessages*(self: ChatMessageList) =
    self.messages.add(self.fetchMoreMessagesButton())
    self.messages.add(self.chatIdentifier(self.id))

  proc setup*(self: ChatMessageList, chatId: string, status: Status, addFakeMessages: bool) =
    self.messages = @[]
    self.id = chatId
    self.loadingHistoryMessages = false
    self.initialMessagesLoaded = false

    if addFakeMessages:
      self.addFakeMessages()

    self.messageIndex = initTable[string, int]()
    self.timedoutMessages = initHashSet[string]()
    self.isEdited = initTable[string, bool]()
    self.userList = newUserListView(status)
    self.status = status

    self.QAbstractListModel.setup

  proc newChatMessageList*(chatId: string, status: Status, addFakeMessages: bool): ChatMessageList =
    new(result, delete)
    result.setup(chatId, status, addFakeMessages)

  #################################################
  # Properties
  #################################################
  proc loadingHistoryMessagesChanged*(self: ChatMessageList) {.signal.}

  proc setLoadingHistoryMessages*(self: ChatMessageList, value: bool) =
    if (value == self.loadingHistoryMessages):
      return

    self.loadingHistoryMessages = value
    self.loadingHistoryMessagesChanged()

  proc getLoadingHistoryMessages*(self: ChatMessageList): QVariant {.slot.} =
    return newQVariant(self.loadingHistoryMessages)

  QtProperty[QVariant] loadingHistoryMessages:
    read = getLoadingHistoryMessages
    notify = loadingHistoryMessagesChanged

  proc initialMessagesLoadedChanged*(self: ChatMessageList) {.signal.}

  proc setInitialMessagesLoaded*(self: ChatMessageList, value: bool) =
    if (value == self.initialMessagesLoaded):
      return

    self.initialMessagesLoaded = value
    self.initialMessagesLoadedChanged()

  proc getInitialMessagesLoaded*(self: ChatMessageList): QVariant {.slot.} =
    return newQVariant(self.initialMessagesLoaded)

  QtProperty[QVariant] initialMessagesLoaded:
    read = getInitialMessagesLoaded
    notify = initialMessagesLoadedChanged

  proc countChanged*(self: ChatMessageList) {.signal.}

  proc count*(self: ChatMessageList): int {.slot.}  =
    self.messages.len

  QtProperty[int] count:
    read = count
    notify = countChanged

  proc hasMessage*(self: ChatMessageList, messageId: string): bool =
    return self.messageIndex.hasKey(messageId)

  proc getMessage*(self: ChatMessageList, messageId: string): Message =
    return self.messages[self.messageIndex[messageId]]

  proc deleteMessage*(self: ChatMessageList, messageId: string): bool =
    if not self.messageIndex.hasKey(messageId):
      return false

    let messageIndex = self.messageIndex[messageId]
    self.beginRemoveRows(newQModelIndex(), messageIndex, messageIndex)
    self.messages.delete(messageIndex)
    self.messageIndex.del(messageId)
    self.messageReactions.del(messageId)
     # update indexes
    for i in countup(0, self.messages.len - 1):
      self.messageIndex[self.messages[i].id] = i
    self.endRemoveRows()
    self.countChanged()

    return true

  proc deleteMessagesByChatId*(self: ChatMessageList, chatId: string) =
    let messages = self.messages.filter(m => m.chatId == chatId)
    for message in messages:
      discard self.deleteMessage(message.id)

  proc replaceMessage*(self: ChatMessageList, message: Message) =
    let msgIdx = self.messageIndex[message.id]
    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.messages[msgIdx].parsedText = message.parsedText
    self.messages[msgIdx].text = message.text
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.Message.int, ChatMessageRoles.PlainText.int, ChatMessageRoles.IsEdited.int])

  proc resetTimeOut*(self: ChatMessageList, messageId: string) =
    if not self.messageIndex.hasKey(messageId): return
    let msgIdx = self.messageIndex[messageId]
    self.timedoutMessages.excl(messageId)
    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.Timeout.int])

  proc checkTimeout*(self: ChatMessageList, messageId: string) =
    if not self.messageIndex.hasKey(messageId): return

    let msgIdx = self.messageIndex[messageId]
    if self.messages[msgIdx].outgoingStatus != "sending": return

    self.timedoutMessages.incl(messageId)

    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.Timeout.int])

  method rowCount(self: ChatMessageList, index: QModelIndex = nil): int =
    return self.messages.len

  proc getReactions*(self:ChatMessageList, messageId: string):string =
    if not self.messageReactions.hasKey(messageId): return ""
    result = self.messageReactions[messageId]

  method data(self: ChatMessageList, index: QModelIndex, role: int): QVariant =
    if not index.isValid:
      return
    if index.row < 0 or index.row >= self.messages.len:
      return
    let message = self.messages[index.row]
    let chatMessageRole = role.ChatMessageRoles
    let isEdited = if self.isEdited.hasKey(message.id): self.isEdited[message.id] else: false
    case chatMessageRole:
      of ChatMessageRoles.UserName: result = newQVariant(message.userName)
      of ChatMessageRoles.Message: result = newQVariant(renderBlock(message, self.status.chat.contacts))
      of ChatMessageRoles.PlainText: result = newQVariant(message.text)
      of ChatMessageRoles.Timestamp: result = newQVariant(message.timestamp)
      of ChatMessageRoles.Clock: result = newQVariant($message.clock)
      of ChatMessageRoles.Identicon: result = newQVariant(message.identicon)
      of ChatMessageRoles.IsCurrentUser: result = newQVariant(message.isCurrentUser)
      of ChatMessageRoles.ContentType: result = newQVariant(message.contentType.int)
      of ChatMessageRoles.Sticker: result = newQVariant(message.stickerHash.decodeContentHash())
      of ChatMessageRoles.StickerPackId: result = newQVariant(message.stickerPackId)
      of ChatMessageRoles.FromAuthor: result = newQVariant(message.fromAuthor)
      of ChatMessageRoles.ChatId: result = newQVariant(message.chatId)
      of ChatMessageRoles.SectionIdentifier: result = newQVariant(sectionIdentifier(message))
      of ChatMessageRoles.Id: result = newQVariant(message.id)
      of ChatMessageRoles.OutgoingStatus: result = newQVariant(message.outgoingStatus)
      of ChatMessageRoles.ResponseTo: result = newQVariant(message.responseTo)
      of ChatMessageRoles.Index: result = newQVariant(index.row)
      of ChatMessageRoles.Timeout: result = newQVariant(self.timedoutMessages.contains(message.id))
      of ChatMessageRoles.Image: result = newQVariant(message.image)
      of ChatMessageRoles.Audio: result = newQVariant(message.audio)
      of ChatMessageRoles.AudioDurationMs: result = newQVariant(message.audioDurationMs)
      of ChatMessageRoles.EmojiReactions: result = newQVariant(self.getReactions(message.id))
      of ChatMessageRoles.LinkUrls: result = newQVariant(message.linkUrls)
      of ChatMessageRoles.CommunityId: result = newQVariant(message.communityId)
      of ChatMessageRoles.HasMention: result = newQVariant(message.hasMention)
      of ChatMessageRoles.IsPinned: result = newQVariant(message.isPinned)
      of ChatMessageRoles.PinnedBy: result = newQVariant(message.pinnedBy)
      # Pass the command parameters as a JSON string
      of ChatMessageRoles.CommandParameters: result = newQVariant($(%*{
        "id": message.commandParameters.id,
        "fromAddress": message.commandParameters.fromAddress,
        "address": message.commandParameters.address,
        "contract": message.commandParameters.contract,
        "value": message.commandParameters.value,
        "transactionHash": message.commandParameters.transactionHash,
        "commandState": message.commandParameters.commandState,
        "signature": message.commandParameters.signature
      }))
      of ChatMessageRoles.Alias: result = newQVariant(message.alias)
      of ChatMessageRoles.LocalName: result = newQVariant(message.localName)
      of ChatMessageRoles.GapFrom: result = newQVariant(message.gapFrom)
      of ChatMessageRoles.GapTo: result = newQVariant(message.gapTo)
      of ChatMessageRoles.Replace: result = newQVariant(message.replace)
      of ChatMessageRoles.IsEdited: result = newQVariant(isEdited)

  method roleNames(self: ChatMessageList): Table[int, string] =
    {
      ChatMessageRoles.UserName.int:"userName",
      ChatMessageRoles.Message.int:"message",
      ChatMessageRoles.PlainText.int:"plainText",
      ChatMessageRoles.Timestamp.int:"timestamp",
      ChatMessageRoles.Clock.int:"clock",
      ChatMessageRoles.Identicon.int:"identicon",
      ChatMessageRoles.IsCurrentUser.int:"isCurrentUser",
      ChatMessageRoles.ContentType.int:"contentType",
      ChatMessageRoles.Sticker.int:"sticker",
      ChatMessageRoles.FromAuthor.int:"fromAuthor",
      ChatMessageRoles.ChatId.int:"chatId",
      ChatMessageRoles.SectionIdentifier.int: "sectionIdentifier",
      ChatMessageRoles.Id.int: "messageId",
      ChatMessageRoles.OutgoingStatus.int: "outgoingStatus",
      ChatMessageRoles.ResponseTo.int: "responseTo",
      ChatMessageRoles.Index.int: "index",
      ChatMessageRoles.Timeout.int: "timeout",
      ChatMessageRoles.Image.int: "image",
      ChatMessageRoles.Audio.int: "audio",
      ChatMessageRoles.AudioDurationMs.int: "audioDurationMs",
      ChatMessageRoles.EmojiReactions.int: "emojiReactions",
      ChatMessageRoles.LinkUrls.int: "linkUrls",
      ChatMessageRoles.CommandParameters.int: "commandParameters",
      ChatMessageRoles.CommunityId.int: "communityId",
      ChatMessageRoles.Alias.int:"alias",
      ChatMessageRoles.HasMention.int:"hasMention",
      ChatMessageRoles.IsPinned.int:"isPinned",
      ChatMessageRoles.PinnedBy.int:"pinnedBy",
      ChatMessageRoles.LocalName.int:"localName",
      ChatMessageRoles.StickerPackId.int:"stickerPackId",
      ChatMessageRoles.GapFrom.int:"gapFrom",
      ChatMessageRoles.GapTo.int:"gapTo",
      ChatMessageRoles.Replace.int:"replaces",
      ChatMessageRoles.IsEdited.int:"isEdited"
    }.toTable

  proc getMessageIndex*(self: ChatMessageList, messageId: string): int {.slot.} =
    if not self.messageIndex.hasKey(messageId): return -1
    result = self.messageIndex[messageId]

  # TODO: see how to use data() instead of this function
  proc getMessageData*(self: ChatMessageList, index: int, data: string): string {.slot.} =
    if index < 0 or index >= self.messages.len: return ("")

    let message = self.messages[index]
    case data:
    of "userName": result = message.userName
    of "publicKey": result = message.fromAuthor
    of "alias": result = message.alias
    of "localName": result = message.localName
    of "ensName": result = message.ensName
    of "message": result = (renderBlock(message, self.status.chat.contacts))
    of "identicon": result = message.identicon
    of "timestamp": result = $(message.timestamp)
    of "image": result = $(message.image)
    of "contentType": result = $(message.contentType.int)
    of "sticker": result = $(message.stickerHash.decodeContentHash())
    of "isEdited": result = if self.isEdited.hasKey(message.id): $self.isEdited[message.id] else: $false
    else: result = ("")

  proc contains*(self: ChatMessageList, message: Message):bool =
    return self.messageIndex.hasKey(message.id)

  proc addChatMembers*(self: ChatMessageList, members: seq[ChatMember]) =
    self.userList.add(members)

  proc add*(self: ChatMessageList, message: Message) =
    if self.messageIndex.hasKey(message.id) and message.editedAt == "0": return # duplicated msg

    if message.editedAt != "0":
      self.isEdited[message.id] = true
      if self.messageIndex.hasKey(message.id):
        self.replaceMessage(message)
        return

    self.userList.add(message)

    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len)
    self.messageIndex[message.id] = self.messages.len
    self.messages.add(message)
    self.endInsertRows()
    self.countChanged()

  proc add*(self: ChatMessageList, messages: seq[Message]) =
    self.beginInsertRows(newQModelIndex(), self.messages.len, self.messages.len + messages.len - 1)
    for message in messages:
      if self.messageIndex.hasKey(message.id): continue
      self.messageIndex[message.id] = self.messages.len
      self.messages.add(message)
      self.userList.add(message)
    self.endInsertRows()
    self.countChanged()

  proc remove*(self: ChatMessageList, messageId: string) =
    if not self.messageIndex.hasKey(messageId): return

    let index = self.getMessageIndex(messageId)
    self.beginRemoveRows(newQModelIndex(), index, index)
    self.messages.delete(index)
    self.messageIndex.del(messageId)
    self.endRemoveRows()
    self.countChanged()

  proc getMessageById*(self: ChatMessageList, messageId: string): Message =
    if (not self.messageIndex.hasKey(messageId)): return
    return self.messages[self.messageIndex[messageId]]

  proc clear*(self: ChatMessageList, addFakeMessages: bool = true) =
    self.beginResetModel()
    self.messages = @[]
    self.messageIndex.clear
    if (addFakeMessages):
      self.addFakeMessages()
    self.endResetModel()
    self.countChanged()

  proc setMessageReactions*(self: ChatMessageList, messageId: string, newReactions: string)=
    self.messageReactions[messageId] = newReactions
    if not self.messageIndex.hasKey(messageId): return
    let msgIdx = self.messageIndex[messageId]
    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.EmojiReactions.int])

  proc changeMessagePinned*(self: ChatMessageList, messageId: string, pinned: bool, pinnedBy: string): bool {.discardable.} =
    if not self.messageIndex.hasKey(messageId): return false

    let msgIdx = self.messageIndex[messageId]
    if msgIdx < 0: return false
    if msgIdx >= self.messages.len: return false

    var message = self.messages[msgIdx]
    message.isPinned = pinned
    message.pinnedBy = pinnedBy
    self.messages[msgIdx] = message
    let topLeft = self.createIndex(msgIdx, 0, nil)
    let bottomRight = self.createIndex(msgIdx, 0, nil)
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.IsPinned.int, ChatMessageRoles.PinnedBy.int])
    return true

  proc markMessageAsSent*(self: ChatMessageList, messageId: string)=
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.messages.len, 0, nil)
    for m in self.messages.mitems:
      if m.id == messageId:
        m.outgoingStatus = "sent"
        break
    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.OutgoingStatus.int])

  proc updateUsernames*(self: ChatMessageList, contacts: seq[Profile]) =
    let topLeft = self.createIndex(0, 0, nil)
    let bottomRight = self.createIndex(self.messages.len, 0, nil)

    # TODO: change this once the contact list uses a table
    for c in contacts:
      for m in self.messages.mitems:
        if m.fromAuthor == c.id:
          m.userName = userNameOrAlias(c)
          m.alias = c.alias
          m.localName = c.localNickname
          self.userList.updateUsernames(c.id, m.username, m.alias, m.localname)

    self.dataChanged(topLeft, bottomRight, @[ChatMessageRoles.Username.int])

  proc removeMessagesByUserId*(self: ChatMessageList, publicKey: string) =
    var msgIdxToDelete: seq[string] = @[]
    for m in self.messages.items:
      if m.fromAuthor == publicKey: # Can't delete on a loop
        msgIdxToDelete.add(m.id)
    for m in msgIdxToDelete:
      discard self.deleteMessage(m)

  proc getID*(self: ChatMessageList):string  {.slot.} =
    self.id

  proc getUserList*(self: ChatMessageList): QVariant {.slot.} =
    newQVariant(self.userList)

  QtProperty[QVariant] userList:
    read = getUserList

  proc getMessageIdWhichReplacedMessageWithId*(self: ChatMessageList, replacedMessageId: string): string =
    ## Returns id of the message which replaced a message with a certain id.
    ## Returns message id as a string or an empty string if there is no such message.

    for message in self.messages:
      if (message.replace == replacedMessageId):
        return message.id