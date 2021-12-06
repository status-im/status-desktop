pragma Singleton

import QtQuick 2.13

QtObject {

    property int currentMenuTab: 0
    property var errorSound: Audio {
        id: errorSound
        track: Qt.resolvedUrl("../assets/audio/error.mp3")
    }
    property var mainModuleInst: mainModule
    signal openLinkInBrowser(string link)
    signal openChooseBrowserPopup(string link)

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
}
