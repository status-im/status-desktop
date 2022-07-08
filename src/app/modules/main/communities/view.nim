import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/active_section
import ./models/curated_community_item
import ./models/curated_community_model

QtObject:
  type
    View* = ref object of QObject
      communityTags: QVariant
      delegate: io_interface.AccessInterface
      model: SectionModel
      modelVariant: QVariant
      observedItem: ActiveSection
      curatedCommunitiesModel: CuratedCommunityModel
      curatedCommunitiesModelVariant: QVariant

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.observedItem.delete
    self.curatedCommunitiesModel.delete
    self.curatedCommunitiesModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.communityTags = newQVariant("")
    result.delegate = delegate
    result.model = newModel()
    result.modelVariant = newQVariant(result.model)
    result.curatedCommunitiesModel = newCuratedCommunityModel()
    result.curatedCommunitiesModelVariant = newQVariant(result.curatedCommunitiesModel)
    result.observedItem = newActiveSection()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc communityAdded*(self: View, communityId: string) {.signal.}
  proc communityChanged*(self: View, communityId: string) {.signal.}

  proc setCommunityTags*(self: View, communityTags: string) =
    self.communityTags = newQVariant(communityTags)

  proc addItem*(self: View, item: SectionItem) =
    self.model.addItem(item)
    self.communityAdded(item.id)

  proc model*(self: View): SectionModel =
    result = self.model

  proc getTags(self: View): QVariant {.slot.} =
    return self.communityTags

  QtProperty[QVariant] tags:
    read = getTags

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] model:
    read = getModel

  proc curatedCommunitiesModel*(self: View): CuratedCommunityModel =
    result = self.curatedCommunitiesModel

  proc getCuratedCommunitiesModel(self: View): QVariant {.slot.} =
    return self.curatedCommunitiesModelVariant

  QtProperty[QVariant] curatedCommunities:
    read = getCuratedCommunitiesModel

  proc observedItemChanged*(self:View) {.signal.}

  proc getObservedItem(self: View): QVariant {.slot.} =
    return newQVariant(self.observedItem)

  QtProperty[QVariant] observedCommunity:
    read = getObservedItem
    notify = observedItemChanged

  proc setObservedCommunity*(self: View, itemId: string) {.slot.} =
    let item = self.model.getItemById(itemId)
    if (item.id == ""):
      return
    self.observedItem.setActiveSectionData(item)
    self.observedItemChanged()

  proc joinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    # Users always have to request to join a community but might 
    # get automatically accepted.
    self.delegate.requestToJoinCommunity(communityId, ensName)

  proc createCommunity*(self: View, name: string,
                        description: string, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool) {.slot.} =
    self.delegate.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled)

  proc deleteCommunityCategory*(self: View, communityId: string, categoryId: string): string {.slot.} =
    self.delegate.deleteCommunityCategory(communityId, categoryId)

  proc reorderCommunityCategories*(self: View, communityId: string, categoryId: string, position: int) {.slot} =
    self.delegate.reorderCommunityCategories(communityId, categoryId, position)

  proc reorderCommunityChannel*(self: View, communityId: string, categoryId: string, chatId: string, position: int): string {.slot} =
    self.delegate.reorderCommunityChannel(communityId, categoryId, chatId, position)

  proc requestToJoinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    self.delegate.requestToJoinCommunity(communityId, ensName)

  proc requestCommunityInfo*(self: View, communityId: string) {.slot.} =
    self.delegate.requestCommunityInfo(communityId)

  proc isUserMemberOfCommunity*(self: View, communityId: string): bool {.slot.} =
    self.delegate.isUserMemberOfCommunity(communityId)

  proc userCanJoin*(self: View, communityId: string): bool {.slot.} =
    self.delegate.userCanJoin(communityId)

  proc isCommunityRequestPending*(self: View, communityId: string): bool {.slot.} =
    self.delegate.isCommunityRequestPending(communityId)

  proc deleteCommunityChat*(self: View, communityId: string, channelId: string) {.slot.} =
    self.delegate.deleteCommunityChat(communityId, channelId)

  proc importCommunity*(self: View, communityKey: string) {.slot.} =
    self.delegate.importCommunity(communityKey)

  proc importingCommunityStateChanged*(self:View, state: int, errorMsg: string) {.signal.}
  proc emitImportingCommunityStateChangedSignal*(self: View, state: int, errorMsg: string) =
    self.importingCommunityStateChanged(state, errorMsg)

  proc isMemberOfCommunity*(self: View, communityId: string, pubKey: string): bool {.slot.} =
    let sectionItem = self.model.getItemById(communityId)
    if (section_item.id == ""):
       return false
    return sectionItem.hasMember(pubKey)