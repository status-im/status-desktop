import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property string privateKey

    id: popup
    height: 504

    //% "Transfer ownership"
    title: qsTrId("transfer-ownership")

    onClosed: {
        popup.destroy();
    }

    Item {
        anchors.fill: parent

        Input {
            property string elidedPkey: popup.privateKey.substring(0, 15) + "..." + popup.privateKey.substring(popup.privateKey.length - 16)

            id: pKeyInput
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

        StyledText {
            id: infoText1
            //% "You should keep it safe and only share it with people you trust to take ownership of your community"
            text: qsTrId("you-should-keep-it-safe-and-only-share-it-with-people-you-trust-to-take-ownership-of-your-community")
            anchors.top: pKeyInput.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.padding
            width: parent.width
            font.pixelSize: 13
            color: Style.current.secondaryText
        }

        StyledText {
            id: infoText2
            //% "You can also use this key to import your community on another device"
            text: qsTrId("you-can-also-use-this-key-to-import-your-community-on-another-device")
            anchors.top: infoText1.bottom
            wrapMode: Text.WordWrap
            anchors.topMargin: Style.current.bigPadding
            width: parent.width
            font.pixelSize: 13
            color: Style.current.secondaryText
        }
    }

    footer: StatusRoundButton {
        id: btnBack
        anchors.left: parent.left
        icon.name: "arrow-right"
        icon.width: 20
        icon.height: 16
        rotation: 180
        onClicked: {
            popup.close()
        }
    }
}

