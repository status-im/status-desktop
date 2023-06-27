pragma Singleton

import QtQml 2.14

QtObject {
    id: root

    property var dragArea
    property var applicationWindow
    property bool activityPopupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile

    property var userProfile
    property bool appIsReady: false

    signal openPinnedMessagesPopupRequested(var store, var messageStore, var pinnedMessagesModel, string messageToPin, string chatId)
    signal openCommunityProfilePopupRequested(var store, var community, var chatCommunitySectionModule)

    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal settingsLoaded()
    signal openCreateChatView()
    signal closeCreateChatView()

    signal blockContactRequested(string publicKey, string contactName)
    signal unblockContactRequested(string publicKey, string contactName)

    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)

    signal openPopupRequested(var popupComponent, var params)
    signal closePopupRequested()
    signal openNicknamePopupRequested(string publicKey, string nickname, string subtitle)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal openChangeProfilePicPopup(var cb)
    signal openBackUpSeedPopup()
    signal openImagePopup(var image)
    signal openProfilePopupRequested(string publicKey, var parentPopup, var cb)
    signal openEditDisplayNamePopup()
    signal openActivityCenterPopupRequested()
    signal openSendIDRequestPopup(string publicKey, var cb)
    signal openContactRequestPopup(string publicKey, var cb)
    signal removeContactRequested(string displayName, string publicKey)
    signal openInviteFriendsToCommunityPopup(var community, var communitySectionModule, var cb)
    signal openIncomingIDRequestPopup(string publicKey, var cb)
    signal openOutgoingIDRequestPopup(string publicKey, var cb)
    signal openDeleteMessagePopup(string messageId, var messageStore)
    signal openDownloadImageDialog(string imageSource)
    signal contactRenamed(string publicKey)

    signal openLink(string link)

    signal setNthEnabledSectionActive(int nthSection)
    signal appSectionBySectionTypeChanged(int sectionType, int subsection)

    signal openSendModal(string address)
    signal switchToCommunity(string communityId)
    signal switchToCommunitySettings(string communityId)
    signal createCommunityPopupRequested(bool isDiscordImport)
    signal importCommunityPopupRequested()
    signal leaveCommunityRequested(string community, string communityId, string outroMessage)
    signal openEditSharedAddressesFlow(string communityId)

    signal playSendMessageSound()
    signal playNotificationSound()
    signal playErrorSound()

    signal openTestnetPopup()

    function openProfilePopup(publicKey, parentPopup, cb) {
        root.openProfilePopupRequested(publicKey, parentPopup, cb)
    }

    function openActivityCenterPopup() {
        root.openActivityCenterPopupRequested();
    }

    function openPopup(popupComponent, params = {}) {
        root.openPopupRequested(popupComponent, params);
    }

    function closePopup() {
        root.closePopupRequested();
    }

    function openDownloadModal(available, version, url){
        root.openDownloadModalRequested(available, version, url);
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0) {
        root.appSectionBySectionTypeChanged(sectionType, subsection);
    }

    function openMenu(menuComponent, menuParent, params = {}, point = undefined) {
        const menu = menuComponent.createObject(menuParent, params)
        if (point)
            menu.popup(point)
        else
            menu.popup()
        return menu
    }
}
