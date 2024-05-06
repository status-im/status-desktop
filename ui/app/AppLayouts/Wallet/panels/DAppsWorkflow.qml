import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import AppLayouts.Wallet.controls 1.0

import shared.popups.walletconnect 1.0
import AppLayouts.Wallet.services.dapps 1.0

import shared.stores 1.0

ConnectedDappsButton {
    id: root

    required property WalletConnectService wcService

    signal dAppsListReady()
    signal pairWCReady()

    onClicked: {
        dappsListLoader.active = true
    }

    highlighted: dappsListLoader.active

    Loader {
        id: pairWCLoader

        active: false

        onLoaded: {
            item.open()
            root.pairWCReady()
        }

        sourceComponent: PairWCModal {
            visible: true

            onClosed: pairWCLoader.active = false

            onPair: (uri) => {
                this.close()
                root.wcService.pair(uri)
            }
        }
    }

    Loader {
        id: dappsListLoader

        active: false

        onLoaded: {
            item.open()
            root.dAppsListReady()
        }

        sourceComponent: DAppsListPopup {
            visible: true

            onPairWCDapp: {
                pairWCLoader.active = true
                this.close()
            }
            onOpened: {
                this.x = root.width - this.menuWidth - 2 * this.padding
                this.y = root.height + 4
            }
            onClosed: dappsListLoader.active = false
        }
    }

    Loader {
        id: connectDappLoader

        active: false

        onLoaded: item.openWithFilter(filterChains, filterAccounts, proposer)

        property var filterChains: []
        property var filterAccounts: []
        property var proposer: null

        sourceComponent: ConnectDAppModal {
            visible: true

            onClosed: connectDappLoader.active = false
        }
    }

    Connections {
        target: root.wcService

        function onConnectDApp(chains, accounts, proposer) {
            connectDappLoader.filterChains = chains
            connectDappLoader.filterAccounts = accounts
            connectDappLoader.proposer = proposer
            connectDappLoader.active = true
        }
    }
}
