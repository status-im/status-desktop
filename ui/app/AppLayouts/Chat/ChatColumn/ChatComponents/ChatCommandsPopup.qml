import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

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

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  walletModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.requestAddressForTransaction(chatsModel.activeChannel.id,
                                                address,
                                                amount,
                                                tokenAddress)
        chatCommandModal.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  walletModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.requestTransaction(chatsModel.activeChannel.id,
                                        address,
                                        amount,
                                        tokenAddress)
        chatCommandModal.close()
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
                chatCommandModal.sendChatCommand = root.requestAddressForTransaction
                chatCommandModal.isRequested = false
                chatCommandModal.commandTitle = qsTr("Send")
                chatCommandModal.title = chatCommandModal.commandTitle
                chatCommandModal.finalButtonLabel = qsTr("Request Address")
                chatCommandModal.selectedRecipient = {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    identicon: chatsModel.activeChannel.identicon,
                    name: chatsModel.activeChannel.name,
                    type: RecipientSelector.Type.Contact
                }
                chatCommandModal.open()
                root.close()
            }
        }


        ChatCommandButton {
            iconColor: Style.current.orange
            iconSource: "../../../../img/send.svg"
            rotatedImage: true
            //% "Request transaction"
            text: qsTrId("request-transaction")
            onClicked: function () {
                chatCommandModal.sendChatCommand = root.requestTransaction
                chatCommandModal.isRequested = true
                chatCommandModal.commandTitle = qsTr("Request")
                chatCommandModal.title = chatCommandModal.commandTitle
                chatCommandModal.finalButtonLabel = qsTr("Request")
                chatCommandModal.selectedRecipient = {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    identicon: chatsModel.activeChannel.identicon,
                    name: chatsModel.activeChannel.name,
                    type: RecipientSelector.Type.Contact
                }
                chatCommandModal.open()
                root.close()
            }
        }

        ChatCommandModal {
            id: chatCommandModal
        }
    }
}
