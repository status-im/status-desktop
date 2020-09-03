import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../Wallet"

Popup {
    id: root
    width: buttonRow.width
    height: buttonRow.height
    padding: 0
    margins: 0

    background: Rectangle {
        color: Style.current.background
        radius: Style.current.radius
        border.width: 0
        layer.enabled: true
        layer.effect: DropShadow {
            verticalOffset: 3
            radius: 8
            samples: 15
            fast: true
            cached: true
            color: "#22000000"
        }
    }

    Row {
        id: buttonRow
        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.top: parent.top
        anchors.topMargin: 0
        padding: Style.current.halfPadding
        spacing: Style.current.halfPadding

        ChatCommandButton {
            iconColor: Style.current.purple
            iconSource: "../../../../img/send.svg"
            //% "Send transaction"
            text: qsTrId("send-transaction")
            onClicked: function () {
                sendModal.selectedRecipient = {
                    address: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9",
                    identicon: chatsModel.activeChannel.identicon,
                    name: chatsModel.activeChannel.name,
                    type: RecipientSelector.Type.Contact
                }
                sendModal.open()
            }
        }

        ChatCommandButton {
            iconColor: Style.current.orange
            iconSource: "../../../../img/send.svg"
            rotatedImage: true
            //% "Request transaction"
            text: qsTrId("request-transaction")
        }

        SendModal {
            id: sendModal
            onOpened: {
                walletModel.getGasPricePredictions()
            }
            selectedRecipient: {
                return {
                   address: "0x9ce0056c5fc6bb9459a4dcfa35eaad8c1fee5ce9",
                   identicon: chatsModel.activeChannel.identicon,
                   name: chatsModel.activeChannel.name,
                   type: RecipientSelector.Type.Contact
               }
            }
        }
    }
}
