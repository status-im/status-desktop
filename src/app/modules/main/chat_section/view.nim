import NimQml, json
import model, item, sub_item, active_item
import io_interface

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: Model
      modelVariant: QVariant
      activeItem: ActiveItem
      activeItemVariant: QVariant
      tmpChatId: string # shouldn't be used anywhere except in prepareChatContentModuleForChatId/getChatContentModule procs
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.activeItem.delete
    self.activeItemVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.activeItem = newActiveItem()
    result.activeItemVariant = newQVariant(result.activeItem)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc isCommunity(self: View): bool {.slot.} =
    return self.delegate.isCommunity()

  proc model*(self: View): Model =
    return self.model

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel
    notify = modelChanged

  proc appendItem*(self: View, item: Item) =
    self.model.appendItem(item)

  proc removeItem*(self: View, id: string) =
    self.model.removeItemById(id)

  proc prependItem*(self: View, item: Item) =
    self.model.prependItem(item)

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