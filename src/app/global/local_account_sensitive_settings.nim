import nimqml, os, json, chronicles

import ../../constants

# Local Account Settings keys:
const LSS_KEY_CHAT_SPLIT_VIEW* = "chatSplitView"
const LSS_KEY_WALLET_SPLIT_VIEW* = "walletSplitView"
const LSS_KEY_PROFILE_SPLIT_VIEW* = "profileSplitView"
const LSS_KEY_IS_COMMUNITY_PERMISSIONS_ENABLED* = "isExperimentalCommunityPermissionsEnabled"
const DEFAULT_IS_COMMUNITY_PERMISSIONS_ENABLED = false
const LSS_KEY_IS_COMMUNITY_TOKENS_ENABLED* = "isExperimentalCommunityTokensEnabled"
const DEFAULT_IS_COMMUNITY_TOKENS_ENABLED = false
const LSS_KEY_NODE_MANAGEMENT_ENABLED* = "nodeManagementEnabled"
const DEFAULT_NODE_MANAGEMENT_ENABLED = false
const LSS_KEY_ENS_COMMUNITY_PERMISSIONS_ENABLED* = "ensCommunityPermissionsEnabled"
const DEFAULT_COMMUNITY_PERMISSIONS_ENABLED = false
const LSS_KEY_SHOW_ONLINE_USERS* = "showOnlineUsers"
const DEFAULT_SHOW_ONLINE_USERS = true
const LSS_KEY_EXPAND_USERS_LIST* = "expandUsersList"
const DEFAULT_EXPAND_USERS_LIST = true
const DEFAULT_IS_MULTI_NETWORK_ENABLED = false
const LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN* = "neverAskAboutUnfurlingAgain"
const DEFAULT_NEVER_ASK_ABOUT_UNFURLING_AGAIN = false
const LSS_KEY_HIDE_CHANNEL_SUGGESTIONS* = "hideChannelSuggestions"
const DEFAULT_HIDE_CHANNEL_SUGGESTIONS = false
const DEFAULT_HIDE_SIGN_PHRASE_MODAL = false
const LSS_KEY_QUITE_ON_CLOSE* = "quitOnClose"
const DEFAULT_QUITE_ON_CLOSE = false
const LSS_KEY_SHOW_DELETE_MESSAGE_WARNING* = "showDeleteMessageWarning"
const DEFAULT_SHOW_DELETE_MESSAGE_WARNING = true
const LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED* = "downloadChannelMessagesEnabled"
const DEFAULT_DOWNLOAD_CHANNEL_MESSAGES_ENABLED = false
const LSS_KEY_ACTIVE_SECTION* = "activeSection"
const DEFAULT_ACTIVE_SECTION = ""
const LAST_SECTION_CHAT = "LastSectionChat"
const DEFAULT_ACTIVE_CHAT = ""
const LSS_KEY_AUTO_LOAD_IMAGES* = "autoLoadImages"
const DEFAULT_AUTO_LOAD_IMAGES = true
const LSS_KEY_JAVA_SCRIPT_ENABLED* = "javaScriptEnabled"
const DEFAULT_JAVA_SCRIPT_ENABLED = true
const LSS_KEY_ERROR_PAGE_ENABLED* = "errorPageEnabled"
const DEFAULT_ERROR_PAGE_ENABLED = true
const LSS_KEY_PLUGINS_ENABLED* = "pluginsEnabled"
const DEFAULT_PLUGINS_ENABLED = true
const LSS_KEY_AUTO_LOAD_ICONS_FOR_PAGE* = "autoLoadIconsForPage"
const DEFAULT_AUTO_LOAD_ICONS_FOR_PAGE = true
const LSS_KEY_TOUCH_ICONS_ENABLED* = "touchIconsEnabled"
const DEFAULT_TOUCH_ICONS_ENABLED = true
const LSS_KEY_WEB_RTC_PUBLIC_INTERFACES_ONLY* = "webRTCPublicInterfacesOnly"
const DEFAULT_WEB_RTC_PUBLIC_INTERFACES_ONLY = true
const LSS_KEY_DEV_TOOLS_ENABLED* = "devToolsEnabled"
const DEFAULT_DEV_TOOLS_ENABLED = false
const LSS_KEY_PDF_VIEWER_ENABLED* = "pdfViewerEnabled"
const DEFAULT_PDF_VIEWER_ENABLED = true
const LSS_KEY_COMPATIBILITY_MODE* = "compatibilityMode"
const DEFAULT_COMPATIBILITY_MODE = true
const LSS_KEY_STICKERS_ENS_ROPSTEN* = "stickersEnsRopsten"
const DEFAULT_STICKERS_ENS_ROPSTEN = false
const LSS_KEY_USER_DECLINED_BACKUP_BANNER* = "userDeclinedBackupBanner"
const DEFAULT_USER_DECLINED_BACKUP_BANNER = false
const LSS_KEY_GIF_UNFURLING_ENABLED* = "gifUnfurlingEnabled"
const DEFAULT_GIF_UNFURLING_ENABLED* = false
const LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN = "createCommunityPopupSeen"
const DEFAULT_LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN = false

