import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import mainui 1.0
import utils 1.0

import shared.views 1.0

import Storybook 1.0
import Models 1.0

import AppLayouts.Wallet.views 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Horizontal

    QtObject {
        id: d

        readonly property string networksChainsCurrentlySelected: {
            let supportNwChains = ":"
            for (let i =0; i< networksRepeater.count; i++) {
                if (networksRepeater.itemAt(i).checked && networksRepeater.itemAt(i).visible)
                    supportNwChains +=  networksRepeater.itemAt(i).chainID + ":"
            }
            return supportNwChains
        }

        readonly property string addressesSelected: {
            let supportedAddresses = ""
            let allChecked = true
            let allUnchecked = true
            for (let i =0; i< accountsRepeater.count; i++) {
                if (accountsRepeater.itemAt(i).checked && accountsRepeater.itemAt(i).visible)
                    supportedAddresses +=  accountsRepeater.itemAt(i).address
                allChecked = allChecked && accountsRepeater.itemAt(i).checked
                allUnchecked = allUnchecked && !accountsRepeater.itemAt(i).checked
            }
            if(allChecked || allUnchecked) {
                supportedAddresses = ""
            }
            return supportedAddresses
        }

        readonly property var currencyStore: QtObject {
            property string currentCurrency: "USD"
            function getCurrencyAmount(amount, symbol) {
                return ({
                            amount: amount,
                            symbol: symbol.toUpperCase(),
                            displayDecimals: 2,
                            stripTrailingZeroes: false
                        })
            }
            function getCurrentCurrencyAmount(amount) {
                return ({
                            amount: amount,
                            symbol: "USD",
                            displayDecimals: 2,
                            stripTrailingZeroes: false
                        })
            }
        }

        readonly property var groupedAccountsAssetsModel: GroupedAccountsAssetsModel {}
        readonly property var tokensBySymbolModel: TokensBySymbolModel {}
        readonly property CommunitiesModel communityModel: CommunitiesModel{}

        // Added this here simply because the network and address filtering wont work in Storybook applied in AssetsView
        readonly property SubmodelProxyModel assetsWithFilteredBalances: SubmodelProxyModel {
            sourceModel: d.groupedAccountsAssetsModel
            submodelRoleName: "balances"
            delegateModel: SortFilterProxyModel {
                sourceModel: submodel
                filters: ExpressionFilter {
                    expression: {
                        d.networksChainsCurrentlySelected
                        d.addressesSelected
                        return d.networksChainsCurrentlySelected.split(":").includes(chainId+"") &&
                                (!! d.addressesSelected ?  d.addressesSelected.toUpperCase() === account.toUpperCase() : true)
                    }
                }
            }
        }

        // renaming tokens by symbol key so that can be used to join models
        readonly property var renamedTokensBySymbolModel: RolesRenamingModel {
            sourceModel: d.tokensBySymbolModel
            mapping: [
                RoleRename {
                    from: "key"
                    to: "tokensKey"
                }
            ]
        }

        // join account assets and tokens by symbol model
        property LeftJoinModel jointModel: LeftJoinModel {
            leftModel: d.assetsWithFilteredBalances
            rightModel: d.renamedTokensBySymbolModel
            joinRole: "tokensKey"
        }

        // combining community model with assets to get community meta data
        property LeftJoinModel builtAccountAssetsModel: LeftJoinModel {
            leftModel: d.jointModel
            rightModel: d.communityModel
            joinRole: "communityId"
        }
    }

    Popups {
        popupParent: root
        rootStore: QtObject {}
        communityTokensStore: QtObject {}
    }

    StackLayout {
        id: stack
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        currentIndex: 0

        AssetsView {
            id: assetsView
            Layout.fillHeight: true
            Layout.fillWidth: true
            areAssetsLoading: loadingCheckbox.checked
            assets: d.builtAccountAssetsModel
            filterVisible: ctrlFilterVisible.checked
            currencyStore: d.currencyStore
            networkFilters: d.networksChainsCurrentlySelected
            addressFilters: d.addressesSelected
            onAssetClicked: {
                stack.currentIndex = 1
                detailsView.token = token
                logs.logEvent("onAssetClicked", ["token"], [token.symbol, token.communityId])
            }
            onSendRequested: logs.logEvent("onSendRequested", ["symbol"], arguments)
            onReceiveRequested: logs.logEvent("onReceiveRequested", ["symbol"], arguments)
            onSwitchToCommunityRequested: logs.logEvent("onSwitchToCommunityRequested", ["communityId"], arguments)
            onManageTokensRequested: logs.logEvent("onManageTokensRequested")
        }

        AssetsDetailView {
            id: detailsView
            Layout.fillHeight: true
            Layout.fillWidth: true
            currencyStore: d.currencyStore
            allNetworksModel: NetworksModel.allNetworks
            networkFilters: d.networksChainsCurrentlySelected
            Button {
                anchors.top: parent.top
                text: "go back"
                onClicked: stack.currentIndex = 0
            }
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ColumnLayout {
            spacing: 12
            anchors.fill: parent

            Switch {
                id: ctrlFilterVisible
                text: "Filter visible"
                checked: true
            }

            CheckBox {
                id: loadingCheckbox
                checked: true
                text: "loading"
            }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "select supported network(s)"
                }
                Repeater {
                    id: networksRepeater
                    model: NetworksModel.allNetworks
                    delegate: CheckBox {
                        property int chainID: chainId
                        width: parent.width
                        text: chainName
                        visible: isTest
                        checked: true
                        onToggled: {
                            isEnabled = checked
                        }
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Text {
                    text: "select account(s)"
                }
                Repeater {
                    id: accountsRepeater
                    model: WalletAccountsModel {}
                    delegate: CheckBox {
                        property string address: model.address
                        checked: true
                        visible: index<2
                        width: parent.width
                        text: name
                    }
                }
            }
        }
    }
}

// category: Views
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17159-67977&mode=design&t=s5EXsh6Vi4nTNYUh-0
// https://www.figma.com/file/FkFClTCYKf83RJWoifWgoX/Wallet-v2?type=design&node-id=17171-285559&mode=design&t=s5EXsh6Vi4nTNYUh-0
