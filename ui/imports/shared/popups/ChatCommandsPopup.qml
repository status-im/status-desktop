import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13

import utils 1.0
import shared.popups 1.0
import shared.stores 1.0

import StatusQ.Controls 0.1

Popup {
    id: root
    width: buttonRow.width
    height: buttonRow.height
    padding: 0
    margins: 0
    closePolicy: Popup.CloseOnReleaseOutsideParent | Popup.CloseOnEscape

    signal sendTransactionCommandButtonClicked()
    signal receiveTransactionCommandButtonClicked()

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

        StatusChatCommandButton {
            //% "Send transaction"
            text: qsTrId("send-transaction")
            icon.color: Style.current.purple
            icon.name: "send"
            onClicked: RootStore.isWalletEnabled ? root.sendTransactionCommandButtonClicked() : sendConfirmationPopup.open()
        }


        StatusChatCommandButton {
            //% "Request transaction"
            text: qsTrId("request-transaction")
            icon.color: Style.current.orange
            icon.name: "send"
            icon.rotation: 180
            onClicked: RootStore.isWalletEnabled ? root.receiveTransactionCommandButtonClicked() : receiveConfirmationPopup.open()
        }

        ConfirmationDialog {
            id: sendConfirmationPopup
            showCancelButton: true
            confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
            confirmButtonLabel: qsTr("I understand")
            onConfirmButtonClicked: {
                RootStore.enableWallet();
                close()
                root.sendTransactionCommandButtonClicked()
            }

            onCancelButtonClicked: {
                close()
            }
        }

        ConfirmationDialog {
            id: receiveConfirmationPopup
            showCancelButton: true
            confirmationText: qsTr("This feature is experimental and is meant for testing purposes by core contributors and the community. It's not meant for real use and makes no claims of security or integrity of funds or data. Use at your own risk.")
            confirmButtonLabel: qsTr("I understand")
            onConfirmButtonClicked: {
                RootStore.enableWallet();
                close()
                root.receiveTransactionCommandButtonClicked()
            }

            onCancelButtonClicked: {
                close()
            }
        }
    }
}
