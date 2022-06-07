import NimQml, os, json, chronicles

import ../../constants

# Local Account Settings keys:
const LSS_KEY_CHAT_SPLIT_VIEW* = "chatSplitView"
const LSS_KEY_WALLET_SPLIT_VIEW* = "walletSplitView"
const LSS_KEY_PROFILE_SPLIT_VIEW* = "profileSplitView"
const LSS_KEY_IS_WALLET_ENABLED* = "isExperimentalWalletEnabled"
const DEFAULT_IS_WALLET_ENABLED = false
const LSS_KEY_NODE_MANAGEMENT_ENABLED* = "nodeManagementEnabled"
const DEFAULT_NODE_MANAGEMENT_ENABLED = false
const LSS_KEY_IS_BROWSER_ENABLED* = "isExperimentalBrowserEnabled"
const DEFAULT_IS_BROWSER_ENABLED = false
const LSS_KEY_SHOW_ONLINE_USERS* = "showOnlineUsers"
const DEFAULT_SHOW_ONLINE_USERS = true
const LSS_KEY_EXPAND_USERS_LIST* = "expandUsersList"
const DEFAULT_EXPAND_USERS_LIST = true
const LSS_KEY_IS_GIF_WIDGET_ENABLED* = "isGifWidgetEnabled"
const DEFAULT_IS_GIF_WIDGET_ENABLED = true
const DEFAULT_IS_MULTI_NETWORK_ENABLED = false
const LSS_KEY_IS_TENOR_WARNING_ACCEPTED* = "isTenorWarningAccepted"
const DEFAULT_IS_TENOR_WARNING_ACCEPTED = false
const LSS_KEY_DISPLAY_CHAT_IMAGES* = "displayChatImages"
const DEFAULT_DISPLAY_CHAT_IMAGES = false
const LSS_KEY_RECENT_EMOJIS* = "recentEmojis"
const DEFAULT_RECENT_EMOJIS = ""
const LSS_KEY_HIDDEN_COMMUNITY_WELCOME_BANNERS* = "hiddenCommunityWelcomeBanners"
const DEFAULT_HIDDEN_COMMUNITY_WELCOME_BANNERS = ""
const LSS_KEY_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS* = "hiddenCommunityChannelsAndCategoriesBanner"
const DEFAULT_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS = ""
const LSS_KEY_HIDDEN_COMMUNITY_BACKUP_BANNERS* = "hiddenCommunityBackUpBanners"
const DEFAULT_HIDDEN_COMMUNITY_BACKUP_BANNERS = ""
const LSS_KEY_WITHLISTED_UNFURLING_SITES* = "whitelistedUnfurlingSites"
const DEFAULT_WITHLISTED_UNFURLING_SITES = ""
const LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN* = "neverAskAboutUnfurlingAgain"
const DEFAULT_NEVER_ASK_ABOUT_UNFURLING_AGAIN = false
const LSS_KEY_HIDE_CHANNEL_SUGGESTIONS* = "hideChannelSuggestions"
const DEFAULT_HIDE_CHANNEL_SUGGESTIONS = false
const LSS_KEY_FONT_SIZE* = "fontSize"
const DEFAULT_FONT_SIZE = 2 #fontSizeM from qml
const LSS_KEY_HIDE_SIGN_PHRASE_MODAL* = "hideSignPhraseModal"
const DEFAULT_HIDE_SIGN_PHRASE_MODAL = false
const LSS_KEY_QUITE_ON_CLOSE* = "quitOnClose"
const DEFAULT_QUITE_ON_CLOSE = false
const LSS_KEY_SKIN_COLOR* = "skinColor"
const DEFAULT_SKIN_COLOR = ""
const LSS_KEY_SHOW_DELETE_MESSAGE_WARNING* = "showDeleteMessageWarning"
const DEFAULT_SHOW_DELETE_MESSAGE_WARNING = true
const LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED* = "downloadChannelMessagesEnabled"
const DEFAULT_DOWNLOAD_CHANNEL_MESSAGES_ENABLED = false
const LSS_KEY_ACTIVE_SECTION* = "activeSection"
const DEFAULT_ACTIVE_SECTION = ""
const LSS_KEY_SHOW_BROWSER_SELECTOR* = "showBrowserSelector"
const DEFAULT_SHOW_BROWSER_SELECTOR = true
const LSS_KEY_OPEN_LINKS_IN_STATUS* = "openLinksInStatus"
const DEFAULT_OPEN_LINKS_IN_STATUS = true
const LSS_KEY_SHOULD_SHOW_FAVORITES_BAR* = "shouldShowFavoritesBar"
const DEFAULT_SHOULD_SHOW_FAVORITES_BAR = true
const LSS_KEY_BROWSER_HOMEPAGE* = "browserHomepage"
const DEFAULT_BROWSER_HOMEPAGE = ""
const LSS_KEY_SHOULD_SHOW_BROWSER_SEARCH_ENGINE* = "shouldShowBrowserSearchEngine"
const DEFAULT_SHOULD_SHOW_BROWSER_SEARCH_ENGINE = 3 #browserSearchEngineDuckDuckGo from qml
const LSS_KEY_USE_BROWSER_ETHEREUM_EXPLORER* = "useBrowserEthereumExplorer"
const DEFAULT_USE_BROWSER_ETHEREUM_EXPLORER = 1 #browserEthereumExplorerEtherscan from qml
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
const LSS_KEY_IS_DDMMYY_DATE_FORMAT* = "is_DDMMYY_date_format"
const DEFAULT_IS_DDMMYY_DATE_FORMAT = false
const LSS_KEY_IS_24H_TIME_FORMAT* = "is_24h_time_format"
const DEFAULT_IS_24H_TIME_FORMAT = false
const LSS_KEY_USER_DECLINED_BACKUP_BANNER* = "userDeclinedBackupBanner"
const DEFAULT_USER_DECLINED_BACKUP_BANNER = false


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
    if(not self.settings.isNil):
      self.settings.delete

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

  template setSettingsProp(self: LocalAccountSensitiveSettings, prop: string, value: QVariant, signal: untyped) =
    if(self.settings.isNil):
      return

    self.settings.setValue(prop, value)
    signal


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

  proc isWalletEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIsWalletEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_WALLET_ENABLED, newQVariant(DEFAULT_IS_WALLET_ENABLED))
  proc setIsWalletEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_WALLET_ENABLED, newQVariant(value)):
      self.isWalletEnabledChanged()

  QtProperty[bool] isWalletEnabled:
    read = getIsWalletEnabled
    write = setIsWalletEnabled
    notify = isWalletEnabledChanged

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


  proc isBrowserEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIsBrowserEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_BROWSER_ENABLED, newQVariant(DEFAULT_IS_BROWSER_ENABLED))
  proc setIsBrowserEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_BROWSER_ENABLED, newQVariant(value)):
      self.isBrowserEnabledChanged()

  QtProperty[bool] isBrowserEnabled:
    read = getIsBrowserEnabled
    write = setIsBrowserEnabled
    notify = isBrowserEnabledChanged

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


  proc isGifWidgetEnabledChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIsGifWidgetEnabled*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_GIF_WIDGET_ENABLED, newQVariant(DEFAULT_IS_GIF_WIDGET_ENABLED))
  proc setIsGifWidgetEnabled*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_GIF_WIDGET_ENABLED, newQVariant(value)):
      self.isGifWidgetEnabledChanged()

  QtProperty[bool] isGifWidgetEnabled:
    read = getIsGifWidgetEnabled
    write = setIsGifWidgetEnabled
    notify = isGifWidgetEnabledChanged

  proc isTenorWarningAcceptedChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIsTenorWarningAccepted*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_TENOR_WARNING_ACCEPTED, newQVariant(DEFAULT_IS_TENOR_WARNING_ACCEPTED))
  proc setIsTenorWarningAccepted*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_TENOR_WARNING_ACCEPTED, newQVariant(value)):
      self.isTenorWarningAcceptedChanged()

  QtProperty[bool] isTenorWarningAccepted:
    read = getIsTenorWarningAccepted
    write = setIsTenorWarningAccepted
    notify = isTenorWarningAcceptedChanged


  proc displayChatImagesChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getDisplayChatImages*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_DISPLAY_CHAT_IMAGES, newQVariant(DEFAULT_DISPLAY_CHAT_IMAGES))
  proc setDisplayChatImages*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_DISPLAY_CHAT_IMAGES, newQVariant(value)):
      self.displayChatImagesChanged()

  QtProperty[bool] displayChatImages:
    read = getDisplayChatImages
    write = setDisplayChatImages
    notify = displayChatImagesChanged


  proc recentEmojisChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getRecentEmojis*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_RECENT_EMOJIS, newQVariant(DEFAULT_RECENT_EMOJIS))
  proc setRecentEmojis*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_RECENT_EMOJIS, value):
      self.recentEmojisChanged()

  QtProperty[QVariant] recentEmojis:
    read = getRecentEmojis
    write = setRecentEmojis
    notify = recentEmojisChanged


  proc hiddenCommunityWelcomeBannersChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getHiddenCommunityWelcomeBanners*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_HIDDEN_COMMUNITY_WELCOME_BANNERS, newQVariant(DEFAULT_HIDDEN_COMMUNITY_WELCOME_BANNERS))
  proc setHiddenCommunityWelcomeBanners*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_HIDDEN_COMMUNITY_WELCOME_BANNERS, value):
      self.hiddenCommunityWelcomeBannersChanged()

  QtProperty[QVariant] hiddenCommunityWelcomeBanners:
    read = getHiddenCommunityWelcomeBanners
    write = setHiddenCommunityWelcomeBanners
    notify = hiddenCommunityWelcomeBannersChanged

  proc hiddenCommunityChannelAndCategoriesBannersChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getHiddenCommunityChannelAndCategoriesBanners*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS, newQVariant(DEFAULT_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS))
  proc setHiddenCommunityChannelAndCategoriesBanners*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS, value):
      self.hiddenCommunityChannelAndCategoriesBannersChanged()

  QtProperty[QVariant] hiddenCommunityChannelAndCategoriesBanners:
    read = getHiddenCommunityChannelAndCategoriesBanners
    write = setHiddenCommunityChannelAndCategoriesBanners
    notify = hiddenCommunityChannelAndCategoriesBannersChanged

  proc hiddenCommunityBackUpBannersChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getHiddenCommunityBackUpBanners*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_HIDDEN_COMMUNITY_BACKUP_BANNERS, newQVariant(DEFAULT_HIDDEN_COMMUNITY_BACKUP_BANNERS))
  proc setHiddenCommunityBackUpBanners*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_HIDDEN_COMMUNITY_BACKUP_BANNERS, value):
      self.hiddenCommunityBackUpBannersChanged()

  QtProperty[QVariant] hiddenCommunityBackUpBanners:
    read = getHiddenCommunityBackUpBanners
    write = setHiddenCommunityBackUpBanners
    notify = hiddenCommunityBackUpBannersChanged


  proc whitelistedUnfurlingSitesChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getWhitelistedUnfurlingSites*(self: LocalAccountSensitiveSettings): QVariant {.slot.} =
    getSettingsPropQVariant(self, LSS_KEY_WITHLISTED_UNFURLING_SITES, newQVariant(DEFAULT_WITHLISTED_UNFURLING_SITES))
  proc setWhitelistedUnfurlingSites*(self: LocalAccountSensitiveSettings, value: QVariant) {.slot.} =
    setSettingsProp(self, LSS_KEY_WITHLISTED_UNFURLING_SITES, value):
      self.whitelistedUnfurlingSitesChanged()

  QtProperty[QVariant] whitelistedUnfurlingSites:
    read = getWhitelistedUnfurlingSites
    write = setWhitelistedUnfurlingSites
    notify = whitelistedUnfurlingSitesChanged


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


  proc fontSizeChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getfontSize*(self: LocalAccountSensitiveSettings): int {.slot.} =
    getSettingsProp[int](self, LSS_KEY_FONT_SIZE, newQVariant(DEFAULT_FONT_SIZE))
  proc setfontSize*(self: LocalAccountSensitiveSettings, value: int) {.slot.} =
    setSettingsProp(self, LSS_KEY_FONT_SIZE, newQVariant(value)):
      self.fontSizeChanged()

  QtProperty[int] fontSize:
    read = getfontSize
    write = setfontSize
    notify = fontSizeChanged


  proc hideSignPhraseModalChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getHideSignPhraseModal*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_HIDE_SIGN_PHRASE_MODAL, newQVariant(DEFAULT_HIDE_SIGN_PHRASE_MODAL))
  proc setHideSignPhraseModal*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_HIDE_SIGN_PHRASE_MODAL, newQVariant(value)):
      self.hideSignPhraseModalChanged()

  QtProperty[bool] hideSignPhraseModal:
    read = getHideSignPhraseModal
    write = setHideSignPhraseModal
    notify = hideSignPhraseModalChanged


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


  proc skinColorChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getSkinColor*(self: LocalAccountSensitiveSettings): string {.slot.} =
    getSettingsProp[string](self, LSS_KEY_SKIN_COLOR, newQVariant(DEFAULT_SKIN_COLOR))
  proc setSkinColor*(self: LocalAccountSensitiveSettings, value: string) {.slot.} =
    setSettingsProp(self, LSS_KEY_SKIN_COLOR, newQVariant(value)):
      self.skinColorChanged()

  QtProperty[string] skinColor:
    read = getSkinColor
    write = setSkinColor
    notify = skinColorChanged


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


  proc showBrowserSelectorChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getShowBrowserSelector*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_SHOW_BROWSER_SELECTOR, newQVariant(DEFAULT_SHOW_BROWSER_SELECTOR))
  proc setShowBrowserSelector*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_SHOW_BROWSER_SELECTOR, newQVariant(value)):
      self.showBrowserSelectorChanged()

  QtProperty[bool] showBrowserSelector:
    read = getShowBrowserSelector
    write = setShowBrowserSelector
    notify = showBrowserSelectorChanged


  proc openLinksInStatusChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getOpenLinksInStatus*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_OPEN_LINKS_IN_STATUS, newQVariant(DEFAULT_OPEN_LINKS_IN_STATUS))
  proc setOpenLinksInStatus*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_OPEN_LINKS_IN_STATUS, newQVariant(value)):
      self.openLinksInStatusChanged()

  QtProperty[bool] openLinksInStatus:
    read = getOpenLinksInStatus
    write = setOpenLinksInStatus
    notify = openLinksInStatusChanged


  proc shouldShowFavoritesBarChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getShouldShowFavoritesBar*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_SHOULD_SHOW_FAVORITES_BAR, newQVariant(DEFAULT_SHOULD_SHOW_FAVORITES_BAR))
  proc setShouldShowFavoritesBar*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_SHOULD_SHOW_FAVORITES_BAR, newQVariant(value)):
      self.shouldShowFavoritesBarChanged()

  QtProperty[bool] shouldShowFavoritesBar:
    read = getShouldShowFavoritesBar
    write = setShouldShowFavoritesBar
    notify = shouldShowFavoritesBarChanged


  proc browserHomepageChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getBrowserHomepage*(self: LocalAccountSensitiveSettings): string {.slot.} =
    getSettingsProp[string](self, LSS_KEY_BROWSER_HOMEPAGE, newQVariant(DEFAULT_BROWSER_HOMEPAGE))
  proc setBrowserHomepage*(self: LocalAccountSensitiveSettings, value: string) {.slot.} =
    setSettingsProp(self, LSS_KEY_BROWSER_HOMEPAGE, newQVariant(value)):
      self.browserHomepageChanged()

  QtProperty[string] browserHomepage:
    read = getBrowserHomepage
    write = setBrowserHomepage
    notify = browserHomepageChanged


  proc shouldShowBrowserSearchEngineChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getShouldShowBrowserSearchEngine*(self: LocalAccountSensitiveSettings): int {.slot.} =
    getSettingsProp[int](self, LSS_KEY_SHOULD_SHOW_BROWSER_SEARCH_ENGINE, newQVariant(DEFAULT_SHOULD_SHOW_BROWSER_SEARCH_ENGINE))
  proc setShouldShowBrowserSearchEngine*(self: LocalAccountSensitiveSettings, value: int) {.slot.} =
    setSettingsProp(self, LSS_KEY_SHOULD_SHOW_BROWSER_SEARCH_ENGINE, newQVariant(value)):
      self.shouldShowBrowserSearchEngineChanged()

  QtProperty[int] shouldShowBrowserSearchEngine:
    read = getShouldShowBrowserSearchEngine
    write = setShouldShowBrowserSearchEngine
    notify = shouldShowBrowserSearchEngineChanged


  proc useBrowserEthereumExplorerChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getUseBrowserEthereumExplorer*(self: LocalAccountSensitiveSettings): int {.slot.} =
    getSettingsProp[int](self, LSS_KEY_USE_BROWSER_ETHEREUM_EXPLORER, newQVariant(DEFAULT_USE_BROWSER_ETHEREUM_EXPLORER))
  proc setUseBrowserEthereumExplorer*(self: LocalAccountSensitiveSettings, value: int) {.slot.} =
    setSettingsProp(self, LSS_KEY_USE_BROWSER_ETHEREUM_EXPLORER, newQVariant(value)):
      self.useBrowserEthereumExplorerChanged()

  QtProperty[int] useBrowserEthereumExplorer:
    read = getUseBrowserEthereumExplorer
    write = setUseBrowserEthereumExplorer
    notify = useBrowserEthereumExplorerChanged


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

  proc isDDMMYYDateFormatChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIsDDMMYYDateFormat*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_DDMMYY_DATE_FORMAT, newQVariant(DEFAULT_IS_DDMMYY_DATE_FORMAT))
  proc setIsDDMMYYDateFormat*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_DDMMYY_DATE_FORMAT, newQVariant(value)): 
      self.isDDMMYYDateFormatChanged()

  QtProperty[bool] isDDMMYYDateFormat:
    read = getIsDDMMYYDateFormat
    write = setIsDDMMYYDateFormat
    notify = isDDMMYYDateFormatChanged

  proc is24hTimeFormatChanged*(self: LocalAccountSensitiveSettings) {.signal.}
  proc getIs24hTimeFormat*(self: LocalAccountSensitiveSettings): bool {.slot.} =
    getSettingsProp[bool](self, LSS_KEY_IS_24H_TIME_FORMAT, newQVariant(DEFAULT_IS_24H_TIME_FORMAT))    

  proc setIs24hTimeFormat*(self: LocalAccountSensitiveSettings, value: bool) {.slot.} =
    setSettingsProp(self, LSS_KEY_IS_24H_TIME_FORMAT, newQVariant(value)):
      self.is24hTimeFormatChanged()

  QtProperty[bool] is24hTimeFormat:
    read = getIs24hTimeFormat
    write = setIs24hTimeFormat
    notify = is24hTimeFormatChanged
  
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

  proc removeKey*(self: LocalAccountSensitiveSettings, key: string) =
    if(self.settings.isNil):
      return

    self.settings.remove(key)

    case key:
      of LSS_KEY_CHAT_SPLIT_VIEW: self.chatSplitViewChanged()
      of LSS_KEY_WALLET_SPLIT_VIEW: self.walletSplitViewChanged()
      of LSS_KEY_PROFILE_SPLIT_VIEW: self.profileSplitViewChanged()
      of LSS_KEY_IS_WALLET_ENABLED: self.isWalletEnabledChanged()
      of LSS_KEY_NODE_MANAGEMENT_ENABLED: self.nodeManagementEnabledChanged()
      of LSS_KEY_IS_BROWSER_ENABLED: self.isBrowserEnabledChanged()
      of LSS_KEY_SHOW_ONLINE_USERS: self.showOnlineUsersChanged()
      of LSS_KEY_EXPAND_USERS_LIST: self.expandUsersListChanged()
      of LSS_KEY_IS_GIF_WIDGET_ENABLED: self.isGifWidgetEnabledChanged()
      of LSS_KEY_IS_TENOR_WARNING_ACCEPTED: self.isTenorWarningAcceptedChanged()
      of LSS_KEY_DISPLAY_CHAT_IMAGES: self.displayChatImagesChanged()
      of LSS_KEY_RECENT_EMOJIS: self.recentEmojisChanged()
      of LSS_KEY_HIDDEN_COMMUNITY_WELCOME_BANNERS: self.hiddenCommunityWelcomeBannersChanged()
      of LSS_KEY_HIDDEN_COMMUNITY_CHANNELS_AND_CATEGORIES_BANNERS: self.hiddenCommunityChannelAndCategoriesBannersChanged()
      of LSS_KEY_HIDDEN_COMMUNITY_BACKUP_BANNERS: self.hiddenCommunityBackUpBannersChanged()
      of LSS_KEY_WITHLISTED_UNFURLING_SITES: self.whitelistedUnfurlingSitesChanged()
      of LSS_KEY_NEVER_ASK_ABOUT_UNFURLING_AGAIN: self.neverAskAboutUnfurlingAgainChanged()
      of LSS_KEY_HIDE_CHANNEL_SUGGESTIONS: self.hideChannelSuggestionsChanged()
      of LSS_KEY_FONT_SIZE: self.fontSizeChanged()
      of LSS_KEY_HIDE_SIGN_PHRASE_MODAL: self.hideSignPhraseModalChanged()
      of LSS_KEY_QUITE_ON_CLOSE: self.quitOnCloseChanged()
      of LSS_KEY_SKIN_COLOR: self.skinColorChanged()
      of LSS_KEY_SHOW_DELETE_MESSAGE_WARNING: self.showDeleteMessageWarningChanged()
      of LSS_KEY_DOWNLOAD_CHANNEL_MESSAGES_ENABLED: self.downloadChannelMessagesEnabledChanged()
      of LSS_KEY_ACTIVE_SECTION: self.activeSectionChanged()
      of LSS_KEY_SHOW_BROWSER_SELECTOR: self.showBrowserSelectorChanged()
      of LSS_KEY_OPEN_LINKS_IN_STATUS: self.openLinksInStatusChanged()
      of LSS_KEY_SHOULD_SHOW_FAVORITES_BAR: self.shouldShowFavoritesBarChanged()
      of LSS_KEY_BROWSER_HOMEPAGE: self.browserHomepageChanged()
      of LSS_KEY_SHOULD_SHOW_BROWSER_SEARCH_ENGINE: self.shouldShowBrowserSearchEngineChanged()
      of LSS_KEY_USE_BROWSER_ETHEREUM_EXPLORER: self.useBrowserEthereumExplorerChanged()
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
      of LSS_KEY_IS_DDMMYY_DATE_FORMAT: self.isDDMMYYDateFormatChanged()
      of LSS_KEY_IS_24H_TIME_FORMAT: self.is24hTimeFormatChanged()
      of LSS_KEY_USER_DECLINED_BACKUP_BANNER: self.userDeclinedBackupBannerChanged()
