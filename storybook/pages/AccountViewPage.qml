import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Profile.views.wallet 1.0

import StatusQ.Core.Theme 0.1

import utils 1.0

import Storybook 1.0

import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d
        readonly property string emptyString: ""

        property var dummyOverview: updateDummyView(StatusColors.colors['black'])

        function updateDummyView(color) {
            const clr = Utils.getIdForColor(color)
            dummyOverview = ({
                                 name: "helloworld",
                                 address: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                 ens: emptyString,
                                 colorId: clr,
                                 emoji: "⚽",
                                 balanceLoading: false,
                                 hasBalanceCache: true,
                                 balance: ({amount: 1.25,
                                               symbol: "USD",
                                               displayDecimals: 4,
                                               stripTrailingZeroes: false}),
                                 isAllAccounts: false,
                                 path: "m/44’/60’/0’/0’/34",
                                 preferredSharingChainIds:  walletStore.areTestNetworksEnabled ? "5:420:421613": "1:10:42161"
                             })
        }

        readonly property QtObject connectionStore: QtObject {
            property bool accountBalanceNotAvailable: false
        }

        readonly property QtObject walletStore: QtObject {
            property var networks: NetworksModel.mainNetworks
            property bool areTestNetworksEnabled: areTestNetworksEnabledCheckbox.checked
            function toggleNetwork(chainId) {
            }

            function getNetworkShortNames() {
                return "eth:opt:arb:"
            }

            function getAllNetworksChainIds() {
                return "1:10:42161"
            }

            function updateWalletAccountPreferredChains(address, preferredChainIds) {
                console.warn("updateWalletAccountPreferredChains :: address ::", address, "preferredChainIds :: ", preferredChainIds)
            }

            function processPreferredSharingNetworkToggle(preferredSharingNetworksArray, network) {
                console.warn("processPreferredSharingNetworkToggle :: preferredSharingNetworksArray ::", preferredSharingNetworksArray, "network :: ", network)
            }
        }

        property var keyPairModel: WalletKeyPairModel {}
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        AccountView {
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            width: 560
            account: d.dummyOverview
            walletStore: d.walletStore
            keyPair: d.keyPairModel.data[0].keyPair
            onUpdateWatchAccountHiddenFromTotalBalance: {
                console.warn("updateWatchAccountHiddenFromTotalBalance :: address ::", address, "hideFromTotalBalance :: ", hideFromTotalBalance)
            }
        }
    }  

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        CheckBox {
            id: areTestNetworksEnabledCheckbox
            text: "areTestNetworksEnabled"
            checked: false
        }
    }
}

// category: Views
