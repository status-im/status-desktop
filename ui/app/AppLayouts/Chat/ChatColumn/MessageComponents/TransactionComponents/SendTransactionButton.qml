import QtQuick 2.3
import "../../../../../../shared"
import "../../../../../../imports"
import "../../ChatComponents"

Item {
    width: parent.width
    height: childrenRect.height + Style.current.halfPadding

    Separator {
        id: separator
    }

    StyledText {
        id: signText
        color: Style.current.blue
        //% "Sign and send"
        text: qsTrId("sign-and-send")
        horizontalAlignment: Text.AlignHCenter
        wrapMode: Text.WordWrap
        font.weight: Font.Medium
        anchors.right: parent.right
        anchors.left: parent.left
        topPadding: Style.current.halfPadding
        anchors.top: separator.bottom
        font.pixelSize: Style.current.primaryTextFontSize

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

    SignTransactionModal {
        id: signTransactionModal
        onOpened: {
          walletModel.getGasPricePredictions()
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
        selectedAsset: {
            return {
                name: token.name,
                symbol: token.symbol,
                address: commandParametersObject.contract
            }
        }
        selectedAmount: tokenAmount
        selectedFiatAmount: fiatValue
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";formeditorZoom:1.25}
}
##^##*/

