import QtQuick 2.13
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

Column {
    spacing: 57

    StatusInput {
        id: codeInput
        anchors.horizontalCenter: parent.horizontalCenter
        Layout.topMargin: 70
        label: qsTr("Paste sync code")
        input.placeholderText: qsTr("eg. %1").arg("0x2Ef19")
        input.font: Theme.palette.monoFont.name
        input.placeholderFont: input.font
        input.rightComponent: StatusButton {
            size: StatusBaseButton.Size.Tiny
            enabled: codeInput.input.edit.canPaste
            onClicked: codeInput.input.edit.paste()
            text: qsTr("Paste")
        }
    }

    Column {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 4

        RowLayout {
            height: d.listItemHeight

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("1. Open Status App on your desktop")
            }
        }

        RowLayout {
            height: d.listItemHeight

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("2. Open")
            }
            StatusRoundIcon {
                id: settingsButton
                icon.name: "settings"
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                color: Theme.palette.directColor1
                text: qsTr("Settings")
            }

        }

        RowLayout {
            height: d.listItemHeight

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 15
                color: Theme.palette.baseColor1
                text: qsTr("3. Navigate to the ")
            }
            StatusRoundIcon {
                icon.name: "rotate"
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Syncing tab")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }
        }

        RowLayout {
            height: d.listItemHeight

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("4. Click the Setup Syncing button")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Setup Syncing")
                font.pixelSize: 15
                color: Theme.palette.directColor1
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("button")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        RowLayout {
            height: d.listItemHeight

            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("5. Paste the sync code above")
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }
    }
}
