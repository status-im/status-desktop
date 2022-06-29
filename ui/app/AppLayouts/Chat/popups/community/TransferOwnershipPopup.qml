import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


import utils 1.0
import shared.controls 1.0
import shared 1.0

StatusModal {
    id: popup

    property string privateKey
    property var store

    //% "Transfer ownership"
    header.title: qsTrId("transfer-ownership")

    onClosed: {
        popup.destroy();
    }

    contentItem: Item {
        width: popup.width
        implicitHeight: Math.max(300, content.height + 32)
        Column {
            id: content
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            width: popup.width - 32
            spacing: 16

            StatusInput {
                property string elidedPkey: popup.privateKey.substring(0, 15) + "..." + popup.privateKey.substring(popup.privateKey.length - 16)

                id: pKeyInput
                anchors.left: parent.left
                anchors.right: parent.right
                leftPadding: 0
                rightPadding: 0
                label: qsTr("Community private key")
                input.text: elidedPkey
                input.edit.readOnly: true
                input.edit.onActiveFocusChanged: {
                    pKeyInput.input.text =  pKeyInput.input.edit.focus ? popup.privateKey : elidedPkey
                }
                input.rightComponent: StatusButton {
                    anchors.verticalCenter: parent.verticalCenter
                    border.width: 1
                    border.color: Theme.palette.primaryColor1
                    size: StatusBaseButton.Size.Tiny
                    text: qsTr("Copy")
                    onClicked: {
                        text = qsTr("Copied")
                        popup.store.copyToClipboard(popup.privateKey)
                    }
                }
            }


            StatusBaseText {
                id: infoText1
                //% "You should keep it safe and only share it with people you trust to take ownership of your community"
                text: qsTrId("you-should-keep-it-safe-and-only-share-it-with-people-you-trust-to-take-ownership-of-your-community")
                wrapMode: Text.WordWrap
                width: parent.width
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }

            StatusBaseText {
                id: infoText2
                //% "You can also use this key to import your community on another device"
                text: qsTrId("you-can-also-use-this-key-to-import-your-community-on-another-device")
                wrapMode: Text.WordWrap
                width: parent.width
                font.pixelSize: 13
                color: Theme.palette.baseColor1
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            icon.name: "arrow-right"
            icon.height: 16
            icon.width: 20
            rotation: 180
            onClicked: {
                popup.close()
            }
        }
    ]
}

