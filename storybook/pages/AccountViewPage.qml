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
                                 includeWatchOnly: false,
                                 path: "m/44’/60’/0’/0’/34"
                             })
        }

        readonly property QtObject connectionStore: QtObject {
            property bool accountBalanceNotAvailable: false
        }

        readonly property QtObject walletStore: QtObject {
            property var allNetworks: enabledNetworks
            property var layer1Networks: NetworksModel.layer1Networks
            property var layer2Networks: NetworksModel.layer2Networks
            property var testNetworks: NetworksModel.testNetworks
            property var enabledNetworks: NetworksModel.enabledNetworks
            function toggleNetwork(chainId) {
            }

            function getAllNetworksSupportedPrefix(hovered) {
                return hovered ?  "<font color=\"" + "#627EEA" + "\">" + "eth:" + "</font>" +
                                 "<font color=\"" + "#E90101" + "\">" + "opt:" + "</font>" +
                                 "<font color=\"" + "#27A0EF" + "\">" + "arb:" + "</font>" : "eth:opt:arb:"
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
        }
    }  
}
