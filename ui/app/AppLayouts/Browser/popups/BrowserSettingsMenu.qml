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
        text: qsTr("New Tab")
        shortcut: StandardKey.AddTab
        onTriggered: addNewTab()
    }

    Action {
        id: offTheRecordEnabled
        // TODO show an indicator on the browser or tab?
        text: checked ?
                  qsTr("Exit Incognito mode") :
                  qsTr("Go Incognito")
        checkable: true
        checked: isIncognito
        onToggled: goIncognito(checked)
    }

    Separator {}

    // TODO find a way to put both in one button
    Action {
        text: qsTr("Zoom In")
        shortcut: StandardKey.ZoomIn
        onTriggered: zoomIn()
    }

    Action {
        text: qsTr("Zoom Out")
        shortcut: StandardKey.ZoomOut
        onTriggered: zoomOut()
    }

    Action {
        shortcut: "Ctrl+0"
        onTriggered: changeZoomFactor()
    }

    Separator {}

    Action {
        text: qsTr("Find")
        shortcut: StandardKey.Find
        onTriggered: launchFindBar()
    }

    Action {
        text: qsTr("Compatibility mode")
        checkable: true
        checked: true
        onToggled: toggleCompatibilityMode(checked)
    }

    Action {
        text: qsTr("Developer Tools")
        shortcut: "F12"
        onTriggered: {
            localAccountSensitiveSettings.devToolsEnabled = !localAccountSensitiveSettings.devToolsEnabled
        }
    }

    Separator {}

    Action {
        text: qsTr("Settings")
        shortcut: "Ctrl+,"
        onTriggered: launchBrowserSettings()
    }
}
