import NimQml, json, strutils, sequtils

import ./io_interface
import ../../shared_models/section_model
import ../../shared_models/section_item
import ../../shared_models/section_details
import ./models/curated_community_model
import ./models/discord_file_list_model
import ./models/discord_file_item
import ./models/discord_categories_model
import ./models/discord_channels_model
import ./models/discord_channel_item
import ./models/discord_import_tasks_model

QtObject:
  type
    View* = ref object of QObject
      communityTags: QVariant
      delegate: io_interface.AccessInterface
      model: SectionModel
      modelVariant: QVariant
      observedItem: SectionDetails
      curatedCommunitiesModel: CuratedCommunityModel
      curatedCommunitiesModelVariant: QVariant
      curatedCommunitiesLoading: bool
      discordFileListModel: DiscordFileListModel
      discordFileListModelVariant: QVariant
      discordCategoriesModel: DiscordCategoriesModel
      discordCategoriesModelVariant: QVariant
      discordChannelsModel: DiscordChannelsModel
      discordChannelsModelVariant: QVariant
      discordOldestMessageTimestamp: int
      discordImportErrorsCount: int
      discordImportWarningsCount: int
      discordImportProgress: int
      discordImportInProgress: bool
      discordImportCancelled: bool
      discordImportProgressStopped: bool
      discordImportProgressTotalChunksCount: int
      discordImportProgressCurrentChunk: int
      discordImportTasksModel: DiscordImportTasksModel
      discordImportTasksModelVariant: QVariant
      discordDataExtractionInProgress: bool
      discordImportCommunityId: string
      discordImportCommunityName: string
      discordImportCommunityImage: string
      discordImportHasCommunityImage: bool
      downloadingCommunityHistoryArchives: bool

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
    self.discordImportTasksModel.delete
    self.discordImportTasksModelVariant.delete
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
    result.curatedCommunitiesLoading = false
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
    result.discordImportProgress = 0
    result.discordImportInProgress = false
    result.discordImportCancelled = false
    result.discordImportProgressStopped = false
    result.discordImportHasCommunityImage = false
    result.discordImportTasksModel = newDiscordDiscordImportTasksModel()
    result.discordImportTasksModelVariant = newQVariant(result.discordImportTasksModel)
    result.observedItem = newActiveSection()
    result.downloadingCommunityHistoryArchives = false

  proc load*(self: View) =
    self.delegate.viewDidLoad()

  proc communityAdded*(self: View, communityId: string) {.signal.}
  proc communityChanged*(self: View, communityId: string) {.signal.}
  proc discordOldestMessageTimestampChanged*(self: View) {.signal.}
  proc discordImportErrorsCountChanged*(self: View) {.signal.}
  proc communityAccessRequested*(self: View, communityId: string) {.signal.}
  proc communityInfoAlreadyRequested*(self: View) {.signal.}

  proc communityTagsChanged*(self: View) {.signal.}
  
  proc setCommunityTags*(self: View, communityTags: string) =
    self.communityTags = newQVariant(communityTags)
    self.communityTagsChanged()

  proc setDiscordOldestMessageTimestamp*(self: View, timestamp: int) {.slot.} =
    if (self.discordOldestMessageTimestamp == timestamp): return
    self.discordOldestMessageTimestamp = timestamp
    self.discordOldestMessageTimestampChanged()

  proc getDiscordOldestMessageTimestamp*(self: View): int {.slot.} =
    return self.discordOldestMessageTimestamp

  QtProperty[int] discordOldestMessageTimestamp:
    read = getDiscordOldestMessageTimestamp
    notify = discordOldestMessageTimestampChanged

  proc downloadingCommunityHistoryArchivesChanged*(self: View) {.signal.}

  proc setDownloadingCommunityHistoryArchives*(self: View, flag: bool) {.slot.} =
    if (self.downloadingCommunityHistoryArchives == flag): return
    self.downloadingCommunityHistoryArchives = flag
    self.downloadingCommunityHistoryArchivesChanged()

  proc getDownloadingCommunityHistoryArchives*(self: View): bool {.slot.} =
    return self.downloadingCommunityHistoryArchives

  QtProperty[bool] downloadingCommunityHistoryArchives:
    read = getDownloadingCommunityHistoryArchives
    notify = downloadingCommunityHistoryArchivesChanged

  proc discordImportHasCommunityImageChanged*(self: View) {.signal.}

  proc setDiscordImportHasCommunityImage*(self: View, hasImage: bool) {.slot.} =
    if (self.discordImportHasCommunityImage == hasImage): return
    self.discordImportHasCommunityImage = hasImage
    self.discordImportHasCommunityImageChanged()

  proc getDiscordImportHasCommunityImage*(self: View): bool {.slot.} =
    return self.discordImportHasCommunityImage

  QtProperty[bool] discordImportHasCommunityImage:
    read = getDiscordImportHasCommunityImage
    notify = discordImportHasCommunityImageChanged

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

  proc discordImportProgressChanged*(self: View) {.signal.}

  proc setDiscordImportProgress*(self: View, value: int) {.slot.} =
    if (self.discordImportProgress == value): return
    self.discordImportProgress = value
    self.discordImportProgressChanged()

  proc getDiscordImportProgress*(self: View): int {.slot.} =
    return self.discordImportProgress

  QtProperty[int] discordImportProgress:
    read = getDiscordImportProgress
    notify = discordImportProgressChanged

  proc discordImportInProgressChanged*(self: View) {.signal.}

  proc setDiscordImportInProgress*(self: View, value: bool) {.slot.} =
    if (self.discordImportInProgress == value): return
    self.discordImportInProgress = value
    self.discordImportInProgressChanged()

  proc getDiscordImportInProgress*(self: View): bool {.slot.} =
    return self.discordImportInProgress

  QtProperty[bool] discordImportInProgress:
    read = getDiscordImportInProgress
    notify = discordImportInProgressChanged

  proc discordImportCancelledChanged*(self: View) {.signal.}

  proc setDiscordImportCancelled*(self: View, value: bool) {.slot.} =
    if (self.discordImportCancelled == value): return
    self.discordImportCancelled = value
    self.discordImportCancelledChanged()

  proc getDiscordImportCancelled*(self: View): bool {.slot.} =
    return self.discordImportCancelled

  QtProperty[bool] discordImportCancelled:
    read = getDiscordImportCancelled
    notify = discordImportCancelledChanged

  proc discordImportProgressStoppedChanged*(self: View) {.signal.}

  proc setDiscordImportProgressStopped*(self: View, stopped: bool) {.slot.} =
    if (self.discordImportProgressStopped == stopped): return
    self.discordImportProgressStopped = stopped
    self.discordImportProgressStoppedChanged()

  proc getDiscordImportProgressStopped*(self: View): bool {.slot.} =
    return self.discordImportProgressStopped

  QtProperty[int] discordImportProgressStopped:
    read = getDiscordImportProgressStopped
    notify = discordImportProgressStoppedChanged

  proc discordImportProgressTotalChunksCountChanged*(self: View) {.signal.}

  proc setDiscordImportProgressTotalChunksCount*(self: View, count: int) {.slot.} =
    if (self.discordImportProgressTotalChunksCount == count): return
    self.discordImportProgressTotalChunksCount = count
    self.discordImportProgressTotalChunksCountChanged()

  proc getDiscordImportProgressTotalChunksCount*(self: View): int {.slot.} =
    return self.discordImportProgressTotalChunksCount

  QtProperty[int] discordImportProgressTotalChunksCount:
    read = getDiscordImportProgressTotalChunksCount
    notify = discordImportProgressTotalChunksCountChanged

  proc discordImportProgressCurrentChunkChanged*(self: View) {.signal.}

  proc setDiscordImportProgressCurrentChunk*(self: View, count: int) {.slot.} =
    if (self.discordImportProgressCurrentChunk == count): return
    self.discordImportProgressCurrentChunk = count
    self.discordImportProgressCurrentChunkChanged()

  proc getDiscordImportProgressCurrentChunk*(self: View): int {.slot.} =
    return self.discordImportProgressCurrentChunk

  QtProperty[int] discordImportProgressCurrentChunk:
    read = getDiscordImportProgressCurrentChunk
    notify = discordImportProgressCurrentChunkChanged

  proc addItem*(self: View, item: SectionItem) =
    self.model.addItem(item)
    self.communityAdded(item.id)

  proc model*(self: View): SectionModel =
    result = self.model

  proc getTags(self: View): QVariant {.slot.} =
    return self.communityTags

  QtProperty[QVariant] tags:
    read = getTags
    notify = communityTagsChanged

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

  proc curatedCommunitiesLoadingChanged*(self: View) {.signal.}

  proc setCuratedCommunitiesLoading*(self: View, flag: bool) =
    if (self.curatedCommunitiesLoading == flag): return
    self.curatedCommunitiesLoading = flag
    self.curatedCommunitiesLoadingChanged()

  proc getCuratedCommunitiesLoading*(self: View): bool {.slot.} =
    return self.curatedCommunitiesLoading

  QtProperty[bool] curatedCommunitiesLoading:
    read = getCuratedCommunitiesLoading
    notify = curatedCommunitiesLoadingChanged

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

  proc discordImportTasksModel*(self: View): DiscordImportTasksModel =
    result = self.discordImportTasksModel

  proc getDiscordImportTasksModel(self: View): QVariant {.slot.} =
    return self.discordImportTasksModelVariant

  QtProperty[QVariant] discordImportTasks:
    read = getDiscordImportTasksModel

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

  proc discordImportCommunityIdChanged*(self: View) {.signal.}

  proc getDiscordImportCommunityId(self: View): string {.slot.} =
    return self.discordImportCommunityId

  proc setDiscordImportCommunityId*(self: View, id: string) {.slot.} =
    if (self.discordImportCommunityId == id): return
    self.discordImportCommunityId = id
    self.discordImportCommunityIdChanged()

  QtProperty[string] discordImportCommunityId:
    read = getDiscordImportCommunityId
    notify = discordImportCommunityIdChanged

  proc discordImportCommunityImageChanged*(self: View) {.signal.}

  proc getDiscordImportCommunityImage(self: View): string {.slot.} =
    return self.discordImportCommunityImage

  proc setDiscordImportCommunityImage*(self: View, image: string) {.slot.} =
    if (self.discordImportCommunityImage == image): return
    self.discordImportCommunityImage = image
    self.discordImportCommunityImageChanged()

  QtProperty[string] discordImportCommunityImage:
    read = getDiscordImportCommunityImage
    notify = discordImportCommunityImageChanged

  proc discordImportCommunityNameChanged*(self: View) {.signal.}

  proc getDiscordImportCommunityName(self: View): string {.slot.} =
    return self.discordImportCommunityName

  proc setDiscordImportCommunityName*(self: View, name: string) {.slot.} =
    if (self.discordImportCommunityName == name): return
    self.discordImportCommunityName = name
    self.discordImportCommunityNameChanged()

  QtProperty[string] discordImportCommunityName:
    read = getDiscordImportCommunityName
    notify = discordImportCommunityNameChanged

  proc navigateToCommunity*(self: View, communityId: string) {.slot.} =
    self.delegate.navigateToCommunity(communityId)

  proc spectateCommunity*(self: View, communityId: string) {.slot.} =
    discard self.delegate.spectateCommunity(communityId)

  proc createCommunity*(self: View, name: string,
                        description: string, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool, bannerJsonStr: string) {.slot.} =
    self.delegate.createCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled, 
                                  bannerJsonStr)

  proc clearFileList*(self: View) {.slot.} =
    self.discordFileListModel.clearItems()
    self.setDiscordImportErrorsCount(0)
    self.setDiscordImportWarningsCount(0)

  proc clearDiscordCategoriesAndChannels*(self: View) {.slot.} =
    self.discordCategoriesModel.clearItems()
    self.discordChannelsModel.clearItems()

  proc resetDiscordImport*(self: View, cancelled: bool) {.slot.} =
    self.clearFileList()
    self.clearDiscordCategoriesAndChannels()
    self.discordImportTasksModel.clearItems()
    self.setDiscordImportProgress(0)
    self.setDiscordImportProgressStopped(false)
    self.setDiscordImportErrorsCount(0)
    self.setDiscordImportWarningsCount(0)
    self.setDiscordImportCommunityId("")
    self.setDiscordImportCommunityName("")
    self.setDiscordImportCommunityImage("")
    self.setDiscordImportHasCommunityImage(false)
    self.setDiscordImportInProgress(false)
    self.setDiscordImportCancelled(cancelled)


  proc requestImportDiscordCommunity*(self: View, name: string,
                        description: string, introMessage: string, outroMessage: string,
                        access: int, color: string, tags: string,
                        imagePath: string,
                        aX: int, aY: int, bX: int, bY: int,
                        historyArchiveSupportEnabled: bool,
                        pinMessageAllMembersEnabled: bool,
                        fromTimestamp: int) {.slot.} =
    let selectedItems = self.discordChannelsModel.getSelectedItems()
    var filesToImport: seq[string] = @[]

    for i in 0 ..< selectedItems.len:
      filesToImport.add(selectedItems[i].getFilePath())

    self.resetDiscordImport(false)
    self.setDiscordImportInProgress(true)
    self.delegate.requestImportDiscordCommunity(name, description, introMessage, outroMessage, access, color, tags,
                                  imagePath, aX, aY, bX, bY, historyArchiveSupportEnabled, pinMessageAllMembersEnabled,
                                  filesToImport, fromTimestamp)

  proc deleteCommunityCategory*(self: View, communityId: string, categoryId: string): string {.slot.} =
    self.delegate.deleteCommunityCategory(communityId, categoryId)

  proc reorderCommunityCategories*(self: View, communityId: string, categoryId: string, position: int) {.slot} =
    self.delegate.reorderCommunityCategories(communityId, categoryId, position)

  proc reorderCommunityChannel*(self: View, communityId: string, categoryId: string, chatId: string, position: int): string {.slot} =
    self.delegate.reorderCommunityChannel(communityId, categoryId, chatId, position)

  proc cancelRequestToJoinCommunity*(self: View, communityId: string) {.slot.} =
    self.delegate.cancelRequestToJoinCommunity(communityId)

  proc requestToJoinCommunity*(self: View, communityId: string, ensName: string) {.slot.} =
    self.delegate.requestToJoinCommunity(communityId, ensName)

  proc requestCommunityInfo*(self: View, communityId: string, importing: bool) {.slot.} =
    self.delegate.requestCommunityInfo(communityId, importing)

  proc getCommunityDetails*(self: View, communityId: string): string {.slot.} =
    let communityItem = self.model.getItemById(communityId)
    if (communityItem.id == ""):
      return ""

    # TODO: unify with observed community approach
    let jsonObj = %* {
      "name": communityItem.name,
      "image": communityItem.image,
      "color": communityItem.color,
    }
    return $jsonObj

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

  proc importingCommunityStateChanged*(self:View, communityId: string, state: int, errorMsg: string) {.signal.}
  proc emitImportingCommunityStateChangedSignal*(self: View, communityId: string, state: int, errorMsg: string) =
    self.importingCommunityStateChanged(communityId, state, errorMsg)

  proc isMemberOfCommunity*(self: View, communityId: string, pubKey: string): bool {.slot.} =
    let sectionItem = self.model.getItemById(communityId)
    if (section_item.id == ""):
       return false
    return sectionItem.hasMember(pubKey)

  proc removeFileListItem*(self: View, filePath: string) {.slot.} =
    var path = filePath
    if path.startsWith("file://"):
      path = replace(path, "file://", "")

    let categoryId = self.discordChannelsModel.getChannelCategoryIdByFilePath(path)

    # file list still uses full path, so relying on `filePath` here
    self.discordFileListModel.removeItem(filePath)
    self.discordChannelsModel.removeItemsByFilePath(path)

    if categoryId != "" and not self.discordChannelsModel.hasItemsWithCategoryId(categoryId):
      self.discordCategoriesModel.removeItem(categoryId)

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

  proc requestExtractDiscordChannelsAndCategories*(self: View) {.slot.} =
    let filePaths = self.discordFileListModel.getSelectedFilePaths()
    self.delegate.requestExtractDiscordChannelsAndCategories(filePaths)

  proc requestCancelDiscordCommunityImport*(self: View, id: string) {.slot.} =
    self.delegate.requestCancelDiscordCommunityImport(id)
    self.resetDiscordImport(true)

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

