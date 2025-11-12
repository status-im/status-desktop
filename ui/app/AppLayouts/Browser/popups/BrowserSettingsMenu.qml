import QtQuick
import QtQuick.Controls

import StatusQ.Popups

StatusMenu {
    id: browserSettingsMenu

    property bool isIncognito: false

    visualizeShortcuts: true

    signal addNewTab()
    signal addNewDownloadTab()
    signal goIncognito(bool checked)
    signal zoomIn()
    signal zoomOut()
    signal changeZoomFactor()
    signal launchFindBar()
    signal toggleCompatibilityMode(bool checked)
    signal launchBrowserSettings()

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

    StatusMenuSeparator {}

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
        text: qsTr("Zoom Fit")
        shortcut: "Ctrl+0"
        onTriggered: changeZoomFactor()
    }

    StatusMenuSeparator {}

    Action {
        text: qsTr("Downloads")
        shortcut: "Ctrl+D"
        onTriggered: addNewDownloadTab()
    }

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
        checkable: true
        checked: localAccountSensitiveSettings.devToolsEnabled
        onTriggered: {
            localAccountSensitiveSettings.devToolsEnabled = !localAccountSensitiveSettings.devToolsEnabled
        }
    }

    StatusMenuSeparator {}

    Action {
        text: qsTr("Settings")
        shortcut: "Ctrl+,"
        onTriggered: launchBrowserSettings()
    }
}
