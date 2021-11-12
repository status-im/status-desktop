import NimQml, Tables, json, sequtils, chronicles, strutils, os, strformat
import status/[status]
import status/utils as status_utils
import status/chat as status_chat
import status/messages as status_messages
import status/contacts as status_contacts
import status/ens as status_ens
import status/chat/[chat]
import status/types/[activity_center_notification, os_notification, rpc_response, profile]
import ../../app_service/[main]
import ../../app_service/tasks/[qt, threadpool]
import ../../app_service/tasks/marathon/mailserver/worker
import status/notifications/[os_notifications]
import ../utils/image_utils
import web3/[conversions, ethtypes]
import views/[channels_list, message_list, chat_item, reactions, stickers, groups, transactions, communities, community_list, community_item, format_input, ens, activity_notification_list, channel, messages, message_item, gif]
import ../../constants

# TODO: remove me
import status/statusgo_backend/chat as statusgo_backend_chat

logScope:
  topics = "chats-view"

type
  GetLinkPreviewDataTaskArg = ref object of QObjectTaskArg
    link: string
    uuid: string
  AsyncActivityNotificationLoadTaskArg = ref object of QObjectTaskArg

const getLinkPreviewDataTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[GetLinkPreviewDataTaskArg](argEncoded)
  var success: bool
  let
    response = status_chat.getLinkPreviewData(arg.link, success)
    responseJson = %* { "result": %response, "success": %success, "uuid": %arg.uuid }
  arg.finish(responseJson)

