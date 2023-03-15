import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../popups"
import "../controls"

Rectangle {
    id: walletFooter

    property var sendModal
    property var walletStore
    property var networkConnectionStore

    height: 61
    color: Theme.palette.statusAppLayout.rightPanelBackgroundColor

    StatusModalDivider {
        anchors.top: parent.top
        width: parent.width
    }

    RowLayout {
        anchors.centerIn: parent
        height: parent.height
        spacing:  Style.current.padding

        FooterTooltipButton {
            button.objectName: "walletFooterSendButton"
            button.icon.name: "send"
            button.text: qsTr("Send")
            button.enabled: networkConnectionStore.sendBuyBridgeEnabled
            button.onClicked: function() {
                sendModal.open()
            }
            tooltipText: networkConnectionStore.sendBuyBridgeToolTipText
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            onClicked: function () {
                Global.openPopup(receiveModalComponent);
            }
        }

        FooterTooltipButton {
            button.icon.name: "bridge"
            button.text: qsTr("Bridge")
            button.enabled: networkConnectionStore.sendBuyBridgeEnabled
            button.onClicked: function() {
                sendModal.isBridgeTx = true
                sendModal.open()
            }
            tooltipText: networkConnectionStore.sendBuyBridgeToolTipText
        }
        
        StatusFlatButton {
            id: buySellBtn
            icon.name: "token"
            text: qsTr("Buy")
            onClicked: function () {
                Global.openPopup(buySellModal);
            }
        }
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            selectedAccount: walletStore.currentAccount
            anchors.centerIn: parent
        }
    }

    Component {
        id: buySellModal
        CryptoServicesModal {}
    }
}


