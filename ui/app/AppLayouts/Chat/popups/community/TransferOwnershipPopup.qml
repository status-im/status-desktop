import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.14

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared.controls 1.0
import shared 1.0

StatusModal {
    id: root

    property string privateKey
    property var store

    header.title: qsTr("Transfer ownership")
    padding: 16

    ColumnLayout {
        anchors.fill: parent

        spacing: 16

        StatusInput {
            id: pKeyInput

            Layout.fillWidth: true

            readonly property string elidedPkey: Utils.elideText(root.privateKey, 16)

            leftPadding: 0
            rightPadding: 0
            label: qsTr("Community private key")

            input.text: elidedPkey
            input.edit.readOnly: true
            input.edit.onActiveFocusChanged: {
                pKeyInput.input.text =  pKeyInput.input.edit.focus ? root.privateKey : elidedPkey
            }
            input.rightComponent: StatusButton {
                anchors.verticalCenter: parent.verticalCenter
                border.width: 1
                border.color: Theme.palette.primaryColor1
                size: StatusBaseButton.Size.Tiny
                text: qsTr("Copy")
                onClicked: {
                    text = qsTr("Copied")
                    root.store.copyToClipboard(root.privateKey)
                }
            }
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: qsTr("You should keep it safe and only share it with people you trust to take ownership of your community")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }

        StatusBaseText {
            Layout.fillWidth: true

            text: qsTr("You can also use this key to import your community on another device")
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
        }
    }

    leftButtons: [
        StatusRoundButton {
            icon.name: "arrow-right"
            icon.height: 16
            icon.width: 20
            rotation: 180
            onClicked: {
                root.close()
            }
        }
    ]
}

