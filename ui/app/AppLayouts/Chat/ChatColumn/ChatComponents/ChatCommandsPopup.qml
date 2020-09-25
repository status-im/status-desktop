import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"
import "../../../../../shared/status"

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
        amount =  utilsModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.requestAddressForTransaction(chatsModel.activeChannel.id,
                                                address,
                                                amount,
                                                tokenAddress)
        chatCommandModal.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  utilsModel.eth2Wei(amount.toString(), tokenDecimals)
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

        StatusChatCommandButton {
            //% "Send transaction"
            text: qsTrId("send-transaction")
            icon.color: Style.current.purple
            icon.name: "send"
            icon.width: 16
            icon.height: 18
            onClicked: function () {
                chatCommandModal.sendChatCommand = root.requestAddressForTransaction
                chatCommandModal.isRequested = false
                //% "Send"
                chatCommandModal.commandTitle = qsTrId("command-button-send")
                chatCommandModal.title = chatCommandModal.commandTitle
                //% "Request Address"
                chatCommandModal.finalButtonLabel = qsTrId("request-address")
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


        StatusChatCommandButton {
            //% "Request transaction"
            text: qsTrId("request-transaction")
            icon.color: Style.current.orange
            icon.name: "send"
            icon.width: 16
            icon.height: 18
            iconRotation: 180
            onClicked: function () {
                chatCommandModal.sendChatCommand = root.requestTransaction
                chatCommandModal.isRequested = true
                //% "Request"
                chatCommandModal.commandTitle = qsTrId("wallet-request")
                chatCommandModal.title = chatCommandModal.commandTitle
                //% "Request"
                chatCommandModal.finalButtonLabel = qsTrId("wallet-request")
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
