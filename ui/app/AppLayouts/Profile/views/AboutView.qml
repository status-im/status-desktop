import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0
import shared 1.0
import shared.status 1.0

Item {
    id: root
    Layout.fillHeight: true
    Layout.fillWidth: true
    clip: true

    property var store

    Column {
        id: generalColumn
        spacing: Style.current.bigPadding
        anchors.top: parent.top
        anchors.topMargin: 46
        width: profileContainer.profileContentWidth
        anchors.horizontalCenter: parent.horizontalCenter

        // TODO: replace with StatusListItem
        StatusSectionDescItem {
            //% "App version"
            name: qsTrId("version")
            //% "Version: %1"
            description: qsTrId("version---1").arg(root.store.getCurrentVersion())
            tooltipUnder: true
        }

        // TODO: replace with StatusListItem
        StatusSectionDescItem {
            //% "Node version "
            name: qsTrId("node-version-")
            description: root.store.nodeVersion()
        }

        StatusBaseText {
            //% "Check for updates"
            text: qsTrId("check-for-updates")
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
                    root.store.checkForUpdates();
                    Global.openPopup(downloadModalComponent, {newVersionAvailable: newVersionJSON.available, downloadURL: newVersionJSON.url})
                }
            }
        }

        StatusBaseText {
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

/*##^##
Designer {
    D{i:0;height:600;width:800}
}
##^##*/
