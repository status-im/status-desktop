pragma Singleton

import QtQuick 2.13

QtObject {
    id: root

    property var appRootComponent
    property int currentMenuTab: 0
    property var errorSound: Audio {
        id: errorSound
        track: Qt.resolvedUrl("../assets/audio/error.mp3")
    }
    property var mainModuleInst: mainModule

    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)
    signal openPopupRequested(var popupComponent, var params)
    signal openDownloadModalRequested()
    signal settingsLoaded()

    function openDownloadModal(){
        openDownloadModalRequested()
    }

    function openPopup(popupComponent, params = {}) {
        root.openPopupRequested(popupComponent, params);
    }

    function createPopup(popupComponent, params = {}) {
        return popupComponent.createObject(root.appRootComponent, params);
    }

    function changeAppSectionBySectionType(sectionType) {
        mainModuleInst.setActiveSectionBySectionType(sectionType)
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
        errorSound.play();
    }

    function settingsHasLoaded() {
        settingsLoaded()
    }
}
