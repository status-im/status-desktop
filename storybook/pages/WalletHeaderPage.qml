import QtQuick
import QtQuick.Controls

import SortFilterProxyModel

import AppLayouts.Wallet.panels
import AppLayouts.Wallet.controls
import AppLayouts.Chat.panels
import AppLayouts.Wallet.stores as WalletStores

import StatusQ.Core.Theme
import StatusQ.Controls

import shared.stores as SharedStores
import utils

import Storybook
import Models

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    property bool globalUtilsReady: false
    property bool mainModuleReady: false

    SharedStores.NetworkConnectionStore {
        id: connectionStore

        property bool accountBalanceNotAvailable: false
    }

    // TODO: WalletStores.RootStore is singleton and therefore it's not mockable
    // Once store is converted to regular, non-singleton store it can be mocked as follows
    // WalletStores.RootStore {
    //     id: walletStore

    //     property var filteredFlatModel: SortFilterProxyModel {
    //         sourceModel: NetworksModel.flatNetworks
    //         filters: ValueFilter { roleName: "isTest"; value: false }
    //     }
    //     function toggleNetwork(chainId) {
    //         print ("toggleNetwork called with chainId: " + chainId)
    //     }

    //     function getAllNetworksSupportedString(hovered) {
    //         return hovered ?  "<font color=\"" + "#627EEA" + "\">" + "eth:" + "</font>" +
    //                          "<font color=\"" + "#E90101" + "\">" + "oeth:" + "</font>" +
    //                          "<font color=\"" + "#27A0EF" + "\">" + "arb1:" + "</font>" : "eth:oeth:arb1:"
    //     }
    // }

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
                                 currencyBalance: ({amount: 1.25,
                                                       symbol: "USD",
                                                       displayDecimals: 4,
                                                       stripTrailingZeroes: false}),
                                 isAllAccounts: false,
                             })
        }

        property var dummyAllAccountsOverview:({
                                                   name: "",
                                                   mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                                   ens: emptyString,
                                                   colorId: "",
                                                   emoji: "",
                                                   balanceLoading: false,
                                                   currencyBalance: ({amount: 1.25,
                                                                         symbol: "USD",
                                                                         displayDecimals: 4,
                                                                         stripTrailingZeroes: false}),
                                                   isAllAccounts: true,
                                                   colorIds: "purple;pink;magenta"
                                               })
        property SharedStores.NetworksStore networksStore: SharedStores.NetworksStore {
            function toggleNetwork(chainId) {
                print ("toggleNetwork called with chainId: " + chainId)
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
                    networkConnectionStore: connectionStore
                    overview: allAccountsCheckbox.checked ? d.dummyAllAccountsOverview :  d.dummyOverview
                    walletStore: walletStore
                    networksStore: d.networksStore
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

// category: Wallet
