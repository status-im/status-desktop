import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.controls 1.0
import AppLayouts.Chat.panels 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1

import utils 1.0

import Storybook 1.0

import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    // globalUtilsInst mock
    QtObject {
        id: d

        Component.onCompleted: {
            Utils.globalUtilsInst = this
            root.globalUtilsReady = true
        }
        Component.onDestruction: {
            root.globalUtilsReady = false
            Utils.globalUtilsInst = {}
        }

        readonly property string emptyString: ""

        property var dummyOverview: updateDummyView(StatusColors.colors['black'])

        function updateDummyView(color) {
            const clr = Utils.getIdForColor(color)
            dummyOverview = ({
                                 name: "helloworld",
                                 mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                 ens: emptyString,
                                 colorId: clr,
                                 emoji: "⚽",
                                 balanceLoading: false,
                                 hasBalanceCache: true,
                                 currencyBalance: ({amount: 1.25,
                                                       symbol: "USD",
                                                       displayDecimals: 4,
                                                       stripTrailingZeroes: false}),
                                 isAllAccounts: false,
                                 includeWatchOnly: false
                             })
        }

        property var dummyAllAccountsOverview:({
                                                   name: "",
                                                   mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                                   ens: emptyString,
                                                   colorId: "",
                                                   emoji: "",
                                                   balanceLoading: false,
                                                   hasBalanceCache: true,
                                                   currencyBalance: ({amount: 1.25,
                                                                         symbol: "USD",
                                                                         displayDecimals: 4,
                                                                         stripTrailingZeroes: false}),
                                                   isAllAccounts: true,
                                                   includeWatchOnly: true,
                                                   colorIds: "purple;pink;magenta"
                                               })

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

            function getAllNetworksSupportedString(hovered) {
                return hovered ?  "<font color=\"" + "#627EEA" + "\">" + "eth:" + "</font>" +
                                 "<font color=\"" + "#E90101" + "\">" + "opt:" + "</font>" +
                                 "<font color=\"" + "#27A0EF" + "\">" + "arb:" + "</font>" : "eth:opt:arb:"
            }
        }
    }

    // mainModuleInst mock
    QtObject {
        function getContactDetailsAsJson(publicKey, getVerificationRequest) {
            return JSON.stringify({ ensVerified: false })
        }
        Component.onCompleted: {
            Utils.mainModuleInst = this
            root.mainModuleReady = true
        }
        Component.onDestruction: {
            root.mainModuleReady = false
            Utils.mainModuleInst = {}
        }
    }
    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Item {
            width: 800
            height: 200
            anchors.centerIn: parent

            AccountHeaderGradient {
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                overview: allAccountsCheckbox.checked ? d.dummyAllAccountsOverview :  d.dummyOverview
            }

            Loader {
                anchors.top: parent.top
                anchors.left: parent.left
                width: parent.width
                active: globalUtilsReady && mainModuleReady

                sourceComponent: WalletHeader {
                    networkConnectionStore: d.connectionStore
                    overview: allAccountsCheckbox.checked ? d.dummyAllAccountsOverview :  d.dummyOverview
                    walletStore: d.walletStore
                    width: parent.width
                }
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        Column {
            spacing: 20
            CheckBox {
                id: allAccountsCheckbox
                text: "All Accounts"
                checked: false
            }
            Row {
                spacing: 10
                id: row
                Repeater {
                    id: repeater
                    model: Theme.palette.customisationColorsArray
                    delegate: StatusColorRadioButton {
                        radioButtonColor: modelData
                        checked: index === 0
                        onToggled: d.updateDummyView(modelData)
                    }
                }
            }
        }
    }
}
