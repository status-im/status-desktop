import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import StatusQ
import StatusQ.Controls
import StatusQ.Core
import StatusQ.Core.Theme

import shared.controls
import shared.views
import shared.stores as SharedStores
import utils

import AppLayouts.Browser.stores as BrowserStores

// TODO: replace with StatusMenu
Dialog {
    id: root

    required property bool currentTabConnected
    required property BrowserStores.BrowserWalletStore browserWalletStore

    signal sendTriggered(string address)
    signal disconnect()
    signal reload()
    signal accountChanged(string newAddress)

    modal: false

    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    parent: Overlay.overlay
    width: 360
    height: 480
    background: Rectangle {
        id: bgPopup
        color: Theme.palette.background
        radius: Theme.radius
        layer.enabled: true
        layer.effect: DropShadow {
            width: bgPopup.width
            height: bgPopup.height
            x: bgPopup.x
            y: bgPopup.y + 10
            visible: bgPopup.visible
            source: bgPopup
            horizontalOffset: 0
            verticalOffset: 5
            radius: 10
            samples: 15
            color: Theme.palette.dropShadow
        }
    }
    padding: Theme.padding

    Item {
        id: walletHeader
        width: parent.width
        height: disconnectBtn.height

        // TODO: Uncomment and connect to connector in next PR
        // Network indicator showing current chain
        /*
        Rectangle {
            id: networkColorCircle
            width: 8
            height: 8
            radius: width / 2
            color: {
                // TODO: Get chainId from connectorBridge instead of web3ProviderStore
                // Example: connectorBridge.chainId
                switch (root.web3ProviderStore.chainName) {
                    case Constants.networkMainnet: return Theme.palette.successColor1
                    case Constants.networkRopsten: return Theme.palette.mentionColor1
                    default: return Theme.palette.warningColor1
                }
            }
            anchors.verticalCenter: parent.verticalCenter
        }

        StatusBaseText {
            id: networkText
            text: {
                // TODO: Get chainId from connectorBridge and map to chainName
                // Example: getChainName(connectorBridge.chainId)
                switch (root.web3ProviderStore.chainName) {
                    case Constants.networkMainnet: return qsTr("Mainnet");
                    case Constants.networkRopsten: return qsTr("Ropsten");
                    default: return qsTr("Unknown")
                }
            }
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: networkColorCircle.right
            anchors.leftMargin: Theme.halfPadding
            color: Theme.palette.directColor1
            font.pixelSize: 13
        }
        */

        StatusBaseText {
            id: disconnectBtn
            text: qsTr("Disconnect")
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right
            color: Theme.palette.dangerColor1
            visible: root.currentTabConnected

            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked: disconnect()
            }
        }
    }


    Connections {
        target: root.browserWalletStore.dappBrowserAccount
        function onConnectedAccountDeleted() {
            root.reload()
            // This is done because when an account is deleted and the account is updated to default one,
            // only the properties are updated and we need to listen to those events and update the selected account
            accountSelectorRow.currentAddress = ""
            accountSelector.selectedAddress = Qt.binding(function () {return root.browserWalletStore.dappBrowserAccount.address})
        }
    }

    Connections {
        target: root.browserWalletStore.transactionActivityStatus
        enabled: root.visible
        function onIsFilterDirtyChanged() {
            root.browserWalletStore.updateTransactionFilterIfDirty()
        }
        function onFilterChainsChanged() {
            root.browserWalletStore.currentActivityFiltersStore.updateCollectiblesModel()
            root.browserWalletStore.currentActivityFiltersStore.updateRecipientsModel()
        }
    }

    Item {
        property string currentAddress: ""
        id: accountSelectorRow
        width: parent.width
        height: accountSelector.height
        anchors.top: walletHeader.bottom
        anchors.topMargin: Theme.bigPadding

        AccountSelector {
            id: accountSelector
            anchors.left: parent.left
            anchors.right: copyBtn.left
            anchors.rightMargin: Theme.padding
            model: root.browserWalletStore.accounts
            selectedAddress: root.browserWalletStore.dappBrowserAccount.address
            onCurrentAccountAddressChanged: {
                if (!accountSelectorRow.currentAddress) {
                    // We just set the account for the first time. Nothing to do here
                    accountSelectorRow.currentAddress = currentAccountAddress
                    return
                }
                if (accountSelectorRow.currentAddress === currentAccountAddress) {
                    return
                }

                accountSelectorRow.currentAddress = currentAccountAddress
                root.browserWalletStore.switchAccountByAddress(currentAccountAddress)
                root.accountChanged(currentAccountAddress)

                // Update activity filter for new account
                root.browserWalletStore.activityController.setFilterAddressesJson(
                    JSON.stringify([currentAccountAddress])
                )
                // Start new session for the new account
                root.browserWalletStore.activityController.newFilterSession()

                reload()
            }
        }

        CopyToClipBoardButton {
            id: copyBtn
            width: 20
            height: 20
            anchors.right: sendBtn.left
            anchors.rightMargin: Theme.padding
            anchors.top: parent.top
            anchors.topMargin: Theme.padding
            color: Theme.palette.transparent
            textToCopy: accountSelector.currentAccountAddress
            onCopyClicked: ClipboardUtils.setText(textToCopy)
        }

        StatusFlatRoundButton {
            id: sendBtn
            width: 40
            height: 40
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.topMargin: Theme.halfPadding
            icon.name: "send"
            onClicked: sendTriggered(accountSelector.currentAccountAddress)
        }
    }

    Loader {
        id: historyLoader
        width: parent.width
        anchors.top: accountSelectorRow.bottom
        anchors.topMargin: Theme.bigPadding
        anchors.bottom: parent.bottom
        active: false

        sourceComponent: HistoryView {
            id: walletInfoContent
            width: parent.width

            walletRootStore: root.browserWalletStore
            overview: root.browserWalletStore.dappBrowserAccount
            communitiesStore: null
            currencyStore: SharedStores.CurrenciesStore {}
            networksStore: SharedStores.NetworksStore {}
            showAllAccounts: false
            displayValues: true
            filterVisible: false
            disableShadowOnScroll: true
            hideVerticalScrollbar: false
        }
    }

    Component.onCompleted: {
        console.log("==== Browser: Dialog completed, initializing activity controller")

        // Get networksStore from a temporary instance
        const tempNetworksStore = Qt.createQmlObject('import shared.stores 1.0; NetworksStore {}', root)
        const activeChainIds = ModelUtils.modelToArray(tempNetworksStore.activeNetworks, "chainId")
        console.log("==== Browser: activeChainIds =", JSON.stringify(activeChainIds))

        if (activeChainIds.length > 0) {
            root.browserWalletStore.activityController.setFilterChainsJson(JSON.stringify(activeChainIds), true)
        }

        if (root.browserWalletStore.dappBrowserAccount.address) {
            console.log("==== Browser: Setting address filter:", root.browserWalletStore.dappBrowserAccount.address)
            root.browserWalletStore.activityController.setFilterAddressesJson(
                JSON.stringify([root.browserWalletStore.dappBrowserAccount.address])
            )
        }

        console.log("==== Browser: Starting new filter session")
        root.browserWalletStore.activityController.newFilterSession()

        // Now load the HistoryView
        console.log("==== Browser: Loading HistoryView")
        historyLoader.active = true

        tempNetworksStore.destroy()
    }
    onClosed: {
        root.destroy();
    }
}
