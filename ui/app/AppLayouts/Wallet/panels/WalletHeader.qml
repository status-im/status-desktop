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

    property string currency: ""
    property var currentAccount
    property var store
    property var walletStore

    implicitHeight: 88

    GridLayout {
        width: parent.width
        columns: 2

        // account + balance
        RowLayout {
            Layout.preferredHeight: 56
            spacing: Style.current.halfPadding
            StatusBaseText {
                objectName: "accountName"
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 28
                font.bold: true
                text: currentAccount.name
            }
            StatusBaseText {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 28
                font.bold: true
                color: Theme.palette.baseColor1
                text: LocaleUtils.currencyAmountToLocaleString(root.currentAccount.currencyBalance)
            }
        }

        // network filter
        NetworkFilter {
            id: networkFilter
            Layout.alignment: Qt.AlignTrailing
            Layout.rowSpan: 2
            store: root.walletStore
        }

        StatusAddressPanel {
            objectName: "addressPanel"
            value: currentAccount.ens || currentAccount.mixedcaseAddress
            ens: !!currentAccount.ens
            autHideCopyIcon: true
            expanded: false

            onDoCopy: () => root.store.copyToClipboard(currentAccount.mixedcaseAddress)
        }
    }
}
