import QtQuick 2.13
import QtQuick.Controls 2.3
import QtWebEngine 1.9
import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0

import "../../Chat/popups"

// TODO: replace with StatusPopupMenu
PopupMenu {
    property var addNewTab: function () {}

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Action {
        //% "New Tab"
        text: qsTrId("new-tab")
        shortcut: StandardKey.AddTab
        onTriggered: {
            addNewTab()
        }
    }

    Action {
        id: offTheRecordEnabled
        // TODO show an indicator on the browser or tab?
        text: checked ?
                  //% "Exit Incognito mode"
                  qsTrId("exit-incognito-mode") :
                  //% "Go Incognito"
                  qsTrId("go-incognito")
        checkable: true
        checked: currentWebView && currentWebView.profile === otrProfile
        onToggled: function(checked) {
            if (currentWebView) {
                currentWebView.profile = checked ? otrProfile : defaultProfile;
            }
        }
    }

    Separator {}

    // TODO find a way to put both in one button
    Action {
        //% "Zoom In"
        text: qsTrId("zoom-in")
        shortcut: StandardKey.ZoomIn
        onTriggered: {
            const newZoom = currentWebView.zoomFactor + 0.1
            currentWebView.changeZoomFactor(newZoom)
        }
    }
    Action {
        //% "Zoom Out"
        text: qsTrId("zoom-out")
        shortcut: StandardKey.ZoomOut
        onTriggered: {
            const newZoom = currentWebView.zoomFactor - 0.1
            currentWebView.changeZoomFactor(newZoom)
        }
    }
    Action {
        shortcut: "Ctrl+0"
        onTriggered: currentWebView.changeZoomFactor(1.0)
    }

    Separator {}

    Action {
        //% "Find"
        text: qsTrId("find")
        shortcut: StandardKey.Find
        onTriggered: {
            if (!findBar.visible) {
                findBar.visible = true;
                findBar.forceActiveFocus()
            }
        }
    }

    Action {
        //% "Compatibility mode"
        text: qsTrId("compatibility-mode")
        checkable: true
        checked: true
        onToggled: {
            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.stop(); // Stop all loading tabs
            }

            localAccountSensitiveSettings.compatibilityMode = checked;

            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.reload(); // Reload them with new user agent
            }
                            
        }
    }

    Action {
        //% "Developer Tools"
        text: qsTrId("developer-tools")
        shortcut: "F12"
        onTriggered: {
            localAccountSensitiveSettings.devToolsEnabled = !localAccountSensitiveSettings.devToolsEnabled
        }
    }

    Separator {}

    Action {
        //% "Settings"
        text: qsTrId("settings")
        shortcut: "Ctrl+,"
        onTriggered: {
            appMain.changeAppSectionBySectionType(Constants.appSection.profile)
            // TODO: replace with shared store constant
            // Profile/RootStore.browser_settings_id
            profileLayoutContainer.changeProfileSection(10)
        }
    }
}
