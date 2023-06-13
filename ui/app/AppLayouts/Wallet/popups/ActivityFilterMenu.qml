import QtQuick 2.15

import StatusQ.Popups 0.1

import "../controls"
import "./filterSubMenus"

StatusMenu {
    id: root

    // Time filter
    property int selectedTime: ActivityFilterMenu.All
    signal setSelectedTime(int selectedTime)

    // Type filter
    property var typeFilters: []
    property bool allTypesChecked: typeMenu.allChecked
    signal updateTypeFilter(int type)

    // Status filter
    property var statusFilters: []
    property bool allStatusChecked: statusMenu.allChecked
    signal updateStatusFilter(int status)

    // Assets filter
    property var tokensList: []
    property var collectiblesList
    signal updateTokensFilter(string tokenSymbol)
    signal updateCollectiblesFilter(string name)

    // Counterparty filter
    property var store
    property var recentsList
    property var savedAddressList
    signal updateSavedAddressFilter(string address)
    signal updateRecentsFilter(string address)

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
            onActionTriggered: updateTypeFilter(type)
            closePolicy: root.closePolicy
        }
        ActivityStatusFilterSubMenu {
            id: statusMenu
            onBack: root.open()
            statusFilters: root.statusFilters
            onActionTriggered: updateStatusFilter(status)
            closePolicy: root.closePolicy
        }
        ActivityTokensFilterSubMenu {
            id: tokensMenu
            height: Math.min(439, tokensMenu.implicitHeight)
            onBack: root.open()
            tokensList: root.tokensList
            collectiblesList: root.collectiblesList
            onTokenToggled: updateTokensFilter(tokenSymbol)
            onCollectibleToggled: updateCollectiblesFilter(name)
            closePolicy: root.closePolicy
        }
        ActivityCounterpartyFilterSubMenu {
            id: counterPartyMenu
            height: Math.min(439, counterPartyMenu.implicitHeight)
            onBack: root.open()
            store: root.store
            recentsList: root.recentsList
            savedAddressList: root.savedAddressList
            onSavedAddressToggled: root.updateSavedAddressFilter(address)
            onRecentsToggled: root.updateRecentsFilter(address)
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

