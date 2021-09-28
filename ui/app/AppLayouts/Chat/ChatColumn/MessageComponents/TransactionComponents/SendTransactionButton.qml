import QtQuick 2.3
import "../../../../../../shared"

import utils 1.0
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
        //% "Sign and send"
        text: qsTrId("sign-and-send")
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
                walletModel.accountsView.setFocusedAccountByAddress(commandParametersObject.fromAddress)
                var acc = walletModel.accountsView.focusedAccount
                openPopup(signTxComponent, {selectedAccount: {
                                  name: acc.name,
                                  address: commandParametersObject.fromAddress,
                                  iconColor: acc.iconColor,
                                  assets: acc.assets
                              }})
            }
        }
    }

    Component {
        id: signTxComponent
        SignTransactionModal {
            onOpened: {
                walletModel.gasView.getGasPrice()
            }
            onClosed: {
                destroy();
            }
            selectedRecipient: {
                return {
                    address: commandParametersObject.address,
                    identicon: chatsModel.channelView.activeChannel.identicon,
                    name: chatsModel.channelView.activeChannel.name,
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

