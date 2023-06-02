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
    signal updateTypeFilter(int type, bool checked)

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
        }
        ActivityTypeFilterSubMenu {
            id: typeMenu
            onBack: root.open()
            typeFilters: root.typeFilters
            onActionTriggered: updateTypeFilter(action, checked)
        }
    }

    ActivityFilterMenuItem {
        text:  qsTr("Type")
        onTriggered: typeMenu.popup(Qt.point(0, -8))
    }

    ActivityFilterMenuItem {
        text:  qsTr("Status")
    }

    ActivityFilterMenuItem {
        text: qsTr("Tokens")
    }

    ActivityFilterMenuItem {
        text: qsTr("Counterparty")
    }
}

