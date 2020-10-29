import QtQuick 2.13
import QtQuick.Controls 2.3
import QtWebEngine 1.9
import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "../Chat/ChatColumn/ChatComponents"
import "../Profile/LeftTab/constants.js" as ProfileConstants

PopupMenu {
    property var addNewTab: function () {}

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Action {
        text: qsTr("New Tab")
        shortcut: StandardKey.AddTab
        onTriggered: {
            addNewTab()
        }
    }

    Action {
        id: offTheRecordEnabled
        // TODO show an indicator on the browser or tab?
        text: checked ?
                  qsTr("Exit Incognito mode") :
                  qsTr("Go Incognito")
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
        text: qsTr("Zoom In")
        shortcut: StandardKey.ZoomIn
        onTriggered: {
            const newZoom = currentWebView.zoomFactor + 0.1
            currentWebView.changeZoomFactor(newZoom)
        }
    }
    Action {
        text: qsTr("Zoom Out")
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
        text: qsTr("Find")
        shortcut: StandardKey.Find
        onTriggered: {
            if (!findBar.visible) {
                findBar.visible = true;
                findBar.forceActiveFocus()
            }
        }
    }

    Action {
        text: qsTr("Compatibility mode")
        checkable: true
        checked: true
        onToggled: {
            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.stop(); // Stop all loading tabs
            }

            appSettings.compatibilityMode = checked;

            for (let i = 0; i < tabs.count; ++i){
                tabs.getTab(i).item.reload(); // Reload them with new user agent
            }
                            
        }
    }

    Action {
        text: qsTr("Developer Tools")
        shortcut: "F12"
        onTriggered: {
            appSettings.devToolsEnabled = !appSettings.devToolsEnabled
        }
    }

    Separator {}

    Action {
        text: qsTr("Settings")
        shortcut: "Ctrl+,"
        onTriggered: {
            appMain.changeAppSection(Constants.profile)
            profileLayoutContainer.changeProfileSection(ProfileConstants.BROWSER_SETTINGS)
        }
    }
}
