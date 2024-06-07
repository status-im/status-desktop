import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0

import SortFilterProxyModel 0.2

import shared.controls 1.0

Item {
    id: root

    ColumnLayout {
        spacing: 16
        anchors.centerIn: parent
        implicitWidth: 150


        WalletAccountsModel {
            id: accountsModel
        }

        Label {
            text: "Default style"
            font.bold: true
            Layout.fillWidth: true
        }
        AccountSelector {
            id: accountSelector
            Layout.fillWidth: true
            model: WalletAccountsModel {}
            onCurrentAccountAddressChanged: {
                accountSelector2.selectedAddress = currentAccountAddress
            }
        }

        Label {
            text: "Header style"
            font.bold: true
            Layout.fillWidth: true
        }
        AccountSelectorHeader {
            id: accountSelector2
            model: accountSelector.model
            onCurrentAccountAddressChanged: {
                accountSelector.selectedAddress = currentAccountAddress
            }
        }
    
    }    
}

// category: Components
