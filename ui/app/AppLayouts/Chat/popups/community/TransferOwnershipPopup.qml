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

    //% "Transfer ownership"
    header.title: qsTrId("transfer-ownership")

    onClosed: {
        popup.destroy();
    }

    contentItem: Item {
        width: popup.width
        height: Math.max(300, content.height + 32)
        Column {
            id: content
            anchors.top: parent.top
            anchors.topMargin: 16
            anchors.horizontalCenter: parent.horizontalCenter

            width: popup.width - 32
            spacing: 16

            Input {
                property string elidedPkey: popup.privateKey.substring(0, 15) + "..." + popup.privateKey.substring(popup.privateKey.length - 16)

                id: pKeyInput
                width: parent.width

                //% "Community private key"
                label: qsTrId("community-key")
                text: elidedPkey
                textField.onFocusChanged: {
                    if (textField.focus) {
                      pKeyInput.text =  popup.privateKey
                    } else {
                        pKeyInput.text =  elidedPkey
                    }
                }

                copyToClipboard: true
                textToCopy: popup.privateKey
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

