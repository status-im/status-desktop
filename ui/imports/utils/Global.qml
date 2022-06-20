pragma Singleton

import QtQuick 2.13
import AppLayouts.Chat.popups 1.0

QtObject {
    id: root

    property var applicationWindow
    property var appMain
    property bool popupOpened: false
    property int settingsSubsection: Constants.settingsSubsection.profile
    property var errorSound

    property var mainModuleInst
    property var privacyModuleInst
    property bool profilePopupOpened: false
    property string currentNetworkId: ""
    property int currentChainId: 0
    property bool networkGuarded: localAccountSensitiveSettings.isMultiNetworkEnabled || (root.currentNetworkId === Constants.networkMainnet ||
        (root.currentNetworkId === Constants.networkRopsten && localAccountSensitiveSettings.stickersEnsRopsten))

    signal openImagePopup(var image, var contextMenu)
    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openDownloadModalRequested()
    signal settingsLoaded()
    signal openBackUpSeedPopup()
    signal openCreateChatView()
    signal closeCreateChatView()

    signal openProfilePopupRequested(string publicKey, var parentPopup, string state)
    signal openChangeProfilePicPopup()
    signal displayToastMessage(string title, string subTitle, string icon, bool loading, int ephNotifType, string url)

    function openProfilePopup(publicKey, parentPopup, state = "") {
        openProfilePopupRequested(publicKey, parentPopup, state);
    }

    function openPopup(popupComponent, params = {}) {
        const popup = popupComponent.createObject(root.appMain, params);
        popup.open();
        return popup;
    }

    function openDownloadModal(){
        openDownloadModalRequested();
    }

    function changeAppSectionBySectionType(sectionType, subsection = 0) {
        if(!root.mainModuleInst)
            return

        mainModuleInst.setActiveSectionBySectionType(sectionType)
        if (sectionType === Constants.appSection.profile) {
            settingsSubsection = subsection;
        }
    }

    function getProfileImage(pubkey, isCurrentUser, useLargeImage) {
        if (isCurrentUser || (isCurrentUser === undefined && pubkey === userProfile.pubKey)) {
            return userProfile.icon;
        }

        let contactDetails = Utils.getContactDetailsAsJson(pubkey)
        
        if (root.privacyModuleInst.profilePicturesVisibility !==
            Constants.profilePicturesVisibility.everyone && !contactDetails.isContact) {
            return;
        }

        return contactDetails.displayIcon
    }

    function openLink(link) {
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
}
