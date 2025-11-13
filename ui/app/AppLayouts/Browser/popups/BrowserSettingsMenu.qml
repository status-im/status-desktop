import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

StatusMenu {
    id: root

    required property bool isIncognito
    required property real zoomFactor

    visualizeShortcuts: true

    signal addNewTab()
    signal addNewDownloadTab()
    signal goIncognito(bool checked)
    signal zoomIn()
    signal zoomOut()
    signal resetZoomFactor()
    signal launchFindBar()
    signal toggleCompatibilityMode(bool checked)
    signal launchBrowserSettings()

    StatusAction {
        text: qsTr("New Tab")
        icon.name: "add-tab"
        shortcut: StandardKey.AddTab
        onTriggered: addNewTab()
    }

    StatusAction {
        id: offTheRecordEnabled
        icon.name: "hide"
        text: checked ? qsTr("Exit Incognito mode") : qsTr("Go Incognito")
        checkable: true
        checked: isIncognito
        onToggled: goIncognito(checked)
    }

    StatusMenuSeparator {}

    Shortcut {
        sequences: [StandardKey.ZoomIn]
        onActivated: zoomIn()
    }

    Shortcut {
        sequences: [StandardKey.ZoomOut]
        onActivated: zoomOut()
    }

    Shortcut {
        sequence: "Ctrl+0"
        onActivated: resetZoomFactor()
    }

    StatusMenuItem {
        id: zoomMenuItem
        text: qsTr("Zoom")
        RowLayout {
            height: parent.availableHeight
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            anchors.rightMargin: zoomMenuItem.rightPadding
            StatusFlatButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                size: StatusBaseButton.Size.Tiny
                icon.name: "zoom-out"
                tooltip.text: qsTr("Zoom Out")
                onClicked: zoomOut()
            }
            StatusBaseText {
                text: "%L1%".arg(Math.round(root.zoomFactor*100))
                font.pixelSize: zoomMenuItem.font.pixelSize
            }
            StatusFlatButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                size: StatusBaseButton.Size.Tiny
                icon.name: "zoom-in"
                tooltip.text: qsTr("Zoom In")
                onClicked: zoomIn()
            }
            Rectangle {
                Layout.fillHeight: true
                Layout.preferredWidth: 1
                color: Theme.palette.statusMenu.separatorColor
            }
            StatusFlatButton {
                Layout.fillHeight: true
                Layout.preferredWidth: height
                size: StatusBaseButton.Size.Tiny
                icon.name: "zoom-fit"
                tooltip.text: qsTr("Zoom Fit")
                enabled: root.zoomFactor != 1
                onClicked: resetZoomFactor()
            }
        }
    }

    StatusMenuSeparator {}

    StatusAction {
        text: qsTr("Downloads")
        icon.name: "download"
        shortcut: "Ctrl+D"
        onTriggered: addNewDownloadTab()
    }

    StatusAction {
        text: qsTr("Find")
        icon.name: "search"
        shortcut: StandardKey.Find
        onTriggered: launchFindBar()
    }

    StatusAction {
        text: qsTr("Compatibility mode")
        checkable: true
        checked: true
        onToggled: toggleCompatibilityMode(checked)
    }

    StatusAction {
        text: qsTr("Developer Tools")
        icon.name: "gavel"
        shortcut: "F12"
        checkable: true
        checked: localAccountSensitiveSettings.devToolsEnabled
        onTriggered: {
            localAccountSensitiveSettings.devToolsEnabled = !localAccountSensitiveSettings.devToolsEnabled
        }
    }

    StatusMenuSeparator {}

    StatusAction {
        text: qsTr("Settings")
        icon.name: "settings"
        shortcut: "Ctrl+,"
        onTriggered: launchBrowserSettings()
    }
}
