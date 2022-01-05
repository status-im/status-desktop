import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/active_section

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: SectionModel
      modelVariant: QVariant
      observedItem: ActiveSection
      observedItemVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.observedItem.delete
    self.observedItemVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.observedItem = newActiveSection()
    result.observedItemVariant = newQVariant(result.observedItem)

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc addItem*(self: View, item: SectionItem) =
    self.model.addItem(item)

  proc getModel(self: View): QVariant {.slot.} =
    return newQVariant(self.modelVariant)

  QtProperty[QVariant] model:
    read = getModel

  proc observedItemChanged*(self:View) {.signal.}

  proc getObservedItem(self: View): QVariant {.slot.} =
    return self.observedItemVariant

  QtProperty[QVariant] observedCommunity:
    read = getObservedItem
    notify = observedItemChanged
    
  proc setObservedCommunity*(self: View, itemId: string) {.slot.} =
    let item = self.model.getItemById(itemId)
    if (item.id == ""):
      return
    self.observedItem.setActiveSectionData(item)
    
  proc joinCommunity*(self: View, communityId: string): string {.slot.} =
    result = self.delegate.joinCommunity(communityId)
  
  proc communityAdded*(self: View, communityId: string) {.signal.}
  proc communityChanged*(self: View, communityId: string) {.signal.}

  proc createCommunity*(self: View, name: string, description: string, 
                        access: int, ensOnly: bool, color: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int) {.slot.} =
    self.delegate.createCommunity(name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)
  
  proc editCommunity*(self: View, id: string, name: string, description: string, access: int, ensOnly: bool, color: string, imagePath: string, aX: int, aY: int, bX: int, bY: int) {.slot.} =
    self.delegate.editCommunity(id, name, description, access, ensOnly, color, imagePath, aX, aY, bX, bY)
  
  proc createCommunityChannel*(self: View, communityId: string, name: string, description: string) {.slot.} =
    self.delegate.createCommunityChannel(communityId, name, description)
  
  proc createCommunityCategory*(self: View, communityId: string, name: string, channels: string) {.slot.} =
    self.delegate.createCommunityCategory(communityId, name, channels)

  proc editCommunityCategory*(self: View, communityId: string, categoryId: string, name: string, channels: string) {.slot.} =
    self.delegate.editCommunityCategory(communityId, categoryId, name, channels)

  proc deleteCommunityCategory*(self: View, communityId: string, categoryId: string): string {.slot.} =
    self.delegate.deleteCommunityCategory(communityId, categoryId)

  proc reorderCommunityCategories*(self: View, communityId: string, categoryId: string, position: int) {.slot} =
    self.delegate.reorderCommunityCategories(communityId, categoryId, position)
  
  proc reorderCommunityChannel*(self: View, communityId: string, categoryId: string, chatId: string, position: int): string {.slot} =
    self.delegate.reorderCommunityChannel(communityId, categoryId, chatId, position)

  proc leaveCommunity*(self: View, communityId: string) {.slot.} =
    self.delegate.leaveCommunity(communityId)

  proc inviteUsersToCommunityById*(self: View, communityId: string, pubKeysJSON: string) {.slot.} =
    self.delegate.inviteUsersToCommunityById(communityId, pubKeysJSON)

  proc inviteUsersToCommunity*(self: View, communityId: string, pubKeysJSON: string) {.slot.} =
    self.inviteUsersToCommunityById(communityId, pubKeysJSON)
  
  proc removeUserFromCommunity*(self: View, communityId: string, pubKey: string) {.slot.} =
    self.delegate.removeUserFromCommunity(communityId, pubKey)

  proc banUserFromCommunity*(self: View, pubKey: string, communityId: string) {.slot.} =
    self.delegate.banUserFromCommunity(communityId, pubKey)

  proc requestToJoinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    self.delegate.requestToJoinCommunity(communityId, ensName)
   
  proc acceptRequestToJoinCommunity*(self: View, communityId: string, requestId: string) {.slot.} =
    self.delegate.acceptRequestToJoinCommunity(communityId, requestid)

  proc declineRequestToJoinCommunity*(self: View, communityId: string, requestId: string) {.slot.} =
    self.delegate.declineRequestToJoinCommunity(communityId, requestId)

  proc requestCommunityInfo*(self: View, communityId: string) {.slot.} =
    self.delegate.requestCommunityInfo(communityId)

  proc deleteCommunityChat*(self: View, communityId: string, channelId: string) {.slot.} =
    self.delegate.deleteCommunityChat(communityId, channelId)

  proc setCommunityMuted*(self: View, communityId: string, muted: bool) {.slot.} =
    self.delegate.setCommunityMuted(communityId, muted)

  # proc markNotificationsAsRead*(self: View, markAsReadProps: MarkAsReadNotificationProperties) =
  #   # todo
  #   discard

  proc importCommunity*(self: View, communityKey: string) {.slot.} =
    self.delegate.importCommunity(communityKey)

  proc exportCommunity*(self: View, communityId: string): string {.slot.} =
    self.delegate.exportCommunity(communityId)

  