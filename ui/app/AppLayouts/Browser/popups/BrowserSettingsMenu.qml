import QtQuick 2.13
import QtQuick.Controls 2.3
import QtWebEngine 1.9

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import shared.popups 1.0

import utils 1.0

// TODO: replace with StatusPopupMenu
PopupMenu {
    id: browserSettingsMenu

    property bool isIncognito: false

    signal addNewTab()
    signal goIncognito(bool checked)
    signal zoomIn()
    signal zoomOut()
    signal changeZoomFactor()
    signal launchFindBar()
    signal toggleCompatibilityMode(bool checked)
    signal launchBrowserSettings()

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutsideParent

    Action {
        //% "New Tab"
        text: qsTrId("new-tab")
        shortcut: StandardKey.AddTab
        onTriggered: addNewTab()
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
        checked: isIncognito
        onToggled: goIncognito(checked)
    }

    Separator {}

    // TODO find a way to put both in one button
    Action {
        //% "Zoom In"
        text: qsTrId("zoom-in")
        shortcut: StandardKey.ZoomIn
        onTriggered: zoomIn()
    }

    Action {
        //% "Zoom Out"
        text: qsTrId("zoom-out")
        shortcut: StandardKey.ZoomOut
        onTriggered: zoomOut()
    }

    Action {
        shortcut: "Ctrl+0"
        onTriggered: changeZoomFactor()
    }

    Separator {}

    Action {
        //% "Find"
        text: qsTrId("find")
        shortcut: StandardKey.Find
        onTriggered: launchFindBar()
    }

    Action {
        //% "Compatibility mode"
        text: qsTrId("compatibility-mode")
        checkable: true
        checked: true
        onToggled: toggleCompatibilityMode(checked)
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
        onTriggered: launchBrowserSettings()
    }
}
