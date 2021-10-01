import QtQuick 2.3

import utils 1.0
import "../../../../shared"
import "../../../../shared/panels"
import "../popups"

Item {
    id: root
    width: parent.width
    height: childrenRect.height + Style.current.halfPadding

    property var acc
    property string fromAddress
    property var selectedRecipient
    property var selectedAsset
    property string selectedAmount
    property string selectedFiatAmount

    signal signModalOpened()
    signal sendTransaction(string address)

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
                root.clicked(root.fromAddress);
                //TODO remove dynamic scoping
                openPopup(signTxComponent, {selectedAccount: {
                                  name: root.acc.name,
                                  address: root.fromAddress,
                                  iconColor: root.acc.iconColor,
                                  assets: root.acc.assets
                              }})
            }
        }
    }

    Component {
        id: signTxComponent
        SignTransactionModal {
            selectedAsset: root.selectedAsset
            selectedAmount: root.selectedAmount
            selectedRecipient: root.selectedRecipient
            selectedFiatAmount: root.selectedFiatAmount
            onOpened: {
                root.signModalOpened();
            }
            onClosed: {
                destroy();
            }
        }
    }
}
