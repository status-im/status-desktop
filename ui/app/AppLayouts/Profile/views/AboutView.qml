import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.status 1.0

SettingsContentBase {
    id: root

    property var store
    property var globalStore

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        // TODO: replace with StatusListItem
        StatusSectionDescItem {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            //% "App version"
            name: qsTrId("version")
            //% "Version: %1"
            description: qsTrId("version---1").arg(root.store.getCurrentVersion())
            tooltipUnder: true
            store: root.globalStore
        }

        // TODO: replace with StatusListItem
        StatusSectionDescItem {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            //% "Node version "
            name: qsTrId("node-version-")
            description: root.store.nodeVersion()
            store: root.globalStore
        }

        StatusFlatButton {
            Layout.fillWidth: true
            leftPadding: Style.current.padding
            rightPadding: Style.current.padding
            //% "Check for updates"
            text: qsTrId("check-for-updates")
            loading: root.store.fetchingUpdate
            onClicked: root.store.checkForUpdates()
            icon.width: 0
        }

        StatusBaseText {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            //% "Privacy Policy"
            text: qsTrId("privacy-policy")
            font.pixelSize: 15
            color: Theme.palette.primaryColor1

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                hoverEnabled: true
                onEntered: {
                    parent.font.underline = true
                }
                onExited: {
                    parent.font.underline = false
                }
                onClicked: {
                    Global.openLink("https://status.im/privacy-policy/")
                }
            }
        }
    }
}
