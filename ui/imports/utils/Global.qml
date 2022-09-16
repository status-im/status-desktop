pragma Singleton

import QtQuick 2.13
import AppLayouts.Chat.popups 1.0

import shared.popups 1.0

Item {
    id: root

    property var applicationWindow
    property var appMain
    property bool popupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile

    property var mainModuleInst
    property var privacyModuleInst
    property var toastMessage
    property var pinnedMessagesPopup
    property var communityProfilePopup
    property var inviteFriendsToCommunityPopup
    property bool profilePopupOpened: false

    property bool activityCenterPopupOpened: false

    property var sendMessageSound
    property var notificationSound
    property var errorSound

    signal openImagePopup(var image, var contextMenu)
    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openPopupRequested(var popupComponent, var params)
    signal openDownloadModalRequested(bool available, string version, string url)
    signal settingsLoaded()
    signal openBackUpSeedPopup()
    signal openCreateChatView()
    signal closeCreateChatView()

    signal openProfilePopupRequested(string publicKey, var parentPopup, string state)
    signal openChangeProfilePicPopup()
    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)
    signal openEditDisplayNamePopup()
    signal openActivityCenterPopupRequested

    function openContactRequestPopup(publicKey) {
        const contactDetails = Utils.getContactDetailsAsJson(publicKey);
        return openPopup(sendContactRequestPopupComponent, {
            userPublicKey: publicKey,
            userDisplayName: contactDetails.displayName,
            userIcon: contactDetails.largeImage,
            userIsEnsVerified: contactDetails.ensVerified,
        })
    }

    function openProfilePopup(publicKey, parentPopup, state = "") {
        openProfilePopupRequested(publicKey, parentPopup, state);
    }

    function openActivityCenterPopup() {
        openActivityCenterPopupRequested()
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(root.appMain, params);
        popup.open();
        return popup;
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
        
        if (root.privacyModuleInst.profilePicturesVisibility !==
            Constants.profilePicturesVisibility.everyone && !contactDetails.isAdded) {
            return;
        }

        return contactDetails.displayIcon
    }

    function openLink(link) {
        // Qt sometimes inserts random HTML tags; and this will break on invalid URL inside QDesktopServices::openUrl(link)
        link = globalUtils.plainText(link);
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

    function settingsHasLoaded() {
        settingsLoaded()
    }

    Component {
        id: sendContactRequestPopupComponent
        SendContactRequestModal {
            anchors.centerIn: parent
            onAccepted: appMain.rootStore.profileSectionStore.contactsStore.sendContactRequest(userPublicKey, message)
            onClosed: destroy()
        }
    }
}
