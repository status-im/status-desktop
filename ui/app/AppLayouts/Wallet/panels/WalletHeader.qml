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

    property var networkConnectionStore
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
            StatusTextWithLoadingState {
                Layout.alignment: Qt.AlignVCenter
                font.pixelSize: 28
                font.bold: true
                customColor: Theme.palette.baseColor1
                text: loading ? Constants.dummyText : LocaleUtils.currencyAmountToLocaleString(root.currentAccount.currencyBalance)
                loading: root.currentAccount.assetsLoading
                visible: !networkConnectionStore.tokenBalanceNotAvailable
            }
        }

        // network filter
        NetworkFilter {
            id: networkFilter
            Layout.alignment: Qt.AlignTrailing
            Layout.rowSpan: 2
            layer1Networks: walletStore.layer1Networks
            layer2Networks: walletStore.layer2Networks
            testNetworks: walletStore.testNetworks
            enabledNetworks: walletStore.enabledNetworks
            allNetworks: walletStore.allNetworks

            onToggleNetwork: walletStore.toggleNetwork(chainId)
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
