import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Popups 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import "../popups"

Rectangle {
    id: walletFooter

    property var sendModal

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

        StatusFlatButton {
            icon.name: "send"
            text: qsTr("Send")
            onClicked: function() {
                sendModal.open()
            }
        }

        StatusFlatButton {
            icon.name: "receive"
            text: qsTr("Receive")
            onClicked: function () {
                Global.openPopup(receiveModalComponent);
            }
        }

        StatusFlatButton {
            id: buySellBtn
            icon.name: "token"
            text: qsTr("Buy / Sell")
            onClicked: function () {
                Global.openPopup(buySellModal);
            }
        }
    }

    Component {
        id: receiveModalComponent
        ReceiveModal {
            selectedAccount: walletHeader.walletStore.currentAccount
            anchors.centerIn: parent
        }
    }

    Component {
        id: buySellModal
        CryptoServicesModal {}
    }
}


