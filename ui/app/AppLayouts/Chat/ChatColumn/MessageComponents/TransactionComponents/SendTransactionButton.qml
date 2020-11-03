import QtQuick 2.3
import "../../../../../../shared"
import "../../../../../../imports"
import "../../ChatComponents"

Item {
    id: root
    width: parent.width
    height: childrenRect.height + Style.current.halfPadding

    Separator {
        id: separator
    }

    StyledText {
        id: signText
        color: Style.current.blue
        text: qsTr("Sign and send")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        topPadding: Style.current.halfPadding
        anchors.top: separator.bottom
        font.pixelSize: 15

        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: {
                walletModel.setFocusedAccountByAddress(commandParametersObject.fromAddress)
                var acc = walletModel.focusedAccount
                signTransactionModal.selectedAccount = {
                    name: acc.name,
                    address: commandParametersObject.fromAddress,
                    iconColor: acc.iconColor,
                    assets: acc.assets
                }
                signTransactionModal.open()
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
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/

