import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared 1.0
import shared.panels 1.0
import shared.status 1.0
import "../controls"
import "../stores"

Item {
    id: root

    property string locale: ""
    property string currency: ""
    property var currentAccount
    property var store
    property var walletStore

    implicitHeight: childrenRect.height

    GridLayout {
        width: parent.width
        rowSpacing: Style.current.halfPadding
        columns: 2

        // account + balance
        Row {
            spacing: Style.current.halfPadding
            StatusBaseText {
                objectName: "accountName"
                font.pixelSize: 28
                font.bold: true
                text: currentAccount.name
            }
            StatusBaseText {
                font.pixelSize: 28
                font.bold: true
                color: Theme.palette.baseColor1
                text: "%1 %2".arg(Utils.toLocaleString(root.currentAccount.currencyBalance.toFixed(2), root.locale, {"currency": true})).arg(root.currency.toUpperCase())
            }
        }

        // network filter
        NetworkFilter {
            id: networkFilter
            Layout.alignment: Qt.AlignTrailing
            Layout.fillHeight: true
            Layout.rowSpan: 2
            store: root.walletStore
        }

        StatusAddressPanel {
            address: currentAccount.mixedcaseAddress

            autHideCopyIcon: true
            expanded: false

            onDoCopy: (address) => root.store.copyToClipboard(address)
        }
    }
}
