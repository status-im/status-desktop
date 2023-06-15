import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.popups 1.0
import AppLayouts.Wallet.panels 1.0
import AppLayouts.Wallet.stores 1.0
import AppLayouts.stores 1.0

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import SortFilterProxyModel 0.2

import Storybook 1.0

import Models 1.0

import utils 1.0

import shared.controls 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d
        property var recipeintModel: RecipientModel {}

        property var store: QtObject {
            property var overview: ({
                                        name: "helloworld",
                                        mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                        ens: "",
                                        color: color,
                                        emoji: "⚽",
                                        balanceLoading: false,
                                        hasBalanceCache: true,
                                        currencyBalance: ({amount: 1.25,
                                                              symbol: "USD",
                                                              displayDecimals: 4,
                                                              stripTrailingZeroes: false}),
                                        isAllAccounts: false,
                                        hideWatchAccounts: false

                                    })

            function getNameForAddress(address) {
                return ""
            }
        }

        property var activityController: QtObject {
            function setFilterTime(fromTimestamp, toTimestamp) {
                console.warn("activityController:: setFilterTime:: fromTimestamp: ",fromTimestamp, " toTimestamp:: ",toTimestamp)
            }
            function setFilterType(typeFilters) {
                console.warn("activityController:: setFilterType:: ",typeFilters)
            }
            function setFilterStatus(statusFilters) {
                console.warn("activityController:: setFilterStatus:: ",statusFilters)
            }
            function setFilterAssets(tokensFilter) {
                console.warn("activityController:: setFilterAssets:: ",tokensFilter)
            }
            function setFilterToAddresses(filters) {
                console.warn("activityController:: setFilterToAddresses:: ",filters)
            }
            function updateFilter() {
                console.warn("activityController:: updateFilter")
            }
        }
    }
    ActivityFiltersStore {
        id: actvityStore
        tokensList: WalletAssetsModel {}
        collectiblesList: CollectiblesModel {}
        savedAddressesModel: d.recipeintModel.savedAddresses
        activityController: d.activityController
        areTestNetworksEnabled: false
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        ActivityFilterPanel {
            id: filterComponent
            width: 800
            anchors.centerIn: parent
            store: d.store
            activityFilterStore: actvityStore
        }
    }
}
