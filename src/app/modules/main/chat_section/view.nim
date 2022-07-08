import NimQml, json, sequtils
import model as chats_model
import item, sub_item, active_item
import ../../shared_models/user_model as user_model
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
      contactRequestsModel: user_model.Model
      contactRequestsModelVariant: QVariant
      listOfMyContacts: user_model.Model
      listOfMyContactsVariant: QVariant
      editCategoryChannelsModel: chats_model.Model
      editCategoryChannelsVariant: QVariant
      loadingHistoryMessagesInProgress: bool 
      
  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.activeItem.delete
    self.activeItemVariant.delete
    self.contactRequestsModel.delete
    self.contactRequestsModelVariant.delete
    self.listOfMyContacts.delete
    self.listOfMyContactsVariant.delete
    self.editCategoryChannelsModel.delete
    self.editCategoryChannelsVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = chats_model.newModel()
    result.modelVariant = newQVariant(result.model)
    result.editCategoryChannelsModel = chats_model.newModel()
    result.editCategoryChannelsVariant = newQVariant(result.editCategoryChannelsModel)
    result.activeItem = newActiveItem()
    result.activeItemVariant = newQVariant(result.activeItem)
    result.contactRequestsModel = user_model.newModel()
    result.contactRequestsModelVariant = newQVariant(result.contactRequestsModel)
    result.listOfMyContacts = user_model.newModel()
    result.listOfMyContactsVariant = newQVariant(result.listOfMyContacts)
    result.loadingHistoryMessagesInProgress = false

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc isCommunity(self: View): bool {.slot.} =
    return self.delegate.isCommunity()

  method getMySectionId*(self: View): string {.slot.} =
    return self.delegate.getMySectionId()

  proc chatsModel*(self: View): chats_model.Model =
    return self.model

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc editCategoryChannelsModel*(self: View): chats_model.Model =
    return self.editCategoryChannelsModel

  proc getEditCategoryChannels(self: View): QVariant {.slot.} =
    return self.editCategoryChannelsVariant

  QtProperty[QVariant] editCategoryChannelsModel:
    read = getEditCategoryChannels

  proc contactRequestsModel*(self: View): user_model.Model =
    return self.contactRequestsModel

  proc getContactRequestsModel(self: View): QVariant {.slot.} =
    return self.contactRequestsModelVariant
  QtProperty[QVariant] contactRequestsModel:
    read = getContactRequestsModel

  proc listOfMyContactsChanged*(self: View) {.signal.}

  proc populateMyContacts*(self: View, pubKeys: string) {.slot.} =
    self.delegate.initListOfMyContacts(pubKeys)
    self.listOfMyContactsChanged()

  proc clearMyContacts*(self: View) {.slot.} =
    self.delegate.clearListOfMyContacts()
    self.listOfMyContactsChanged()

  proc listOfMyContacts*(self: View): user_model.Model =
    return self.listOfMyContacts

  proc getListOfMyContacts(self: View): QVariant {.slot.} =
    return self.listOfMyContactsVariant
  QtProperty[QVariant] listOfMyContacts:
    read = getListOfMyContacts
    notify = listOfMyContactsChanged

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

  proc createOneToOneChat*(self: View, communityID: string, chatId: string, ensName: string) {.slot.} =
    self.delegate.createOneToOneChat(communityID, chatId, ensName)

  proc leaveChat*(self: View, id: string) {.slot.} =
    self.delegate.leaveChat(id)

  proc getItemAsJson*(self: View, itemId: string): string {.slot.} =
    let jsonObj = self.model.getItemOrSubItemByIdAsJson(itemId)
    return $jsonObj

  proc muteChat*(self: View, chatId: string) {.slot.} =
    self.delegate.muteChat(chatId)

  proc unmuteChat*(self: View, chatId: string) {.slot.} =
    self.delegate.unmuteChat(chatId)

  proc muteCategory*(self: View, categoryId: string) {.slot.} =
    self.delegate.muteCategory(categoryId)

  proc unmuteCategory*(self: View, categoryId: string) {.slot.} =
    self.delegate.unmuteCategory(categoryId)

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

  proc dismissContactRequest*(self: View, publicKey: string) {.slot.} =
    self.delegate.dismissContactRequest(publicKey)

  proc dismissAllContactRequests*(self: View) {.slot.} =
    self.delegate.dismissAllContactRequests()

  proc blockContact*(self: View, publicKey: string) {.slot.} =
    self.delegate.blockContact(publicKey)

  proc removeCommunityChat*(self: View, chatId: string) {.slot} =
    self.delegate.removeCommunityChat(chatId)

  proc addGroupMembers*(self: View, chatId: string, pubKeys: string) {.slot.} =
    self.delegate.addGroupMembers(chatId, pubKeys)

  proc removeMemberFromGroupChat*(self: View, communityID: string, chatId: string, pubKey: string) {.slot.} =
    self.delegate.removeMemberFromGroupChat(communityID, chatId, pubKey)

  proc removeMembersFromGroupChat*(self: View, communityID: string, chatId: string, pubKeys: string) {.slot.} =
    self.delegate.removeMembersFromGroupChat(communityID, chatId, pubKeys)

  proc renameGroupChat*(self: View, chatId: string, newName: string) {.slot.} =
    self.delegate.renameGroupChat(chatId, newName)

  proc makeAdmin*(self: View, communityID: string, chatId: string, pubKey: string) {.slot.} =
    self.delegate.makeAdmin(communityID, chatId, pubKey)

  proc createGroupChat*(self: View, communityID: string, groupName: string, pubKeys: string) {.slot.} =
    self.delegate.createGroupChat(communityID, groupName, pubKeys)

  proc joinGroupChatFromInvitation*(self: View, groupName: string, chatId: string, adminPK: string) {.slot.} =
    self.delegate.joinGroupChatFromInvitation(groupName, chatId, adminPK)

  proc acceptRequestToJoinCommunity*(self: View, requestId: string) {.slot.} =
    self.delegate.acceptRequestToJoinCommunity(requestId)

  proc declineRequestToJoinCommunity*(self: View, requestId: string) {.slot.} =
    self.delegate.declineRequestToJoinCommunity(requestId)

  proc createCommunityChannel*(
      self: View,
      name: string,
      description: string,
      emoji: string,
      color: string,
      categoryId: string
      ) {.slot.} =
    self.delegate.createCommunityChannel(name, description, emoji, color, categoryId)

  proc editCommunityChannel*(
      self: View,
      channelId: string,
      name: string,
      description: string,
      emoji: string,
      color: string,
      categoryId: string,
      position: int
    ) {.slot.} =
    self.delegate.editCommunityChannel(
      channelId,
      name,
      description,
      emoji,
      color,
      categoryId,
      position
    )

  proc leaveCommunity*(self: View) {.slot.} =
    self.delegate.leaveCommunity()
  
  proc removeUserFromCommunity*(self: View, pubKey: string) {.slot.} =
    self.delegate.removeUserFromCommunity(pubKey)

  proc banUserFromCommunity*(self: View, pubKey: string) {.slot.} =
    self.delegate.banUserFromCommunity(pubKey)

  proc editCommunity*(self: View, name: string, description: string, introMessage: string, outroMessage: string, access: int,
                      color: string, tags: string, logoJsonData: string, bannerJsonData: string, historyArchiveSupportEnabled: bool, 
                      pinMessageAllMembersEnabled: bool) {.slot.} =
    self.delegate.editCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                logoJsonData, bannerJsonData, historyArchiveSupportEnabled, pinMessageAllMembersEnabled)

  proc exportCommunity*(self: View): string {.slot.} =
    self.delegate.exportCommunity()

  proc setCommunityMuted*(self: View, muted: bool) {.slot.} =
    self.delegate.setCommunityMuted(muted)

  proc inviteUsersToCommunity*(self: View, pubKeysJSON: string): string {.slot.} =
    result = self.delegate.inviteUsersToCommunity(pubKeysJSON)

  proc createCommunityCategory*(self: View, name: string, channels: string) {.slot.} =
    let channelsSeq = map(parseJson(channels).getElems(), proc(x:JsonNode):string = x.getStr())
    self.delegate.createCommunityCategory(name, channelsSeq)

  proc editCommunityCategory*(self: View, categoryId: string, name: string, channels: string) {.slot.} =
    let channelsSeq = map(parseJson(channels).getElems(), proc(x:JsonNode):string = x.getStr())
    self.delegate.editCommunityCategory(categoryId, name, channelsSeq)

  proc deleteCommunityCategory*(self: View, categoryId: string) {.slot.} =
    self.delegate.deleteCommunityCategory(categoryId)

  proc prepareEditCategoryModel*(self: View, categoryId: string) {.slot.} =
    self.delegate.prepareEditCategoryModel(categoryId)

  proc reorderCommunityCategories*(self: View, categoryId: string, position: int) {.slot} =
    self.delegate.reorderCommunityCategories(categoryId, position)

  proc reorderCommunityChat*(self: View, categoryId: string, chatId: string, position: int): string {.slot} =
    self.delegate.reorderCommunityChat(categoryId, chatId, position)
    
  proc loadingHistoryMessagesInProgressChanged*(self: View) {.signal.}

  proc getLoadingHistoryMessagesInProgress*(self: View): bool {.slot.} =
    return self.loadingHistoryMessagesInProgress
  
  QtProperty[bool] loadingHistoryMessagesInProgress:
    read = getLoadingHistoryMessagesInProgress
    notify = loadingHistoryMessagesInProgressChanged

  proc setLoadingHistoryMessagesInProgress*(self: View, value: bool) = # this is not a slot
    if (value == self.loadingHistoryMessagesInProgress):
      return
    self.loadingHistoryMessagesInProgress = value
    self.loadingHistoryMessagesInProgressChanged()

  proc downloadMessages*(self: View, chatId: string, filePath: string) {.slot.} =
    self.delegate.downloadMessages(chatId, filePath)