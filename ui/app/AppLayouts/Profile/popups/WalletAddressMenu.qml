import QtQuick 2.15

import StatusQ.Popups 0.1

import utils 1.0

import AppLayouts.Wallet.popups 1.0

StatusMenu {
    id: root

    property string selectedAddress
    property bool areTestNetworksEnabled: false
    property bool isSepoliaEnabled: false
    property string preferredSharingNetworks
    property var preferredSharingNetworksArray

    signal copyToClipboard(string address)

    function openMenu(delegate) {
        const x = delegate.width - 40
        const y = delegate.height / 2 + 20
        root.popup(delegate, x, y)
    }

    StatusAction {
        id: showOnEtherscanAction
        text: qsTr("View address on Etherscan")
        icon.name: "link"
        onTriggered: {
            let link = Constants.networkExplorerLinks.etherscan
            if (areTestNetworksEnabled) {
                if (root.isSepoliaEnabled) {
                    link = Constants.networkExplorerLinks.sepoliaEtherscan
                } else {
                    link = Constants.networkExplorerLinks.goerliEtherscan
                }
            }
            
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAddress))
        }
    }
    StatusAction {
        id: showOnArbiscanAction
        text: qsTr("View address on Arbiscan")
        icon.name: "link"
        onTriggered: {
            const link = areTestNetworksEnabled ? Constants.networkExplorerLinks.goerliArbiscan : Constants.networkExplorerLinks.arbiscan
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAddress))
        }
    }
    StatusAction {
        id: showOnOptimismAction
        text: qsTr("View address on Optimism Explorer")
        icon.name: "link"
        onTriggered: {
            const link = areTestNetworksEnabled ? Constants.networkExplorerLinks.goerliOptimistic : Constants.networkExplorerLinks.optimistic
            Global.openLink("%1/%2/%3".arg(link).arg(Constants.networkExplorerLinks.addressPath).arg(root.selectedAddress))
        }
    }
    StatusSuccessAction {
        id: copyAddressAction
        successText:  qsTr("Address copied")
        text: qsTr("Copy address")
        icon.name: "copy"
        onTriggered: root.copyToClipboard(root.selectedAddress)
    }
    StatusAction {
        id: showQrAction
        text: qsTr("Show address QR")
        icon.name: "qr"
        onTriggered: Global.openPopup(addressQr)
    }

    Component {
        id: addressQr
        ReceiveModal {
            anchors.centerIn: parent
            address: root.selectedAddress
            chainShortNames: root.preferredSharingNetworks
            preferredSharingNetworksArray: root.preferredSharingNetworksArray
            readOnly: true
            hasFloatingButtons: false
            advancedHeaderComponent: null
            description: qsTr("Address")
            onClosed: destroy()
        }
    }
}
