import QtQuick 2.3

import shared 1.0
import shared.popups 1.0
import shared.panels 1.0
import shared.controls 1.0

import "../popups"

import utils 1.0

//TODO remove dynamic scoping
Item {
    id: root
    width: parent.width
    height: childrenRect.height

    property var store
    property int state: Constants.addressRequested

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
                    openPopup(signTxComponent)
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
                    root.store.chatsModelInst.transactions.declineAddressRequest(messageId)
                } else if (root.state === Constants.transactionRequested) {
                    root.store.chatsModelInst.transactions.declineRequest(messageId)
                }

            }
        }
    }

    ConfirmationDialog {
        id: gasEstimateErrorPopup
        height: 220
        onConfirmButtonClicked: {
            gasEstimateErrorPopup.close();
        }
    }

    Component {
        id: signTxComponent
        SignTransactionModal {
            store: root.store
            onOpened: {
                root.store.walletModelInst.gasView.getGasPrice()
            }
            onClosed: {
                destroy();
            }
            selectedAccount: {}
            selectedRecipient: {
                return {
                    address: commandParametersObject.address,
                    identicon: root.store.chatsModelInst.channelView.activeChannel.identicon,
                    name: root.store.chatsModelInst.channelView.activeChannel.name,
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
        accounts: root.store.walletModelInst.accountsView.accounts
        currency: root.store.walletModelInst.balanceView.defaultCurrency
        onSelectAndShareAddressButtonClicked: {
            root.store.chatsModelInst.transactions.acceptAddressRequest(messageId, accountSelector.selectedAccount.address)
            selectAccountModal.close()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/
