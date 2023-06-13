import QtQuick 2.15

import StatusQ.Popups 0.1

import utils 1.0

import "../../controls"

StatusMenu {
    id: root

    property int selectedTime: ActivityFilterMenu.All

    signal back()
    signal actionTriggered(int action)

    MenuBackButton {
        width: parent.width
        onClicked: {
            close()
            back()
        }
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.All
        text: qsTr("All time")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.All)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.Today
        text: qsTr("Today")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.Today)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.Yesterday
        text: qsTr("Yesterday")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.Yesterday)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.ThisWeek
        text: qsTr("This week")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.ThisWeek)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.LastWeek
        text: qsTr("Last week")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.LastWeek)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.ThisMonth
        text: qsTr("This month")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.ThisMonth)
    }
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.LastMonth
        text: qsTr("Last month")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.LastMonth)
    }
    StatusMenuSeparator {}
    StatusWalletMenuRadioButton {
        checkedState: root.selectedTime === Constants.TransactionTimePeriod.Custom
        text: qsTr("Custom range")
        onClicked: actionTriggered(Constants.TransactionTimePeriod.Custom)
    }
}
