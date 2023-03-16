pragma Singleton

import QtQml 2.14

QtObject {
    id: root

    property var dragArea
    property var applicationWindow
    property bool popupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile

    property var userProfile

    signal openPinnedMessagesPopupRequested(var store, var messageStore, var pinnedMessagesModel, string messageToPin)
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
    signal openNicknamePopupRequested(string publicKey, string nickname, string subtitle)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal openChangeProfilePicPopup(var cb)
    signal openBackUpSeedPopup()
    signal openImagePopup(var image, var contextMenu)
    signal openProfilePopupRequested(string publicKey, var parentPopup)
    signal openEditDisplayNamePopup()
    signal openActivityCenterPopupRequested()
    signal openSendIDRequestPopup(string publicKey, var cb)
    signal openContactRequestPopup(string publicKey, var cb)
    signal openInviteFriendsToCommunityPopup(var community, var communitySectionModule, var cb)
    signal openIncomingIDRequestPopup(string publicKey, var cb)
    signal openOutgoingIDRequestPopup(string publicKey, var cb)

    signal openLink(string link)

    signal setNthEnabledSectionActive(int nthSection)
    signal appSectionBySectionTypeChanged(int sectionType, int subsection)

    signal playSendMessageSound()
    signal playNotificationSound()
    signal playErrorSound()

    function openProfilePopup(publicKey, parentPopup) {
        root.openProfilePopupRequested(publicKey, parentPopup)
    }

    function openActivityCenterPopup() {
        root.openActivityCenterPopupRequested();
    }

    function openPopup(popupComponent, params = {}) {
        root.openPopupRequested(popupComponent, params);
    }

    function openDownloadModal(available, version, url){
        root.openDownloadModalRequested(available, version, url);
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0) {
        root.appSectionBySectionTypeChanged(sectionType, subsection);
    }
}
