import QtQuick 2.14
import QtQuick.Controls 2.14
import "../../../../imports"
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
            imageSource: "../../../img/swap-icon.svg"
            text: qsTr("Swap")
            onClicked: {
                console.log("TODO");
            }
        }

        WalletButton {
            imageSource: "../../../img/send.svg"
            text: qsTr("Send")
            onClicked: {
                console.log("TODO");
            }
        }

        WalletButton {
            imageSource: "../../../img/crypto-icon.svg"
            text: qsTr("Buy / Sell")
            onClicked: {
                cryptoServicesModal.open();
            }
        }
    }

    CryptoServicesModal {
        id: cryptoServicesModal
        anchors.centerIn: parent
        walletV2Model: walletFooterRoot.walletV2Model
    }
}
