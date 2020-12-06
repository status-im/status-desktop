import QtQuick 2.3
import "../../ChatComponents"
import "../../../../../../shared"
import "../../../../../../imports"

Item {
    property int state: Constants.addressRequested

    width: parent.width
    height: childrenRect.height

    Separator {
        id: separator1
    }

    StyledText {
        id: acceptText
        color: Style.current.blue
        //% "Accept and share address"
        text: root.state === Constants.addressRequested ? 
          qsTrId("accept-and-share-address") : 
          //% "Accept and send"
          qsTrId("accept-and-send")
        padding: Style.current.halfPadding
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: separator1.bottom
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.state === Constants.addressRequested) {
                    selectAccountModal.open()
                } else if (root.state === Constants.transactionRequested) {
                    signTransactionModal.open()
                }
            }
        }
    }

    Separator {
        id: separator2
        anchors.topMargin: 0
        anchors.top: acceptText.bottom
    }

    StyledText {
        id: declineText
        color: Style.current.blue
        //% "Decline"
        text: qsTrId("decline")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        padding: Style.current.halfPadding
        anchors.top: separator2.bottom
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                if (root.state === Constants.addressRequested) {
                    chatsModel.transactions.declineAddressRequest(messageId)
                } else if (root.state === Constants.transactionRequested) {
                    chatsModel.transactions.declineRequest(messageId)
                }

            }
        }
    }

    Loader {
        id: signTransactionModal
        function open() {
            this.active = true
            this.item.open()
        }
        function closed() {
            this.active = false // kill an opened instance
        }
        sourceComponent: SignTransactionModal {
            onOpened: {
                walletModel.getGasPricePredictions()
            }
            onClosed: {
                signTransactionModal.closed()
            }
            selectedAccount: {}
            selectedRecipient: {
                return {
                    address: commandParametersObject.address,
                    identicon: chatsModel.activeChannel.identicon,
                    name: chatsModel.activeChannel.name,
                    type: RecipientSelector.Type.Contact
                }
            }
            selectedAsset: token
            selectedAmount: tokenAmount
            selectedFiatAmount: fiatValue
        }
    }

    SelectAccountModal {
        id: selectAccountModal
        onSelectAndShareAddressButtonClicked: {
            chatsModel.transactions.acceptAddressRequest(messageId, accountSelector.selectedAccount)
            selectAccountModal.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
