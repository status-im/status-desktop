import QtQuick

import StatusQ.Popups

import "../controls"
import "./filterSubMenus"

import AppLayouts.Wallet.stores as WalletStores

StatusMenu {
    id: root

    property WalletStores.RootStore store

    // Time filter
    property int selectedTime: ActivityFilterMenu.All
    signal setSelectedTime(int selectedTime)

    // Type filter
    property var typeFilters: []
    readonly property bool allTypesChecked: typeMenu.allChecked
    signal updateTypeFilter(int type, int allFiltersCount)

    // Status filter
    property var statusFilters: []
    readonly property bool allStatusChecked: statusMenu.allChecked
    signal updateStatusFilter(int status, int allFiltersCount)

    // Tokens filter
    property var tokensList: []
    property var tokensFilter: []
    readonly property bool allTokensChecked: tokensMenu.allTokensChecked
    signal updateTokensFilter(string tokenSymbol)

    // Collectibles filter
    property var collectiblesList: []
    property var collectiblesFilter: []
    property bool loadingCollectibles: false
    readonly property bool allCollectiblesChecked: tokensMenu.allCollectiblesChecked
    signal updateCollectiblesFilter(string uid)

    // Recents filter
    property var recentsList
    property bool loadingRecipients: false
    property var recentsFilters
    readonly property bool allRecentsChecked: counterPartyMenu.allRecentsChecked
    signal updateRecentsFilter(string address)
    signal updateRecipientsModel()

    // Collectibles filter
    property var savedAddressList
    property var savedAddressFilters
    readonly property bool allSavedAddressesChecked: counterPartyMenu.allSavedAddressesChecked
    signal updateSavedAddressFilter(string address)

    implicitWidth: 176

    function resetView() {
        counterPartyMenu.resetView()
        tokensMenu.resetView()
    }

    // Filter By Period
    ActivityFilterMenuItem {
        text: qsTr("Period")
        onTriggered: timeMenu.popup(Qt.point(0, -8))

        // just to be able to place the submenus within an Item
        ActivityPeriodFilterSubMenu {
            id: timeMenu
            onBack: root.open()
            onActionTriggered: {
                timeMenu.close()
                setSelectedTime(action)
            }
            selectedTime: root.selectedTime
            closePolicy: root.closePolicy
        }
        ActivityTypeFilterSubMenu {
            id: typeMenu
            implicitWidth: 230
            onBack: root.open()
            typeFilters: root.typeFilters
            onActionTriggered: updateTypeFilter(type, allFiltersCount)
            closePolicy: root.closePolicy
        }
        ActivityStatusFilterSubMenu {
            id: statusMenu
            onBack: root.open()
            statusFilters: root.statusFilters
            onActionTriggered: updateStatusFilter(status, allFiltersCount)
            closePolicy: root.closePolicy
        }
        ActivityTokensFilterSubMenu {
            id: tokensMenu
            height: 439
            onBack: root.open()
            tokensList: root.tokensList
            tokensFilter: root.tokensFilter
            collectiblesList: root.collectiblesList
            collectiblesFilter: root.collectiblesFilter
            loadingCollectibles: root.loadingCollectibles
            onTokenToggled: updateTokensFilter(tokenSymbol)
            onCollectibleToggled: updateCollectiblesFilter(uid)
            closePolicy: root.closePolicy
        }
        ActivityCounterpartyFilterSubMenu {
            id: counterPartyMenu
            height: 439
            onBack: root.open()
            store: root.store
            recentsList: root.recentsList
            loadingRecipients: root.loadingRecipients
            recentsFilters: root.recentsFilters
            savedAddressList: root.savedAddressList
            savedAddressFilters: root.savedAddressFilters
            onSavedAddressToggled: root.updateSavedAddressFilter(address)
            onRecentsToggled: root.updateRecentsFilter(address)
            onUpdateRecipientsModel: root.updateRecipientsModel()
            closePolicy: root.closePolicy
        }
    }

    ActivityFilterMenuItem {
        text:  qsTr("Type")
        onTriggered: typeMenu.popup(Qt.point(0, -8))
    }

    ActivityFilterMenuItem {
        text:  qsTr("Status")
        onTriggered: statusMenu.popup(Qt.point(0, -8))
    }

    ActivityFilterMenuItem {
        text: qsTr("Tokens")
        onTriggered: tokensMenu.popup(Qt.point(0, -8))
    }

    ActivityFilterMenuItem {
        text: qsTr("Counterparty")
        onTriggered: counterPartyMenu.popup(Qt.point(0, -8))
    }
}