logScope:
  topics = "la-sensitive-settings"

QtObject:
  type LocalAccountSensitiveSettings* = ref object of QObject
    settingsFileDir: string
    settings: QSettings

  proc setup(self: LocalAccountSensitiveSettings) =
    self.QObject.setup
    self.settingsFileDir = os.joinPath(DATADIR, "qt")

  proc delete*(self: LocalAccountSensitiveSettings) =
    self.QObject.delete

  proc newLocalAccountSensitiveSettings*():
    LocalAccountSensitiveSettings =
    new(result, delete)
    result.setup

  proc setFileName*(self: LocalAccountSensitiveSettings, fileName: string) =
    if(not self.settings.isNil):
      self.settings.delete

    let filePath = os.joinPath(self.settingsFileDir, fileName)
    self.settings = newQSettings(filePath, QSettingsFormat.IniFormat)

  # float type must be exposed through QVariant property.
  proc getSettingsPropQVariant(self: LocalAccountSensitiveSettings, prop: string, default: QVariant): QVariant =
    result = if(self.settings.isNil): default else: self.settings.value(prop, default)

  proc getSettingsPropString(self: LocalAccountSensitiveSettings, prop: string, default: QVariant): string =
    result = if(self.settings.isNil): default.stringVal else: self.settings.value(prop, default).stringVal

  proc getSettingsPropInt(self: LocalAccountSensitiveSettings, prop: string, default: QVariant): int =
    result = if(self.settings.isNil): default.intVal else: self.settings.value(prop, default).intVal

  proc getSettingsPropBool(self: LocalAccountSensitiveSettings, prop: string, default: QVariant): bool =
    result = if(self.settings.isNil): default.boolVal else: self.settings.value(prop, default).boolVal

  template getSettingsProp[T](self: LocalAccountSensitiveSettings, prop: string, default: QVariant): untyped =
    # This doesn't work in case of QVariant, such properties will be handled in a common way.
    when T is string:
      result = getSettingsPropString(self, prop, default)
    when T is int:
      result = getSettingsPropInt(self, prop, default)
    when T is bool:
      result = getSettingsPropBool(self, prop, default)

  template getSettingsGroupProp[T](self: LocalAccountSensitiveSettings, group: string, prop: string, default: QVariant): untyped =
    # This doesn't work in case of QVariant, such properties will be handled in a common way.
    if(self.settings.isNil):
      return

    self.settings.beginGroup(group);
    getSettingsProp[T](self, prop, default)
    self.settings.endGroup();
  

  template setSettingsProp(self: LocalAccountSensitiveSettings, prop: string, value: QVariant, signal: untyped) =
    if(self.settings.isNil):
      return

    self.settings.setValue(prop, value)
    signal

  template setSettingsGroupProp(self: LocalAccountSensitiveSettings, group: string, key: string, value: QVariant) =
    if(self.settings.isNil):
      return

    self.settings.beginGroup(group)
    self.settings.setValue(key, value)
    self.settings.endGroup()

  proc removeSettingsGroupKey(self: LocalAccountSensitiveSettings, group: string, key: string) =
    if(self.settings.isNil):
      return

    self.settings.beginGroup(group)
    self.settings.remove(key)
    self.settings.endGroup()

  proc getSectionLastOpenChat*(self: LocalAccountSensitiveSettings, sectionId: string): string =
    getSettingsGroupProp[string](self, LAST_SECTION_CHAT, sectionId, newQVariant(DEFAULT_ACTIVE_CHAT))

  proc setSectionLastOpenChat*(self: LocalAccountSensitiveSettings, sectionId: string, value: string) =
    self.setSettingsGroupProp(LAST_SECTION_CHAT, sectionId, newQVariant(value))
    
  proc removeSectionChatRecord*(self: LocalAccountSensitiveSettings, sectionId: string) =
    self.removeSettingsGroupKey(LAST_SECTION_CHAT, sectionId)

  proc chatSplitViewChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getChatSplitView*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_CHAT_SPLIT_VIEW, newQVariant())
  proc setChatSplitView*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_CHAT_SPLIT_VIEW, value):
      self.chatSplitViewChanged()

  QtProperty[QVariant] chatSplitView:
    read = getChatSplitView
    write = setChatSplitView
    notify = chatSplitViewChanged


  proc walletSplitViewChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getWalletSplitView*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_WALLET_SPLIT_VIEW, newQVariant())
  proc setWalletSplitView*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_WALLET_SPLIT_VIEW, value):
      self.walletSplitViewChanged()

  QtProperty[QVariant] walletSplitView:
    read = getWalletSplitView
    write = setWalletSplitView
    notify = walletSplitViewChanged


  proc profileSplitViewChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getProfileSplitView*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_PROFILE_SPLIT_VIEW, newQVariant())
  proc setProfileSplitView*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_PROFILE_SPLIT_VIEW, value):
      self.profileSplitViewChanged()

  QtProperty[QVariant] profileSplitView:
    read = getProfileSplitView
    write = setProfileSplitView
    notify = profileSplitViewChanged

  proc nodeManagementEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getNodeManagementEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_NODE_MANAGEMENT_ENABLED, newQVariant(DEFAULT_NODE_MANAGEMENT_ENABLED))
  proc setNodeManagementEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_NODE_MANAGEMENT_ENABLED, newQVariant(value)):
      self.nodeManagementEnabledChanged()

  QtProperty[bool] nodeManagementEnabled:
    read = getNodeManagementEnabled
    write = setNodeManagementEnabled
    notify = nodeManagementEnabledChanged

  proc ensCommunityPermissionsEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getEnsCommunityPermissionsEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_ENS_COMMUNITY_PERMISSIONS_ENABLED, newQVariant(DEFAULT_COMMUNITY_PERMISSIONS_ENABLED))
  proc setEnsCommunityPermissionsEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_ENS_COMMUNITY_PERMISSIONS_ENABLED, newQVariant(value)):
      self.ensCommunityPermissionsEnabledChanged()

  QtProperty[bool] ensCommunityPermissionsEnabled:
    read = getEnsCommunityPermissionsEnabled
    write = setEnsCommunityPermissionsEnabled
    notify = ensCommunityPermissionsEnabledChanged

  proc showOnlineUsersChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getShowOnlineUsers*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_SHOW_ONLINE_USERS, newQVariant(DEFAULT_SHOW_ONLINE_USERS))
  proc setShowOnlineUsers*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_SHOW_ONLINE_USERS, newQVariant(value)):
      self.showOnlineUsersChanged()

  QtProperty[bool] showOnlineUsers:
    read = getShowOnlineUsers
    write = setShowOnlineUsers
    notify = showOnlineUsersChanged


  proc expandUsersListChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getExpandUsersList*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_EXPAND_USERS_LIST, newQVariant(DEFAULT_EXPAND_USERS_LIST))
  proc setExpandUsersList*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_EXPAND_USERS_LIST, newQVariant(value)):
      self.expandUsersListChanged()

  QtProperty[bool] expandUsersList:
    read = getExpandUsersList
    write = setExpandUsersList
    notify = expandUsersListChanged

  proc neverAskAboutUnfurlingAgainChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getNeverAskAboutUnfurlingAgain*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN, newQVariant(DEFAULT_NEVER_ASK_ABOUT_UNFURLING_AGAIN))
  proc setNeverAskAboutUnfurlingAgain*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN, newQVariant(value)):
      self.neverAskAboutUnfurlingAgainChanged()

  QtProperty[bool] neverAskAboutUnfurlingAgain:
    read = getNeverAskAboutUnfurlingAgain
    write = setNeverAskAboutUnfurlingAgain
    notify = neverAskAboutUnfurlingAgainChanged


  proc hideChannelSuggestionsChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getHideChannelSuggestions*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_HIDE_CHANNEL_SUGGESTIONS, newQVariant(DEFAULT_HIDE_CHANNEL_SUGGESTIONS))
  proc setHideChannelSuggestions*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_HIDE_CHANNEL_SUGGESTIONS, newQVariant(value)):
      self.hideChannelSuggestionsChanged()

  QtProperty[bool] hideChannelSuggestions:
    read = getHideChannelSuggestions
    write = setHideChannelSuggestions
    notify = hideChannelSuggestionsChanged


  proc quitOnCloseChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getQuitOnClose*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_QUITE_ON_CLOSE, newQVariant(DEFAULT_QUITE_ON_CLOSE))
  proc setQuitOnClose*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_QUITE_ON_CLOSE, newQVariant(value)):
      self.quitOnCloseChanged()

  QtProperty[bool] quitOnClose:
    read = getQuitOnClose
    write = setQuitOnClose
    notify = quitOnCloseChanged


  proc showDeleteMessageWarningChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getShowDeleteMessageWarning*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_SHOW_DELETE_MESSAGE_WARNING, newQVariant(DEFAULT_SHOW_DELETE_MESSAGE_WARNING))
  proc setShowDeleteMessageWarning*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_SHOW_DELETE_MESSAGE_WARNING, newQVariant(value)):
      self.showDeleteMessageWarningChanged()

  QtProperty[bool] showDeleteMessageWarning:
    read = getShowDeleteMessageWarning
    write = setShowDeleteMessageWarning
    notify = showDeleteMessageWarningChanged


  proc downloadChannelMessagesEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getDownloadChannelMessagesEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED, newQVariant(DEFAULT_DOWNLOAD_CHANNEL_MESSAGES_ENABLED))
  proc setDownloadChannelMessagesEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED, newQVariant(value)):
      self.downloadChannelMessagesEnabledChanged()

  QtProperty[bool] downloadChannelMessagesEnabled:
    read = getDownloadChannelMessagesEnabled
    write = setDownloadChannelMessagesEnabled
    notify = downloadChannelMessagesEnabledChanged


  proc activeSectionChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getActiveSection*(self: LocalAccountSensitiveSettings): string {.slot.} =
    getSettingsProp[string](self, LSS_KEY_ACTIVE_SECTION, newQVariant(DEFAULT_ACTIVE_SECTION))
  proc setActiveSection*(self: LocalAccountSensitiveSettings, value: string) {.slot.} =
    setSettingsProp(self, LSS_KEY_ACTIVE_SECTION, newQVariant(value)):
      self.activeSectionChanged()

  QtProperty[string] activeSection:
    read = getActiveSection
    write = setActiveSection
    notify = activeSectionChanged


  proc autoLoadImagesChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getAutoLoadImages*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_AUTO_LOAD_IMAGES, newQVariant(DEFAULT_AUTO_LOAD_IMAGES))
  proc setAutoLoadImages*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_AUTO_LOAD_IMAGES, newQVariant(value)):
      self.autoLoadImagesChanged()

  QtProperty[bool] autoLoadImages:
    read = getAutoLoadImages
    write = setAutoLoadImages
    notify = autoLoadImagesChanged


  proc javaScriptEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getJavaScriptEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_JAVA_SCRIPT_ENABLED, newQVariant(DEFAULT_JAVA_SCRIPT_ENABLED))
  proc setJavaScriptEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_JAVA_SCRIPT_ENABLED, newQVariant(value)):
      self.javaScriptEnabledChanged()

  QtProperty[bool] javaScriptEnabled:
    read = getJavaScriptEnabled
    write = setJavaScriptEnabled
    notify = javaScriptEnabledChanged


  proc errorPageEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getErrorPageEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_ERROR_PAGE_ENABLED, newQVariant(DEFAULT_ERROR_PAGE_ENABLED))
  proc setErrorPageEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_ERROR_PAGE_ENABLED, newQVariant(value)):
      self.errorPageEnabledChanged()

  QtProperty[bool] errorPageEnabled:
    read = getErrorPageEnabled
    write = setErrorPageEnabled
    notify = errorPageEnabledChanged


  proc pluginsEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getPluginsEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_PLUGINS_ENABLED, newQVariant(DEFAULT_PLUGINS_ENABLED))
  proc setPluginsEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_PLUGINS_ENABLED, newQVariant(value)):
      self.pluginsEnabledChanged()

  QtProperty[bool] pluginsEnabled:
    read = getPluginsEnabled
    write = setPluginsEnabled
    notify = pluginsEnabledChanged


  proc autoLoadIconsForPageChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getAutoLoadIconsForPage*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_AUTO_LOAD_ICONS_FOR_PAGE, newQVariant(DEFAULT_AUTO_LOAD_ICONS_FOR_PAGE))
  proc setAutoLoadIconsForPage*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_AUTO_LOAD_ICONS_FOR_PAGE, newQVariant(value)):
      self.autoLoadIconsForPageChanged()

  QtProperty[bool] autoLoadIconsForPage:
    read = getAutoLoadIconsForPage
    write = setAutoLoadIconsForPage
    notify = autoLoadIconsForPageChanged


  proc touchIconsEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getTouchIconsEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_TOUCH_ICONS_ENABLED, newQVariant(DEFAULT_TOUCH_ICONS_ENABLED))
  proc setTouchIconsEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_TOUCH_ICONS_ENABLED, newQVariant(value)):
      self.touchIconsEnabledChanged()

  QtProperty[bool] touchIconsEnabled:
    read = getTouchIconsEnabled
    write = setTouchIconsEnabled
    notify = touchIconsEnabledChanged


  proc webRTCPublicInterfacesOnlyChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getWebRTCPublicInterfacesOnly*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_WEB_RTC_PUBLIC_INTERFACES_ONLY, newQVariant(DEFAULT_WEB_RTC_PUBLIC_INTERFACES_ONLY))
  proc setWebRTCPublicInterfacesOnly*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_WEB_RTC_PUBLIC_INTERFACES_ONLY, newQVariant(value)):
      self.webRTCPublicInterfacesOnlyChanged()

  QtProperty[bool] webRTCPublicInterfacesOnly:
    read = getWebRTCPublicInterfacesOnly
    write = setWebRTCPublicInterfacesOnly
    notify = webRTCPublicInterfacesOnlyChanged


  proc devToolsEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getDevToolsEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_DEV_TOOLS_ENABLED, newQVariant(DEFAULT_DEV_TOOLS_ENABLED))
  proc setDevToolsEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_DEV_TOOLS_ENABLED, newQVariant(value)):
      self.devToolsEnabledChanged()

  QtProperty[bool] devToolsEnabled:
    read = getDevToolsEnabled
    write = setDevToolsEnabled
    notify = devToolsEnabledChanged


  proc pdfViewerEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getPdfViewerEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_PDF_VIEWER_ENABLED, newQVariant(DEFAULT_PDF_VIEWER_ENABLED))
  proc setPdfViewerEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_PDF_VIEWER_ENABLED, newQVariant(value)):
      self.pdfViewerEnabledChanged()

  QtProperty[bool] pdfViewerEnabled:
    read = getPdfViewerEnabled
    write = setPdfViewerEnabled
    notify = pdfViewerEnabledChanged


  proc compatibilityModeChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getCompatibilityMode*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_COMPATIBILITY_MODE, newQVariant(DEFAULT_COMPATIBILITY_MODE))
  proc setCompatibilityMode*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_COMPATIBILITY_MODE, newQVariant(value)):
      self.compatibilityModeChanged()

  QtProperty[bool] compatibilityMode:
    read = getCompatibilityMode
    write = setCompatibilityMode
    notify = compatibilityModeChanged


  proc stickersEnsRopstenChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getStickersEnsRopsten*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_STICKERS_ENS_ROPSTEN, newQVariant(DEFAULT_STICKERS_ENS_ROPSTEN))
  proc setStickersEnsRopsten*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_STICKERS_ENS_ROPSTEN, newQVariant(value)):
      self.stickersEnsRopstenChanged()

  QtProperty[bool] stickersEnsRopsten:
    read = getStickersEnsRopsten
    write = setStickersEnsRopsten
    notify = stickersEnsRopstenChanged

  proc userDeclinedBackupBannerChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getUserDeclinedBackupBanner*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_USER_DECLINED_BACKUP_BANNER, newQVariant(DEFAULT_USER_DECLINED_BACKUP_BANNER))
  proc setUserDeclinedBackupBanner*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_USER_DECLINED_BACKUP_BANNER, newQVariant(value)):
      self.userDeclinedBackupBannerChanged()

  QtProperty[bool] userDeclinedBackupBanner:
    read = getUserDeclinedBackupBanner
    write = setUserDeclinedBackupBanner
    notify = userDeclinedBackupBannerChanged

  proc gifUnfurlingEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getGifUnfurlingEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_GIF_UNFURLING_ENABLED, newQVariant(DEFAULT_GIF_UNFURLING_ENABLED))
  proc setGifUnfurlingEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_GIF_UNFURLING_ENABLED, newQVariant(value)):
      self.gifUnfurlingEnabledChanged()

  QtProperty[bool] gifUnfurlingEnabled:
    read = getGifUnfurlingEnabled
    write = setGifUnfurlingEnabled
    notify = gifUnfurlingEnabledChanged

  proc createCommunityPopupSeenChanged(self: LocalAccountSensitiveSettings) {.signal.}
  proc getCreateCommunityPopupSeen(self: LocalAccountSensitiveSettings): bool {.slot.} =
    self.settings.value(LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN, newQVariant(DEFAULT_LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN)).boolVal
  proc setCreateCommunityPopupSeen(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    if value == self.getCreateCommunityPopupSeen:
      return
    self.settings.setValue(LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN, newQVariant(value))
    self.createCommunityPopupSeenChanged()

  QtProperty[bool] createCommunityPopupSeen:
    read = getCreateCommunityPopupSeen
    write = setCreateCommunityPopupSeen
    notify = createCommunityPopupSeenChanged

  proc removeKey*(self: LocalAccountSensitiveSettings, key: string) =
    if(self.settings.isNil):
      return

    self.settings.remove(key)

    case key:
      of LSS_KEY_CHAT_SPLIT_VIEW: self.chatSplitViewChanged()
      of LSS_KEY_WALLET_SPLIT_VIEW: self.walletSplitViewChanged()
      of LSS_KEY_PROFILE_SPLIT_VIEW: self.profileSplitViewChanged()
      of LSS_KEY_NODE_MANAGEMENT_ENABLED: self.nodeManagementEnabledChanged()
      of LSS_KEY_ENS_COMMUNITY_PERMISSIONS_ENABLED: self.ensCommunityPermissionsEnabledChanged()
      of LSS_KEY_SHOW_ONLINE_USERS: self.showOnlineUsersChanged()
      of LSS_KEY_EXPAND_USERS_LIST: self.expandUsersListChanged()
      of LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN: self.neverAskAboutUnfurlingAgainChanged()
      of LSS_KEY_HIDE_CHANNEL_SUGGESTIONS: self.hideChannelSuggestionsChanged()
      of LSS_KEY_QUITE_ON_CLOSE: self.quitOnCloseChanged()
      of LSS_KEY_SHOW_DELETE_MESSAGE_WARNING: self.showDeleteMessageWarningChanged()
      of LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED: self.downloadChannelMessagesEnabledChanged()
      of LSS_KEY_ACTIVE_SECTION: self.activeSectionChanged()
      of LSS_KEY_AUTO_LOAD_IMAGES: self.autoLoadImagesChanged()
      of LSS_KEY_JAVA_SCRIPT_ENABLED: self.javaScriptEnabledChanged()
      of LSS_KEY_ERROR_PAGE_ENABLED: self.errorPageEnabledChanged()
      of LSS_KEY_PLUGINS_ENABLED: self.pluginsEnabledChanged()
      of LSS_KEY_AUTO_LOAD_ICONS_FOR_PAGE: self.autoLoadIconsForPageChanged()
      of LSS_KEY_TOUCH_ICONS_ENABLED: self.touchIconsEnabledChanged()
      of LSS_KEY_WEB_RTC_PUBLIC_INTERFACES_ONLY: self.webRTCPublicInterfacesOnlyChanged()
      of LSS_KEY_DEV_TOOLS_ENABLED: self.devToolsEnabledChanged()
      of LSS_KEY_PDF_VIEWER_ENABLED: self.pdfViewerEnabledChanged()
      of LSS_KEY_COMPATIBILITY_MODE: self.compatibilityModeChanged()
      of LSS_KEY_STICKERS_ENS_ROPSTEN: self.stickersEnsRopstenChanged()
      of LSS_KEY_USER_DECLINED_BACKUP_BANNER: self.userDeclinedBackupBannerChanged()
      of LSS_KEY_GIF_UNFURLING_ENABLED: self.gifUnfurlingEnabledChanged()
      of LSS_KEY_CREATE_COMMUNITY_POPUP_SEEN: self.createCommunityPopupSeenChanged()
