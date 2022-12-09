pragma Singleton

import QtQml 2.14

QtObject {
    id: root

    property var applicationWindow
    property var appMain
    property var dragArea
    property bool popupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile

    property var globalUtilsInst: typeof globalUtils !== "undefined" ? globalUtils : null
    property var mainModuleInst
    property var userProfile
    property var privacyModuleInst
    property var toastMessage
    property var pinnedMessagesPopup
    property var communityProfilePopup
    property bool profilePopupOpened: false

    property bool activityCenterPopupOpened: false

    property var sendMessageSound
    property var notificationSound
    property var errorSound

    signal openImagePopup(var image, var contextMenu)
    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal settingsLoaded()
    signal openBackUpSeedPopup()
    signal openCreateChatView()
    signal closeCreateChatView()

    signal openProfilePopupRequested(string publicKey, var parentPopup)

    signal openNicknamePopupRequested(string publicKey, string nickname, string subtitle)
    signal nickNameChanged(string publicKey, string nickname)

    signal blockContactRequested(string publicKey, string contactName)
    signal contactBlocked(string publicKey)
    signal unblockContactRequested(string publicKey, string contactName)
    signal contactUnblocked(string publicKey)

    signal openChangeProfilePicPopup(var cb)
    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)
    signal openEditDisplayNamePopup()
    signal openActivityCenterPopupRequested

    signal openContactRequestPopup(string publicKey, var cb)

    signal openInviteFriendsToCommunityPopup(var community, var communitySectionModule, var cb)

    signal openSendIDRequestPopup(string publicKey, var cb)

    signal openIncomingIDRequestPopup(string publicKey, var cb)

    signal openOutgoingIDRequestPopup(string publicKey, var cb)

    function openProfilePopup(publicKey, parentPopup) {
        openProfilePopupRequested(publicKey, parentPopup)
    }

    function openActivityCenterPopup() {
        openActivityCenterPopupRequested()
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(root.appMain, params)
        popup.open()
        return popup
    }

    function openDownloadModal(available, version, url){
        openDownloadModalRequested(available, version, url);
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0) {
        if(!root.mainModuleInst)
            return

        mainModuleInst.setActiveSectionBySectionType(sectionType)
        if (sectionType === Constants.appSection.profile) {
            settingsSubsection = subsection;
        }
    }

    function setNthEnabledSectionActive(nthSection) {
        if(!root.mainModuleInst)
            return
        mainModuleInst.setNthEnabledSectionActive(nthSection)
    }

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === userProfile.pubKey)) {
            return userProfile.icon;
        }

        let contactDetails = Utils.getContactDetailsAsJson(pubkey)
        return contactDetails.displayIcon
    }

    function openLink(link) {
        // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
        link = globalUtilsInst.plainText(link);
        if (localAccountSensitiveSettings.showBrowserSelector) {
            openChooseBrowserPopup(link);
        } else {
            if (localAccountSensitiveSettings.openLinksInStatus) {
                changeAppSectionBySectionType(Constants.appSection.browser);
                openLinkInBrowser(link);
            } else {
                Qt.openUrlExternally(link);
            }
        }
    }

    function playErrorSound() {
        if(errorSound)
            errorSound.play();
    }
}
