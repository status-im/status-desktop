import NimQml
import ../../../shared_models/message_model as pinned_msg_model
import ../../../../../app_service/service/chat/dto/chat as chat_dto

import io_interface
import chat_details

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      pinnedMessagesModel: pinned_msg_model.Model
      pinnedMessagesModelVariant: QVariant
      chatDetails: ChatDetails
      chatDetailsVariant: QVariant
      viewOnlyPermissionsSatisfied: bool
      viewAndPostPermissionsSatisfied: bool

  proc chatDetailsChanged*(self:View) {.signal.}

  proc delete*(self: View) =
    self.pinnedMessagesModel.delete
    self.pinnedMessagesModelVariant.delete
    self.chatDetails.delete
    self.chatDetailsVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.pinnedMessagesModel = pinned_msg_model.newModel()
    result.pinnedMessagesModelVariant = newQVariant(result.pinnedMessagesModel)
    result.chatDetails = newChatDetails()
    result.chatDetailsVariant = newQVariant(result.chatDetails)
    result.viewOnlyPermissionsSatisfied = false
    result.viewAndPostPermissionsSatisfied = false

  proc load*(self: View, id: string, `type`: int, belongsToCommunity, isUsersListAvailable: bool,
      name, icon: string, color, description, emoji: string, hasUnreadMessages: bool,
      notificationsCount: int, muted: bool, position: int, isUntrustworthy: bool,
      isContact: bool, blocked: bool) =
    self.chatDetails.setChatDetails(id, `type`, belongsToCommunity, isUsersListAvailable, name,
      icon, color, description, emoji, hasUnreadMessages, notificationsCount, muted, position,
      isUntrustworthy, isContact, blocked)
    self.delegate.viewDidLoad()
    self.chatDetailsChanged()

  proc pinnedModel*(self: View): pinned_msg_model.Model =
    return self.pinnedMessagesModel

  proc getInputAreaModule(self: View): QVariant {.slot.} =
    return self.delegate.getInputAreaModule()
  QtProperty[QVariant] inputAreaModule:
    read = getInputAreaModule

  proc getMessagesModule(self: View): QVariant {.slot.} =
    return self.delegate.getMessagesModule()
  QtProperty[QVariant] messagesModule:
    read = getMessagesModule

  proc getUsersModule(self: View): QVariant {.slot.} =
    return self.delegate.getUsersModule()
  QtProperty[QVariant] usersModule:
    read = getUsersModule

  proc getPinnedMessagesModel(self: View): QVariant {.slot.} =
    return self.pinnedMessagesModelVariant
  QtProperty[QVariant] pinnedMessagesModel:
    read = getPinnedMessagesModel

  proc unpinMessage*(self: View, messageId: string) {.slot.} =
    self.delegate.unpinMessage(messageId)

  proc getMyChatId*(self: View): string {.slot.} =
    return self.delegate.getMyChatId()

  proc isMyContact*(self: View, contactId: string): bool {.slot.} =
    return self.delegate.isMyContact(contactId)

  proc muteChat*(self: View, interval: int) {.slot.} =
    self.delegate.muteChat(interval)

  proc unmuteChat*(self: View) {.slot.} =
    self.delegate.unmuteChat()

  proc unblockChat*(self: View): string {.slot.} =
    self.delegate.unblockChat()

  proc markAllMessagesRead*(self: View) {.slot.} =
    self.delegate.markAllMessagesRead()

  proc markMessageRead*(self: View, msgID: string) {.slot.} =
    self.delegate.markMessageRead(msgID)

  proc clearChatHistory*(self: View) {.slot.} =
    self.delegate.clearChatHistory()

  proc leaveChat*(self: View) {.slot.} =
    self.delegate.leaveChat()

  proc setMuted*(self: View, muted: bool) =
    self.chatDetails.setMuted(muted)

  proc setActive*(self: View) =
    self.chatDetails.setActive(true)

  proc setInactive*(self: View) =
    self.chatDetails.setActive(false)

  proc updateChatDetailsNameAndIcon*(self: View, name, icon: string) =
    self.chatDetails.setName(name)
    self.chatDetails.setIcon(icon)

  proc updateChatDetailsNameColorIcon*(self: View, name, color, icon: string) =
    self.updateChatDetailsNameAndIcon(name, icon)
    self.chatDetails.setColor(color)

  proc updateTrustStatus*(self: View, isUntrustworthy: bool) =
    self.chatDetails.setIsUntrustworthy(isUntrustworthy)

  proc updateChatDetailsNotifications*(self: View, hasUnreadMessages: bool, notificationCount: int) =
    self.chatDetails.setHasUnreadMessages(hasUnreadMessages)
    self.chatDetails.setNotificationCount(notificationCount)

  proc getChatDetails(self: View): QVariant {.slot.} =
    return self.chatDetailsVariant
  QtProperty[QVariant] chatDetails:
    read = getChatDetails
    notify = chatDetailsChanged

  proc getCurrentFleet*(self: View): string {.slot.} =
    self.delegate.getCurrentFleet()

  proc amIChatAdmin*(self: View): bool {.slot.} =
    return self.delegate.amIChatAdmin()

  proc updateChatDetails*(self: View, chatDto: ChatDto) =
    if chatDto.chatType != ChatType.OneToOne:
      self.chatDetails.setName(chatDto.name)
      self.chatDetails.setIcon(chatDto.icon)
    self.chatDetails.setDescription(chatDto.description)
    self.chatDetails.setEmoji(chatDto.emoji)
    self.chatDetails.setColor(chatDto.color)

  proc updateChatDetailsName*(self: View, name: string) =
    self.chatDetails.setName(name)

  proc onMutualContactChanged*(self: View, value: bool) =
    self.chatDetails.setIsMutualContact(value)

  proc downloadMessages*(self: View, filePath: string) {.slot.} =
    self.delegate.downloadMessages(filePath)

  proc updateChatBlocked*(self: View, blocked: bool) =
    self.chatDetails.setBlocked(blocked)

  proc viewOnlyPermissionsSatisfiedChanged(self: View) {.signal.}

  proc setViewOnlyPermissionsSatisfied*(self: View, value: bool) =
    self.viewOnlyPermissionsSatisfied = value
    self.viewOnlyPermissionsSatisfiedChanged()

  proc getViewOnlyPermissionsSatisfied*(self: View): bool {.slot.} =
    return self.viewOnlyPermissionsSatisfied
  QtProperty[bool] viewOnlyPermissionsSatisfied:
    read = getViewOnlyPermissionsSatisfied
    notify = viewOnlyPermissionsSatisfiedChanged

  proc viewAndPostPermissionsSatisfiedChanged(self: View) {.signal.}

  proc setViewAndPostPermissionsSatisfied*(self: View, value: bool) =
    self.viewAndPostPermissionsSatisfied = value
    self.viewAndPostPermissionsSatisfiedChanged()

  proc getViewAndPostPermissionsSatisfied*(self: View): bool {.slot.} =
    return self.viewAndPostPermissionsSatisfied
  QtProperty[bool] viewAndPostPermissionsSatisfied:
    read = getViewAndPostPermissionsSatisfied
    notify = viewAndPostPermissionsSatisfiedChanged

