import NimQml, json
import model as chats_model
import item, sub_item, active_item
import ../../shared_models/contacts_model as contacts_model
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: chats_model.Model
      modelVariant: QVariant
      activeItem: ActiveItem
      activeItemVariant: QVariant
      tmpChatId: string # shouldn't be used anywhere except in prepareChatContentModuleForChatId/getChatContentModule procs
      contactRequestsModel: contacts_model.Model
      contactRequestsModelVariant: QVariant
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.activeItem.delete
    self.activeItemVariant.delete
    self.contactRequestsModel.delete
    self.contactRequestsModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = chats_model.newModel()
    result.modelVariant = newQVariant(result.model)
    result.activeItem = newActiveItem()
    result.activeItemVariant = newQVariant(result.activeItem)
    result.contactRequestsModel = contacts_model.newModel()
    result.contactRequestsModelVariant = newQVariant(result.contactRequestsModel)      

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc isCommunity(self: View): bool {.slot.} =
    return self.delegate.isCommunity()

  proc chatsModel*(self: View): chats_model.Model =
    return self.model

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant
  QtProperty[QVariant] model:
    read = getModel

  proc contactRequestsModel*(self: View): contacts_model.Model =
    return self.contactRequestsModel

  proc getContactRequestsModel(self: View): QVariant {.slot.} =
    return self.contactRequestsModelVariant
  QtProperty[QVariant] contactRequestsModel:
    read = getContactRequestsModel

  proc activeItemChanged*(self:View) {.signal.}

  proc getActiveItem(self: View): QVariant {.slot.} =
    return self.activeItemVariant

  QtProperty[QVariant] activeItem:
    read = getActiveItem
    notify = activeItemChanged

  method activeItemSubItemSet*(self: View, item: Item, subItem: SubItem) =
    self.activeItem.setActiveItemData(item, subItem)
    self.activeItemChanged()

  proc setActiveItem*(self: View, itemId: string, subItemId: string = "") {.slot.} =
    self.delegate.setActiveItemSubItem(itemId, subItemId)

  # Since we cannot return QVariant from the proc which has arguments, so cannot have proc like this:
  # prepareChatContentModuleForChatId(self: View, chatId: string): QVariant {.slot.}
  # we're using combinaiton of 
  # prepareChatContentModuleForChatId/getChatContentModule procs
  proc prepareChatContentModuleForChatId*(self: View, chatId: string) {.slot.} =
    self.tmpChatId = chatId

  proc getChatContentModule*(self: View): QVariant {.slot.} =
    var chatContentVariant = self.delegate.getChatContentModule(self.tmpChatId)
    self.tmpChatId = ""
    if(chatContentVariant.isNil):
      return newQVariant()
    
    return chatContentVariant

  proc createPublicChat*(self: View, chatId: string) {.slot.} =
    self.delegate.createPublicChat(chatId)

  proc createOneToOneChat*(self: View, chatId: string, ensName: string) {.slot.} =
    self.delegate.createOneToOneChat(chatId, ensName)

  proc leaveChat*(self: View, id: string) {.slot.} =
    self.delegate.leaveChat(id)

  proc getItemAsJson*(self: View, itemId: string): string {.slot.} = 
    let jsonObj = self.model.getItemOrSubItemByIdAsJson(itemId)  
    return $jsonObj

  proc muteChat*(self: View, chatId: string) {.slot.} = 
    self.delegate.muteChat(chatId)

  proc unmuteChat*(self: View, chatId: string) {.slot.} = 
    self.delegate.unmuteChat(chatId)

  proc markAllMessagesRead*(self: View, chatId: string) {.slot.} = 
    self.delegate.markAllMessagesRead(chatId)

  proc clearChatHistory*(self: View, chatId: string) {.slot.} = 
    self.delegate.clearChatHistory(chatId)

  proc getCurrentFleet*(self: View): string {.slot.} =
    self.delegate.getCurrentFleet()

  proc acceptContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.acceptContactRequest(publicKey)

  proc acceptAllContactRequests*(self: View) {.slot.} =
    self.delegate.acceptAllContactRequests()
  
  proc rejectContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.rejectContactRequest(publicKey)

  proc rejectAllContactRequests*(self: View) {.slot.} =
    self.delegate.rejectAllContactRequests()

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc acceptRequestToJoinCommunity*(self: View, requestId: string) {.slot.} =
    self.delegate.acceptRequestToJoinCommunity(requestId)

  proc declineRequestToJoinCommunity*(self: View, requestId: string) {.slot.} =
    self.delegate.declineRequestToJoinCommunity(requestId)

  proc createCommunityChannel*(self: View, name: string, description: string) {.slot.} =
    self.delegate.createCommunityChannel(name, description)

  proc leaveCommunity*(self: View) {.slot.} =
    self.delegate.leaveCommunity()

  proc editCommunity*(self: View, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int) {.slot.} =
    self.delegate.editCommunity(name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)

  proc exportCommunity*(self: View): string {.slot.} =
    self.delegate.exportCommunity()

  proc setCommunityMuted*(self: View, muted: bool) {.slot.} =
    self.delegate.setCommunityMuted(muted)

  proc inviteUsersToCommunity*(self: View, pubKeysJSON: string): string {.slot.} =
    result = self.delegate.inviteUsersToCommunity(pubKeysJSON)