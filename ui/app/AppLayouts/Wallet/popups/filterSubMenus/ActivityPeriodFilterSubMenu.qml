import QtQuick 2.15

import StatusQ.Popups 0.1

import "../../controls"

StatusMenu {
    id: root

    property int selectedTime: ActivityFilterMenu.All

    signal back()
    signal actionTriggered(int action)

    enum TimePeriod {
        All,
        Today,
        Yesterday,
        ThisWeek,
        LastWeek,
        ThisMonth,
        LastMonth,
        Custom
    }

    MenuBackButton {
        width: parent.width
        onClicked: {
            close()
            back()
        }
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.All
        text: qsTr("All time")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.All)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.Today
        text: qsTr("Today")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.Today)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.Yesterday
        text: qsTr("Yesterday")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.Yesterday)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.ThisWeek
        text: qsTr("This week")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.ThisWeek)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.LastWeek
        text: qsTr("Last week")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.LastWeek)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.ThisMonth
        text: qsTr("This month")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.ThisMonth)
    }
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.LastMonth
        text: qsTr("Last month")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.LastMonth)
    }
    StatusMenuSeparator {}
    StatusWalletMenuRadioButton {
        checked: root.selectedTime === ActivityPeriodFilterSubMenu.Custom
        text: qsTr("Custom range")
        onClicked: actionTriggered(ActivityPeriodFilterSubMenu.Custom)
    }
}
