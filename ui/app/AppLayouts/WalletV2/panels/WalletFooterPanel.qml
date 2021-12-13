import QtQuick 2.14
import QtQuick.Controls 2.14

import utils 1.0
import "../controls"
import "../popups"

Item {
    id: walletFooterRoot
    height: 50
    width: parent.width
    property var walletV2Model

    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Style.current.separator
    }

    Row {
        anchors.centerIn: parent
        spacing: 50

        WalletButton {
            imageSource: Style.svg("swap-icon")
            text: qsTr("Swap")
            onClicked: {
                console.log("TODO");
            }
        }

        WalletButton {
            imageSource: Style.svg("send")
            text: qsTr("Send")
            onClicked: {
                console.log("TODO");
            }
        }

        WalletButton {
            imageSource: Style.svg("crypto-icon")
            text: qsTr("Buy / Sell")
            onClicked: {
                cryptoServicesModal.open();
            }
        }
    }

    CryptoServicesModal {
        id: cryptoServicesModal
        anchors.centerIn: parent
        // Not Refactored Yet
//        walletV2Model: walletFooterRoot.walletV2Model
    }
}
