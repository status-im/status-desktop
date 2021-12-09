import NimQml
import ../../../shared_models/message_model as pinned_msg_model
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

  proc load*(self: View, id: string, `type`: int, belongsToCommunity, isUsersListAvailable: bool, name, icon: string, 
    isIdenticon: bool, color, description: string, hasUnreadMessages: bool, notificationsCount: int, muted: bool) =
    self.chatDetails.setChatDetails(id, `type`, belongsToCommunity, isUsersListAvailable, name, icon, isIdenticon, 
    color, description, hasUnreadMessages, notificationsCount, muted)
    self.delegate.viewDidLoad()

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

  proc unmuteChat*(self: View) {.slot.} = 
    self.delegate.unmuteChat()

  proc setMuted*(self: View, muted: bool) = 
    self.chatDetails.setMuted(muted)

  proc getChatDetails(self: View): QVariant {.slot.} =
    return self.chatDetailsVariant
  QtProperty[QVariant] chatDetails:
    read = getChatDetails
