import NimQml, strutils
import ../shared_models/section_model
import ../shared_models/section_item
import ../shared_models/section_details
import io_interface
import chat_search_model
import ephemeral_notification_model
from ../../../app_service/common/conversion import intToEnum
from ../../../app_service/common/types import StatusType

QtObject:
  type
    View* = ref object of QObject
      delegate: io_interface.AccessInterface
      model: section_model.SectionModel
      modelVariant: QVariant
      sectionsLoaded: bool
      chatsLoadingFailed: bool
      activeSection: SectionDetails
      activeSectionVariant: QVariant
      chatSearchModel: chat_search_model.Model
      chatSearchModelVariant: QVariant
      ephemeralNotificationModel: ephemeralNotification_model.Model
      ephemeralNotificationModelVariant: QVariant
      tmpCommunityId: string # shouldn't be used anywhere except in prepareCommunitySectionModuleForCommunityId/getCommunitySectionModule procs

  proc activeSectionChanged*(self:View) {.signal.}

  proc delete*(self: View) =
    self.model.delete
    self.modelVariant.delete
    self.activeSection.delete
    self.activeSectionVariant.delete
    self.chatSearchModel.delete
    self.chatSearchModelVariant.delete
    self.ephemeralNotificationModel.delete
    self.ephemeralNotificationModelVariant.delete
    self.QObject.delete

  proc newView*(delegate: io_interface.AccessInterface): View =
    new(result, delete)
    result.QObject.setup
    result.delegate = delegate
    result.model = section_model.newModel()
    result.sectionsLoaded = false
    result.chatsLoadingFailed = false
    result.modelVariant = newQVariant(result.model)
    result.activeSection = newActiveSection()
    result.activeSectionVariant = newQVariant(result.activeSection)
    result.chatSearchModel = chat_search_model.newModel()
    result.chatSearchModelVariant = newQVariant(result.chatSearchModel)
    result.ephemeralNotificationModel = ephemeralNotification_model.newModel()
    result.ephemeralNotificationModelVariant = newQVariant(result.ephemeralNotificationModel)
    signalConnect(result.model, "notificationsCountChanged()", result,
    "onNotificationsCountChanged()", 2)

  proc load*(self: View) =
    # In some point, here, we will setup some exposed main module related things.
    self.delegate.viewDidLoad()

  proc editItem*(self: View, item: SectionItem) =
    self.model.editItem(item)
    if (self.activeSection.getId() == item.id):
      self.activeSection.setActiveSectionData(item)
      self.activeSectionChanged()

  proc model*(self: View): SectionModel =
    return self.model

  proc modelChanged*(self: View) {.signal.}

  proc getModel(self: View): QVariant {.slot.} =
    return self.modelVariant

  QtProperty[QVariant] sectionsModel:
    read = getModel
    notify = modelChanged

  proc chatSearchModel*(self: View): chat_search_model.Model =
    return self.chatSearchModel

  proc rebuildChatSearchModel*(self: View) {.slot.} =
    self.delegate.rebuildChatSearchModel()

  proc onNotificationsCountChanged*(self: View) {.slot.} =
    self.delegate.meMentionedCountChanged(self.model.allMentionsCount())

  proc chatSearchModelChanged*(self: View) {.signal.}
  proc getChatSearchModel(self: View): QVariant {.slot.} =
    return self.chatSearchModelVariant
  QtProperty[QVariant] chatSearchModel:
    read = getChatSearchModel
    notify = chatSearchModelChanged

  proc ephemeralNotificationModel*(self: View): ephemeralNotification_model.Model =
    return self.ephemeralNotificationModel

  proc ephemeralNotificationModelChanged*(self: View) {.signal.}
  proc getEphemeralNotificationModel(self: View): QVariant {.slot.} =
    return self.ephemeralNotificationModelVariant
  QtProperty[QVariant] ephemeralNotificationModel:
    read = getEphemeralNotificationModel
    notify = ephemeralNotificationModelChanged

  proc displayEphemeralNotification*(self: View, title: string, subTitle: string, icon: string, loading: bool, 
    ephNotifType: int, url: string) {.slot.} =
    self.delegate.displayEphemeralNotification(title, subTitle, icon, loading, ephNotifType, url)

  proc removeEphemeralNotification*(self: View, id: string) {.slot.} =
    self.delegate.removeEphemeralNotification(id.parseInt)

  proc ephemeralNotificationClicked*(self: View, id: string) {.slot.} =
    self.delegate.ephemeralNotificationClicked(id.parseInt)

  proc openStoreToKeychainPopup*(self: View) {.signal.}

  proc mailserverWorking*(self:View) {.signal.}

  proc mailserverNotWorking*(self:View) {.signal.}

  proc displayWindowsOsNotification*(self:View, title: string, message: string) {.signal.}

  proc emitMailserverWorking*(self: View) =
    self.mailserverWorking()

  proc emitMailserverNotWorking*(self: View) =
    self.mailserverNotWorking()

  proc activeSection*(self: View): SectionDetails =
    return self.activeSection

  proc getActiveSection(self: View): QVariant {.slot.} =
    return self.activeSectionVariant

  QtProperty[QVariant] activeSection:
    read = getActiveSection
    notify = activeSectionChanged

  proc activeSectionSet*(self: View, item: SectionItem) =
    self.activeSection.setActiveSectionData(item)
    self.activeSectionChanged()

  proc setNthEnabledSectionActive*(self: View, nth: int) {.slot.} =
    let item = self.model.getNthEnabledItem(nth)
    self.delegate.setActiveSection(item)

  proc setActiveSectionById*(self: View, sectionId: string) {.slot.} =
    self.delegate.setActiveSectionById(sectionId)

  proc setActiveSectionBySectionType*(self: View, sectionType: int) {.slot.} =
    ## This will try to set a section with passed sectionType to active one, in case of communities the first community
    ## will be set as active one.
    let item = self.model.getItemBySectionType(sectionType.SectionType)
    self.delegate.setActiveSection(item)

  proc switchTo*(self: View, sectionId: string, chatId: string) {.slot.} =
    self.delegate.switchTo(sectionId, chatId)

  proc setCurrentUserStatus*(self: View, status: int) {.slot.} =
    self.delegate.setCurrentUserStatus(intToEnum(status, StatusType.Unknown))

  proc sectionsLoadedChanged(self: View) {.signal.}

  proc sectionsLoaded*(self: View) =
    self.sectionsLoaded = true
    self.sectionsLoadedChanged()

  proc getSectionsLoaded(self: View): bool {.slot.} =
    return self.sectionsLoaded
  QtProperty[bool] sectionsLoaded:
    read = getSectionsLoaded
    notify = sectionsLoadedChanged

  proc chatsLoadingFailedChanged(self: View) {.signal.}

  proc chatsLoadingFailed*(self: View) =
    self.chatsLoadingFailed = true
    self.chatsLoadingFailedChanged()

  proc getChatsLoadingFailed(self: View): bool {.slot.} =
    return self.chatsLoadingFailed
  QtProperty[bool] chatsLoadingFailed:
    read = getChatsLoadingFailed
    notify = chatsLoadingFailedChanged

  # Since we cannot return QVariant from the proc which has arguments, so cannot have proc like this:
  # prepareCommunitySectionModuleForCommunityId(self: View, communityId: string): QVariant {.slot.}
  # we're using combination of
  # prepareCommunitySectionModuleForCommunityId/getCommunitySectionModule procs
  proc prepareCommunitySectionModuleForCommunityId*(self: View, communityId: string) {.slot.} =
    self.tmpCommunityId = communityId

  proc getCommunitySectionModule*(self: View): QVariant {.slot.} =
    var communityVariant = self.delegate.getCommunitySectionModule(self.tmpCommunityId)
    self.tmpCommunityId = ""
    if(communityVariant.isNil):
      return newQVariant()

    return communityVariant

  proc getChatSectionModule*(self: View): QVariant {.slot.} =
    return self.delegate.getChatSectionModuleAsVariant()

  proc getAppSearchModule(self: View): QVariant {.slot.} =
    return self.delegate.getAppSearchModule()

  QtProperty[QVariant] appSearchModule:
    read = getAppSearchModule

  proc getContactDetailsAsJson(self: View, publicKey: string, getVerificationRequest: bool): string {.slot.} =
    return self.delegate.getContactDetailsAsJson(publicKey, getVerificationRequest)

  proc isEnsVerified(self:View, publicKey: string): bool {.slot.} =
    return self.delegate.isEnsVerified(publicKey)

  proc resolveENS*(self: View, ensName: string, uuid: string) {.slot.} =
    self.delegate.resolveENS(ensName, uuid)

  proc resolvedENS*(self: View, resolvedPubKey: string, resolvedAddress: string, uuid: string) {.signal.}
  proc emitResolvedENSSignal*(self: View, resolvedPubKey: string, resolvedAddress: string, uuid: string) =
    self.resolvedENS(resolvedPubKey, resolvedAddress, uuid)

  proc openActivityCenter*(self: View) {.signal.}
  proc emitOpenActivityCenterSignal*(self: View) =
    self.openActivityCenter()

  proc openCommunityMembershipRequestsView*(self: View, sectionId: string) {.signal.}
  proc emitOpenCommunityMembershipRequestsViewSignal*(self: View, sectionId: string) =
    self.openCommunityMembershipRequestsView(sectionId)

  proc onlineStatusChanged(self: View, connected: bool) {.signal.}

  proc isConnected*(self: View): bool {.slot.} =
    result = self.delegate.isConnected()

  proc setConnected*(self: View, connected: bool) = # Not a slot
    self.onlineStatusChanged(connected)

  QtProperty[bool] isOnline:
    read = isConnected
    notify = onlineStatusChanged

  proc displayUserProfile*(self:View, publicKey: string) {.signal.}
  proc emitDisplayUserProfileSignal*(self: View, publicKey: string) =
    self.displayUserProfile(publicKey)

  proc getKeycardSharedModule(self: View): QVariant {.slot.} =
    let module = self.delegate.getKeycardSharedModule()
    if not module.isNil:
      return module
    return newQVariant()
  QtProperty[QVariant] keycardSharedModule:
    read = getKeycardSharedModule

  proc activateStatusDeepLink*(self: View, statusDeepLink: string) {.slot.} =
    self.delegate.activateStatusDeepLink(statusDeepLink)
    
  proc displayKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDisplayKeycardSharedModuleFlow*(self: View) =
    self.displayKeycardSharedModuleFlow()

  proc destroyKeycardSharedModuleFlow*(self: View) {.signal.}
  proc emitDestroyKeycardSharedModuleFlow*(self: View) =
    self.destroyKeycardSharedModuleFlow()

  proc windowActivated*(self: View) {.slot.} = 
    self.delegate.windowActivated()

  proc windowDeactivated*(self: View) {.slot.} = 
    self.delegate.windowDeactivated()
