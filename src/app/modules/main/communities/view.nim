import NimQml, json, strutils, json_serialization, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/active_section
import ./models/curated_community_model
import ./models/curated_community_item
import ./models/discord_file_list_model
import ./models/discord_file_item
import ./models/discord_categories_model
import ./models/discord_category_item
import ./models/discord_channels_model
import ./models/discord_channel_item

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
      discordFileListModel: DiscordFileListModel
      discordFileListModelVariant: QVariant
      discordCategoriesModel: DiscordCategoriesModel
      discordCategoriesModelVariant: QVariant
      discordChannelsModel: DiscordChannelsModel
      discordChannelsModelVariant: QVariant
      discordOldestMessageTimestamp: int
      discordImportErrorsCount: int
      discordImportWarningsCount: int
      discordDataExtractionInProgress: bool

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.observedItem.delete
    self.curatedCommunitiesModel.delete
    self.curatedCommunitiesModelVariant.delete
    self.discordFileListModel.delete
    self.discordFileListModelVariant.delete
    self.discordCategoriesModel.delete
    self.discordCategoriesModelVariant.delete
    self.discordChannelsModel.delete
    self.discordChannelsModelVariant.delete
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
    result.discordFileListModel = newDiscordFileListModel()
    result.discordFileListModelVariant = newQVariant(result.discordFileListModel)
    result.discordCategoriesModel = newDiscordCategoriesModel()
    result.discordCategoriesModelVariant = newQVariant(result.discordCategoriesModel)
    result.discordChannelsModel = newDiscordChannelsModel()
    result.discordChannelsModelVariant = newQVariant(result.discordChannelsModel)
    result.discordOldestMessageTimestamp = 0
    result.discordDataExtractionInProgress = false 
    result.discordImportWarningsCount = 0
    result.discordImportErrorsCount = 0
    result.observedItem = newActiveSection()

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc communityAdded*(self: View, communityId: string) {.signal.}
  proc communityChanged*(self: View, communityId: string) {.signal.}
  proc discordOldestMessageTimestampChanged*(self: View) {.signal.}
  proc discordImportErrorsCountChanged*(self: View) {.signal.}
  proc communityAccessRequested*(self: View, communityId: string) {.signal.}

  proc setCommunityTags*(self: View, communityTags: string) =
    self.communityTags = newQVariant(communityTags)

  proc setDiscordOldestMessageTimestamp*(self: View, timestamp: int) {.slot.} =
    if (self.discordOldestMessageTimestamp == timestamp): return
    self.discordOldestMessageTimestamp = timestamp
    self.discordOldestMessageTimestampChanged()

  proc getDiscordOldestMessageTimestamp*(self: View): int {.slot.} =
    return self.discordOldestMessageTimestamp

  QtProperty[int] discordOldestMessageTimestamp:
    read = getDiscordOldestMessageTimestamp
    notify = discordOldestMessageTimestampChanged

  proc discordImportWarningsCountChanged*(self: View) {.signal.}

  proc setDiscordImportWarningsCount*(self: View, count: int) {.slot.} =
    if (self.discordImportWarningsCount == count): return
    self.discordImportWarningsCount = count
    self.discordImportWarningsCountChanged()

  proc getDiscordImportWarningsCount*(self: View): int {.slot.} =
    return self.discordImportWarningsCount

  QtProperty[int] discordImportWarningsCount:
    read = getDiscordImportWarningsCount
    notify = discordImportWarningsCountChanged

  proc setDiscordImportErrorsCount*(self: View, count: int) {.slot.} =
    if (self.discordImportErrorsCount == count): return
    self.discordImportErrorsCount = count
    self.discordImportErrorsCountChanged()

  proc getDiscordImportErrorsCount*(self: View): int {.slot.} =
    return self.discordImportErrorsCount

  QtProperty[int] discordImportErrorsCount:
    read = getDiscordImportErrorsCount
    notify = discordImportErrorsCountChanged

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

  proc discordFileListModel*(self: View): DiscordFileListModel =
    result = self.discordFileListModel

  proc getDiscordFileListModel(self: View): QVariant{.slot.} =
    return self.discordFileListModelVariant

  QtProperty[QVariant] discordFileList:
    read = getDiscordFileListModel

  proc discordCategoriesModel*(self: View): DiscordCategoriesModel =
    result = self.discordCategoriesModel

  proc getDiscordCategoriesModel*(self: View): QVariant {.slot.} =
    return self.discordCategoriesModelVariant

  QtProperty[QVariant] discordCategories:
    read = getDiscordCategoriesModel

  proc discordChannelsModel*(self: View): DiscordChannelsModel =
    result = self.discordChannelsModel

  proc getDiscordChannelsModel*(self: View): QVariant {.slot.} =
    return self.discordChannelsModelVariant

  QtProperty[QVariant] discordChannels:
    read = getDiscordChannelsModel

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

  proc discordDataExtractionInProgressChanged*(self: View) {.signal.}

  proc getDiscordDataExtractionInProgress(self: View): bool {.slot.} =
    return self.discordDataExtractionInProgress

  proc setDiscordDataExtractionInProgress*(self: View, inProgress: bool) {.slot.} =
    if (self.discordDataExtractionInProgress == inProgress): return
    self.discordDataExtractionInProgress = inProgress
    self.discordDataExtractionInProgressChanged()

  QtProperty[bool] discordDataExtractionInProgress:
    read = getDiscordDataExtractionInProgress
    notify = discordDataExtractionInProgressChanged

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
                        pinMessageAllMembersEnabled: bool, bannerJsonStr: string) {.slot.} =
    self.delegate.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled, bannerJsonStr)

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

  proc setFileListItems*(self: View, filePaths: string) {.slot.} =
    let filePaths = filePaths.split(',')
    var fileItems: seq[DiscordFileItem] = @[]

    for filePath in filePaths:
      var fileItem = DiscordFileItem()
      fileItem.filePath = filePath
      fileItem.errorMessage = ""
      fileItem.errorCode = 0
      fileItem.selected = true
      fileItem.validated = false
      fileItems.add(fileItem)
    self.discordFileListModel.setItems(fileItems)
    self.setDiscordImportErrorsCount(0)
    self.setDiscordImportWarningsCount(0)

  proc clearFileList*(self: View) {.slot.} =
    self.discordFileListModel.clearItems()
    self.setDiscordImportErrorsCount(0)
    self.setDiscordImportWarningsCount(0)

  proc requestExtractDiscordChannelsAndCategories*(self: View) {.slot.} =
    let filePaths = self.discordFileListModel.getSelectedFilePaths()
    self.delegate.requestExtractDiscordChannelsAndCategories(filePaths)

  proc toggleDiscordCategory*(self: View, id: string, selected: bool) {.slot.} =
    if selected:
      self.discordCategoriesModel.selectItem(id)
      self.discordChannelsModel.selectItemsByCategoryId(id)
    else:
      self.discordCategoriesModel.unselectItem(id)
      self.discordChannelsModel.unselectItemsByCategoryId(id)

  proc toggleDiscordChannel*(self: View, id: string, selected: bool) {.slot.} =
    if selected:
      self.discordChannelsModel.selectItem(id)
      let item = self.discordChannelsModel.getItem(id)
      self.discordCategoriesModel.selectItem(item.getCategoryId())
    else:
      self.discordChannelsModel.unselectItem(id)
      let item = self.discordChannelsModel.getItem(id)
      if self.discordChannelsModel.allChannelsByCategoryUnselected(item.getCategoryId()):
        self.discordCategoriesModel.unselectItem(item.getCategoryId())

  proc clearDiscordCategoriesAndChannels*(self: View) {.slot.} =
    self.discordCategoriesModel.clearItems()
    self.discordChannelsModel.clearItems()
