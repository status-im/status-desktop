import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1


import utils 1.0
import shared 1.0
import shared.status 1.0

SettingsContentBase {
    id: root

    property var store
    property var globalStore

    titleRowComponentLoader.sourceComponent: StatusButton {
        size: StatusBaseButton.Size.Small
        text: qsTrId("check-for-updates")
        onClicked: {
            root.store.checkForUpdates()
        }
    }

    ColumnLayout {
        spacing: Constants.settingsSection.itemSpacing
        width: root.contentWidth

        Column {
            Layout.fillWidth: true
            Image {
                id: statusIcon
                width: Style.dp(80)
                height: Style.dp(80)
                fillMode: Image.PreserveAspectFit
                source: Style.png("status-logo")
                anchors.horizontalCenter: parent.horizontalCenter
            }

            Item { width: Style.dp(1); height: Style.dp(8)}

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.palette.textColor
                font.pixelSize: Style.dp(22)
                font.bold: true
                text: root.store.getCurrentVersion()
            }

            StatusBaseText {
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.palette.textColor
                font.pixelSize: Style.current.primaryTextFontSize
                text: qsTr("Current Version")
            }

            Item { width: Style.dp(1); height: Style.dp(17)}

            StatusButton {
                anchors.horizontalCenter: parent.horizontalCenter
                size: StatusBaseButton.Size.Small
                icon.name: "info"
                text: qsTr("Release Notes")
            }
        } // Column

        StatusListItem {
            title: qsTr("Our Principles")
            Layout.fillWidth: true
            implicitHeight: Style.dp(64)
            components: [
                StatusIcon {
                    icon: "chevron-down"
                    rotation: 270
                    color: Theme.palette.baseColor1
                }
            ]
        }

        Column {
            Layout.fillWidth: true
            spacing: Style.dp(4)
            StatusBaseText {
                text: qsTr("Status desktop’s GitHub Repositories")
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                font.pixelSize: Style.current.primaryTextFontSize
                color: Style.current.secondaryText
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("Status Desktop")
                icon.width: 0
                onClicked: {
                    Global.openLink("https://github.com/status-im/status-desktop")
                }
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("Status Go")
                icon.width: 0
                onClicked: {
                    Global.openLink("https://github.com/status-im/status-go")
                }
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("StatusQ")
                icon.width: 0
                onClicked: {
                    Global.openLink("https://github.com/status-im/statusq")
                }
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("go-waku")
                icon.width: 0
                onClicked: {
                    Global.openLink("https://github.com/status-im/go-waku")
                }
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: Style.dp(4)
            StatusBaseText {
                anchors.left: parent.left
                anchors.leftMargin: Style.current.padding
                text: qsTr("Legal & Privacy Documents")
                font.pixelSize: Style.current.primaryTextFontSize
                color: Style.current.secondaryText
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("Terms of Use")
                icon.width: 0
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTr("Privacy Policy")
                icon.width: 0
                onClicked: {
                    Global.openLink("https://status.im/privacy-policy/")
                }
            }

            StatusFlatButton {
                Layout.fillWidth: true
                leftPadding: Style.current.padding
                rightPadding: Style.current.padding
                text: qsTrId("Software License")
                icon.width: 0
            }
        } // Column
    }
}
