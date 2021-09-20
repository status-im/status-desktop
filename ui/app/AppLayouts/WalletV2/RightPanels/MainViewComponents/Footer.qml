import QtQuick 2.14
import QtQuick.Controls 2.14
import "../../../../../imports"
import "../../components" as WalletComponents

Item {
    id: walletFooterRoot
    height: 50
    width: parent.width

    Rectangle {
        id: separatorLine
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 1
        color: Style.current.separator
    }

    Row {

        anchors.centerIn: parent
        spacing: 50

        WalletComponents.Button {
            id: swapBtn
            imageSource: "../../../../img/swap-icon.svg"
            text: qsTr("Swap")
            onClicked: function (){
            }
        }

        WalletComponents.Button {
            id: sendBtn
            imageSource: "../../../../img/send.svg"
            text: qsTr("Send")
            onClicked: function (){
            }
        }

        WalletComponents.Button {
            id: buySellBtn
            imageSource: "../../../../img/crypto-icon.svg"
            text: qsTr("Buy / Sell")
            onClicked: function (){
                cryptoServicesModal.open()
            }
        }
    }

    WalletComponents.CryptoServicesModal {
        id: cryptoServicesModal
    }
}
