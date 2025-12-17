import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import AppLayouts.Wallet.controls
import AppLayouts.Wallet.popups
import AppLayouts.Wallet.panels
import AppLayouts.Wallet.stores
import AppLayouts.stores

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Popups

import SortFilterProxyModel

import utils

import shared.controls

import Storybook
import Models
import Mocks

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d
        property var recipientModel: RecipientModel {}

        property var store: QtObject {
            property var overview: ({
                                        name: "helloworld",
                                        mixedcaseAddress: "0xcdc2ea3b6ba8fed3a3402f8db8b2fab53e7b7421",
                                        ens: "",
                                        color: color,
                                        emoji: "⚽",
                                        balanceLoading: false,
                                        currencyBalance: ({amount: 1.25,
                                                              symbol: "USD",
                                                              displayDecimals: 4,
                                                              stripTrailingZeroes: false}),
                                        isAllAccounts: false,
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

        readonly property WalletAssetsStoreMock walletAssetStore: WalletAssetsStoreMock {
        }
    }
    ActivityFiltersStore {
        id: actvityStore
        tokensList: d.walletAssetStore.groupedAccountAssetsModel
        collectiblesList: CollectiblesModel {}
        savedAddressesModel: d.recipientModel.savedAddresses
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

// category: Wallet
