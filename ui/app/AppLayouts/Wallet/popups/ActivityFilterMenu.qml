import QtQuick 2.15

import StatusQ.Popups 0.1

import "../controls"
import "./filterSubMenus"

StatusMenu {
    id: root

    property var store

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
    readonly property bool allCollectiblesChecked: tokensMenu.allCollectiblesChecked
    signal updateCollectiblesFilter(double id)

    // Recents filter
    property var recentsList
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
            height: Math.min(439, tokensMenu.implicitHeight)
            onBack: root.open()
            tokensList: root.tokensList
            tokensFilter: root.tokensFilter
            collectiblesList: root.collectiblesList
            collectiblesFilter: root.collectiblesFilter
            onTokenToggled: updateTokensFilter(tokenSymbol)
            onCollectibleToggled: updateCollectiblesFilter(id)
            closePolicy: root.closePolicy
        }
        ActivityCounterpartyFilterSubMenu {
            id: counterPartyMenu
            height: Math.min(439, counterPartyMenu.implicitHeight)
            onBack: root.open()
            store: root.store
            recentsList: root.recentsList
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