proc getLinkPreviewData[T](self: T, slot: string, link: string, uuid: string) =
  let arg = GetLinkPreviewDataTaskArg(
    tptr: cast[ByteAddress](getLinkPreviewDataTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot,
    link: link,
    uuid: uuid
  )
  self.appService.threadpool.start(arg)

const asyncActivityNotificationLoadTask: Task = proc(argEncoded: string) {.gcsafe, nimcall.} =
  let arg = decode[AsyncActivityNotificationLoadTaskArg](argEncoded)
  var activityNotifications: JsonNode
  var activityNotificationsCallSuccess: bool
  let activityNotificationsCallResult = statusgo_backend_chat.rpcActivityCenterNotifications(newJString(""), 20, activityNotificationsCallSuccess)
  if(activityNotificationsCallSuccess):
    activityNotifications = activityNotificationsCallResult.parseJson()["result"]

  let responseJson = %*{
    "activityNotifications": activityNotifications
  }
  arg.finish(responseJson)

proc asyncActivityNotificationLoad[T](self: T, slot: string) =
  let arg = AsyncActivityNotificationLoadTaskArg(
    tptr: cast[ByteAddress](asyncActivityNotificationLoadTask),
    vptr: cast[ByteAddress](self.vptr),
    slot: slot
  )
  self.appService.threadpool.start(arg)

QtObject:
  type
    ChatsView* = ref object of QAbstractListModel
      status: Status
      appService: AppService
      formatInputView: FormatInputView
      ensView: EnsView
      channelView*: ChannelView
      messageView*: MessageView
      activityNotificationList*: ActivityNotificationList
      callResult: string
      reactions*: ReactionView
      stickers*: StickersView
      gif*: GifView
      groups*: GroupsView
      transactions*: TransactionsView
      communities*: CommunitiesView
      replyTo: string
      connected: bool
      pubKey*: string

  proc setup(self: ChatsView) = self.QAbstractListModel.setup

  proc delete(self: ChatsView) =
    self.formatInputView.delete
    self.ensView.delete
    self.activityNotificationList.delete
    self.reactions.delete
    self.stickers.delete
    self.gif.delete
    self.groups.delete
    self.transactions.delete
    self.communities.delete
    self.QAbstractListModel.delete

  proc newChatsView*(status: Status, appService: AppService): ChatsView =
    new(result, delete)
    result.status = status
    result.appService = appService
    result.formatInputView = newFormatInputView()
    result.ensView = newEnsView(status, appService)
    result.communities = newCommunitiesView(status)
    result.activityNotificationList = newActivityNotificationList(status)
    result.channelView = newChannelView(status, appService, result.communities, result.activityNotificationList)
    result.messageView = newMessageView(status, appService, result.channelView, result.communities)
    result.connected = false
    result.reactions = newReactionView(
      status,
      result.messageView.messageList.addr,
      result.messageView.pinnedMessagesList.addr,
      result.channelView.activeChannel
    )
    result.stickers = newStickersView(status, appService, result.channelView.activeChannel)
    result.gif = newGifView()
    result.groups = newGroupsView(status,result.channelView.activeChannel)
    result.transactions = newTransactionsView(status)

    result.setup()

  proc setPubKey*(self: ChatsView, pubKey: string) =
    self.pubKey = pubKey
    self.messageView.pubKey = pubKey
    self.communities.pubKey = pubKey

  proc getFormatInput(self: ChatsView): QVariant {.slot.} = newQVariant(self.formatInputView)
  QtProperty[QVariant] formatInputView:
    read = getFormatInput

  proc getEns(self: ChatsView): QVariant {.slot.} = newQVariant(self.ensView)
  QtProperty[QVariant] ensView:
    read = getEns

  proc getCommunities*(self: ChatsView): QVariant {.slot.} = newQVariant(self.communities)
  QtProperty[QVariant] communities:
    read = getCommunities

  proc getChannelView*(self: ChatsView): QVariant {.slot.} = newQVariant(self.channelView)
  QtProperty[QVariant] channelView:
    read = getChannelView

  proc triggerActiveChannelChange*(self:ChatsView) {.signal.}

  proc activeChannelChanged*(self: ChatsView) {.slot.} =
    self.channelView.activeChannelChanged()
    self.messageView.activeChannelChanged()
    self.triggerActiveChannelChange()

  proc getMessageView*(self: ChatsView): QVariant {.slot.} = newQVariant(self.messageView)
  QtProperty[QVariant] messageView:
    read = getMessageView

  proc plainText(self: ChatsView, input: string): string {.slot.} =
    result = plain_text(input)

  proc sendImage*(self: ChatsView, imagePath: string, isStatusUpdate: bool = false): string {.slot.} =
    result = ""
    try:
      var image = image_utils.formatImagePath(imagePath)
      let tmpImagePath = image_resizer(image, 2000, TMPDIR)

      var channelId = self.channelView.activeChannel.id

      if isStatusUpdate:
        channelId = "@" & self.pubKey

      self.status.chat.sendImage(channelId, tmpImagePath)
      removeFile(tmpImagePath)
    except Exception as e:
      error "Error sending the image", msg = e.msg
      result = fmt"Error sending the image: {e.msg}"

  proc sendImages*(self: ChatsView, imagePathsArray: string): string {.slot.} =
    result = ""
    try:
      var images = Json.decode(imagePathsArray, seq[string])
      let channelId = self.channelView.activeChannel.id

      for imagePath in images.mitems:
        var image = image_utils.formatImagePath(imagePath)
        imagePath = image_resizer(image, 2000, TMPDIR)

      self.status.chat.sendImages(channelId, images)

      for imagePath in images.items:
        removeFile(imagePath)
    except Exception as e:
      error "Error sending images", msg = e.msg
      result = fmt"Error sending images: {e.msg}"

  proc appReady*(self: ChatsView) {.signal.}

  proc alias*(self: ChatsView, pubKey: string): string {.slot.} =
    if (pubKey == ""):
      return ""
    generateAlias(pubKey)

  proc userNameOrAlias*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.getContacts().hasKey(pubKey):
      return status_ens.userNameOrAlias(self.status.chat.getContacts()[pubKey])
    generateAlias(pubKey)

  proc getProfileThumbnail*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.getContacts().hasKey(pubKey):
      return self.status.chat.getContacts()[pubKey].identityImage.thumbnail
    else:
      return ""
  
  proc getProfileImageLarge*(self: ChatsView, pubKey: string): string {.slot.} =
    if self.status.chat.getContacts().hasKey(pubKey):
      return self.status.chat.getContacts()[pubKey].identityImage.large
    else:
      return ""

  proc activityNotificationsChanged*(self: ChatsView) {.signal.}

  proc getActivityNotificationList(self: ChatsView): QVariant {.slot.} =
    return newQVariant(self.activityNotificationList)

  QtProperty[QVariant] activityNotificationList:
    read = getActivityNotificationList
    notify = activityNotificationsChanged

  proc pushActivityCenterNotifications*(self:ChatsView, activityCenterNotifications: seq[ActivityCenterNotification]) =
    self.activityNotificationList.addActivityNotificationItemsToList(activityCenterNotifications)
    self.activityNotificationsChanged()

  proc addActivityCenterNotification*(self:ChatsView, activityCenterNotifications: seq[ActivityCenterNotification]) =
    for activityCenterNotification in activityCenterNotifications:
      if self.channelView.activeChannel.id == activityCenterNotification.chatId:
        activityCenterNotification.read = true
        let communityId = self.status.chat.getCommunityIdForChat(activityCenterNotification.chatId)
        if communityId != "":
          self.communities.joinedCommunityList.decrementMentions(communityId, activityCenterNotification.chatId)
      self.activityNotificationList.addActivityNotificationItemToList(activityCenterNotification)
    self.activityNotificationsChanged()

  proc updateUsernames*(self:ChatsView, contacts: seq[Profile]) =
    if contacts.len > 0:
      # Updating usernames for all the messages list
      for k in self.messageView.messageList.keys:
        self.messageView.messageList[k].updateUsernames(contacts)
      self.channelView.activeChannel.contactsUpdated()

  proc updateChannelForContacts*(self: ChatsView, contacts: seq[Profile]) =
    for contact in contacts:
      let channel = self.channelView.chats.getChannelById(contact.id)
      if not channel.isNil:
        if contact.localNickname == "":
          if channel.name == "" or channel.name == channel.id:
            if channel.ensName != "":
              channel.name = channel.ensName
            else:
              channel.name = contact.username
        else:
          channel.name = contact.localNickname
        self.channelView.chats.updateChat(channel)
        if (self.channelView.activeChannel.id == channel.id):
          self.channelView.activeChannel.setChatItem(channel)
          self.activeChannelChanged()

  proc pushChatItem*(self: ChatsView, chatItem: Chat) =
    discard self.channelView.chats.addChatItemToList(chatItem)
    self.messageView.messagePushed(self.messageView.messageList[chatItem.id].count - 1)

  proc copyToClipboard*(self: ChatsView, content: string) {.slot.} =
    setClipBoardText(content)

  proc copyImageToClipboard*(self: ChatsView, content: string) {.slot} =
    setClipBoardImage(content)

  proc downloadImage*(self: ChatsView, content: string, path: string) {.slot} =
    downloadImage(content, path)

  proc linkPreviewDataWasReceived*(self: ChatsView, previewData: string) {.signal.}

  proc linkPreviewDataReceived(self: ChatsView, previewData: string) {.slot.} =
    self.linkPreviewDataWasReceived(previewData)

  proc getLinkPreviewData*(self: ChatsView, link: string, uuid: string) {.slot.} =
    self.getLinkPreviewData("linkPreviewDataReceived", link, uuid)

  proc getChannel*(self: ChatsView, channel: string): string {.slot.} =
    let selectedChannel = self.channelView.getChannelById(channel)
    if selectedChannel == nil:
      return ""

    result = Json.encode(selectedChannel.toJsonNode())

  proc asyncActivityNotificationLoad*(self: ChatsView) {.slot.} =
    self.asyncActivityNotificationLoad("asyncActivityNotificationLoaded")

  proc asyncActivityNotificationLoaded*(self: ChatsView, rpcResponse: string) {.slot.} =
    let rpcResponseObj = rpcResponse.parseJson

    if(rpcResponseObj["activityNotifications"].kind != JNull):
      let activityNotifications = parseActivityCenterNotifications(rpcResponseObj["activityNotifications"])
      self.status.chat.activityCenterNotifications(activityNotifications[0], activityNotifications[1])

  proc removeChat*(self: ChatsView, chatId: string) =
    discard self.channelView.chats.removeChatItemFromList(chatId)
    self.messageView.removeChat(chatId)

  proc toggleReaction*(self: ChatsView, messageId: string, emojiId: int) {.slot.} =
      self.reactions.toggle(messageId, self.channelView.activeChannel.id, emojiId)

  proc updateChats*(self: ChatsView, chats: seq[Chat]) =
    for chat in chats:
      if (chat.communityId != ""):
        self.communities.updateCommunityChat(chat)
        if(self.channelView.activeChannel.id == chat.id):
          self.activeChannelChanged()

        continue

      self.messageView.upsertChannel(chat.id)
      self.channelView.chats.updateChat(chat)

      if(self.channelView.activeChannel.id == chat.id):
        self.channelView.activeChannel.setChatItem(chat)
        self.activeChannelChanged()

      if self.channelView.contextChannel.id == chat.id:
        self.channelView.contextChannel.setChatItem(chat)
        self.channelView.contextChannelChanged()

    self.messageView.calculateUnreadMessages()

  proc isConnected*(self: ChatsView): bool {.slot.} =
    result = self.status.network.isConnected

  proc onlineStatusChanged(self: ChatsView, connected: bool) {.signal.}

  proc setConnected*(self: ChatsView, connected: bool) =
    self.connected = connected
    self.onlineStatusChanged(connected)

  QtProperty[bool] isOnline:
    read = isConnected
    notify = onlineStatusChanged

  proc getReactions*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.reactions)

  QtProperty[QVariant] reactions:
    read = getReactions

  proc getStickers*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.stickers)

  QtProperty[QVariant] stickers:
    read = getStickers

  proc getGif*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.gif)

  QtProperty[QVariant] gif:
    read = getGif

  proc getGroups*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.groups)

  QtProperty[QVariant] groups:
    read = getGroups

  proc getTransactions*(self: ChatsView): QVariant {.slot.} =
    newQVariant(self.transactions)

  QtProperty[QVariant] transactions:
    read = getTransactions


  proc createCommunityChannel*(self: ChatsView, communityId: string, name: string, description: string, categoryId: string): string {.slot.} =
    try:
      let chat = self.status.chat.createCommunityChannel(communityId, name, description)
      if categoryId != "":
        self.status.chat.reorderCommunityChannel(communityId, categoryId, chat.id.replace(communityId, ""), 0)

      chat.categoryId = categoryId
      self.communities.joinedCommunityList.addChannelToCommunity(communityId, chat)
      self.communities.activeCommunity.addChatItemToList(chat)
      self.channelView.setActiveChannel(chat.id)
    except RpcException as e:
      error "Error creating channel", msg=e.msg, name, description
      result = StatusGoError(error: e.msg).toJson

  proc editCommunityChannel*(self: ChatsView, communityId: string, channelId: string, name: string, description: string, categoryId: string, position: int): string {.slot.} =
    try:
      let chat = self.status.chat.editCommunityChannel(communityId, channelId, name, description, categoryId, position)

      chat.categoryId = categoryId
      self.communities.joinedCommunityList.replaceChannelInCommunity(communityId, chat)
      self.communities.activeCommunity.updateChatItemInList(chat)
      self.channelView.setActiveChannel(chat.id)
    except RpcException as e:
      error "Error editing channel", msg=e.msg, channelId, name, description
      result = StatusGoError(error: e.msg).toJson

  proc getChannelNameById*(self: ChatsView, channelId: string): string {.slot.} =
    if self.status.chat.channels.hasKey(channelId):
      result = self.status.chat.channels[channelId].name

  proc setActiveChannelByIndex*(self: ChatsView, index: int) {.slot.} =
    self.channelView.setActiveChannelByIndex(index)

  proc restorePreviousActiveChannel*(self: ChatsView) {.slot.} =
    self.channelView.restorePreviousActiveChannel()

  proc setActiveChannel*(self: ChatsView, channel: string) {.slot.} =
    self.channelView.setActiveChannel(channel)
    self.messageView.activeChannelChanged()

  proc requestMoreMessages*(self: ChatsView, fetchRange: int) {.slot.} =
    self.messageView.loadingMessages = true
    self.messageView.loadingMessagesChanged(true)
    let mailserverWorker = self.appService.marathon[MailserverWorker().name]
    let task = RequestMessagesTaskArg( `method`: "requestMoreMessages", chatId: self.channelView.activeChannel.id)
    mailserverWorker.start(task)

  proc onMessagesLoaded*(self: ChatsView, chatId: string, messages: var seq[Message]) =
    self.messageView.onMessagesLoaded(chatId, messages)

  proc pushMessages*(self: ChatsView, messages: var seq[Message]) =
    self.messageView.pushMessages(messages)

  proc pushMembers*(self: ChatsView, chats: seq[Chat]) =
    self.messageView.pushMembers(chats)

  proc pushPinnedMessages*(self: ChatsView, pinnedMessages: var seq[Message]) =
    self.messageView.pushPinnedMessages(pinnedMessages)


  proc deleteMessage*(self: ChatsView, channelId: string, messageId: string): bool =
    result = self.messageView.deleteMessage(channelId, messageId)

  proc deleteMessageWhichReplacedMessageWithId*(self: ChatsView, channelId: string, messageId: string): bool =
    result = self.messageView.deleteMessageWhichReplacedMessageWithId(channelId, messageId)

  proc refreshPinnedMessages*(self: ChatsView, pinnedMessages: seq[Message]) =
    self.messageView.refreshPinnedMessages(pinnedMessages)

  proc deleteMessage*(self: ChatsView, messageId: string) =
    let chatId = self.messageView.getChatIdForMessage(messageId)
    if (chatId.len == 0):
      return
    discard self.deleteMessage(chatId, messageId)


  proc clearMessages*(self: ChatsView, id: string) =
    self.messageView.clearMessages(id)

  proc calculateUnreadMessages*(self: ChatsView) =
    self.messageView.calculateUnreadMessages()

  proc sendingMessageSuccess*(self: ChatsView) =
    self.messageView.sendingMessageSuccess()

  proc sendingMessageFailed*(self: ChatsView) =
    self.messageView.sendingMessageFailed()

  proc markMessageAsSent*(self: ChatsView, chat: string, messageId: string) =
    self.messageView.markMessageAsSent(chat, messageId)

  proc switchTo*(self: ChatsView, communityId: string, channelId: string, 
    messageId: string) =
    ## This method displays community with communityId as an active one (if 
    ## communityId is empty, "Chat" section will be active), then displays 
    ## channel/chat with channelId as an active one and finally display message
    ## with messageId as a central message in the message list.    
    if (communityId.len > 0):
      self.communities.setActiveCommunity(communityId)
      if (channelId.len > 0):
        self.channelView.setActiveChannel(channelId)
        if (messageId.len > 0):
          self.messageView.switchToMessage(messageId)
    else:
      self.communities.activeCommunity.setActive(false)
      if (channelId.len > 0):
        self.channelView.setActiveChannel(channelId)
        if (messageId.len > 0):
          self.messageView.switchToMessage(messageId)

  proc switchToSearchedItem*(self: ChatsView, itemId: string) {.slot.} =
    discard
    # Not refactored yet, will be once we have corresponding qml part done.
    # let info = self.messageSearchViewController.getItemInfo(itemId)
    # if(info.isEmpty()):
    #   return

    # self.switchTo(info.communityId, info.channelId, info.messageId)

  proc notificationClicked*(self:ChatsView, notificationType: int) {.signal.}

  proc onOsNotificationClicked*(self: ChatsView, details: OsNotificationDetails) =
    # A logic what should be done depends on details.notificationType and should be
    # defined here in this method.
    # So far if notificationType is:
    # - NewContactRequest or AcceptedContactRequest we are switching to Chat section
    # - JoinCommunityRequest or AcceptedIntoCommunity we are switching to that Community
    # - RejectedByCommunity we are switching to Chat section
    # - NewMessage we are switching to appropriate chat/channel and a message inside it
    
    self.switchTo(details.communityId, details.channelId, details.messageId)
    
    # Notify qml about the changes, cause changing section cannot be performed 
    # completely from the nim side.
    self.notificationClicked(details.notificationType.int)

  proc showOSNotification*(self: ChatsView, title: string, message: string, 
    notificationType: int, communityId: string, channelId: string, 
    messageId: string, useOSNotifications: bool) {.slot.} =

    let details = OsNotificationDetails(
      notificationType: notificationType.OsNotificationType,
      communityId: communityId,
      channelId: channelId,
      messageId: messageId
    )
    
    self.appService.osNotificationService.showNotification(title, message, 
    details, useOSNotifications)

  proc handleProtocolUri*(self: ChatsView, uri: string) {.slot.} =
    # for now this only supports links to 1-1 chats, e.g.
    # status-im://p/0x04ecb3636368be823f9c62e2871f8ea5b52eb3fac0132bdcf9e57907a9cb1024d81927fb3ce12fea6d9b9a8f1acb24370df756108170ab0e3454ae93aa601f3c33
    # TODO: support other chat types
    let parts = uri.replace("status-im://", "").split("/")
    if parts.len == 2 and parts[0] == "p" and parts[1].startsWith("0x"):
      let pubKey = parts[1]
      self.status.chat.createOneToOneChat(pubKey)
      self.setActiveChannel(pubKey)
      return
    echo "Unsupported deep link structure: " & uri
