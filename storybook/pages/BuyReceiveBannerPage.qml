import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.panels 1.0

import StatusQ.Core.Theme 0.1

SplitView {
    id: root
    Pane {
        id: leftPane
        SplitView.fillWidth: true
        SplitView.fillHeight: true
        BuyReceiveBanner {
            id: banner
            anchors.centerIn: parent
            width: leftPane.width
            closeEnabled: closeEnabled.checked
            buyEnabled: buyEnabled.checked
            receiveEnabled: receiveEnabled.checked
            onBuyClicked: {
                print("Buy clicked")
            }
            onReceiveClicked: {
                print("Receive clicked")
            }
            onCloseBuy: {
                buyEnabled.checked = false
            }
            onCloseReceive: {
                receiveEnabled.checked = false
            }
            onAnyVisibleItemsChanged: {
                print("Any visible: ", anyVisibleItems)
            }
        }
    }
    Pane {
        id: rightPane
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: "Any visible items"
            }
            Rectangle {
                width: 30
                height: 30
                radius: 15
                color: banner.anyVisibleItems ? "green" : "red"
            }
            CheckBox {
                id: closeEnabled
                text: "Show close button"
                checked: true
            }
            CheckBox {
                id: buyEnabled
                text: "Show buy button"
                checked: false
            }
            CheckBox {
                id: receiveEnabled
                text: "Show receive button"
                checked: false
            }
            Item {
                Layout.fillHeight: true
            }
        }
    }
}