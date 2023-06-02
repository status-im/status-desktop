import QtQuick 2.14
import QtQuick.Controls 2.14

import AppLayouts.Wallet.controls 1.0
import AppLayouts.Wallet.popups 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import Storybook 1.0

import Models 1.0

SplitView {
    id: root

    Logs { id: logs }

    orientation: Qt.Vertical

    QtObject {
        id: d
        property int selectedTime: ActivityPeriodFilterSubMenu.All
        function changeSelectedTime(newTime) {
            selectedTime = newTime
        }
        function setCustomTimeRange(fromTimestamp , toTimestamp) {
            dialog.fromTimestamp = fromTimestamp
            dialog.toTimestamp = toTimestamp
        }
        property var typeFilters: [
            ActivityTypeFilterSubMenu.Send,
            ActivityTypeFilterSubMenu.Receive,
            ActivityTypeFilterSubMenu.Buy,
            ActivityTypeFilterSubMenu.Swap,
            ActivityTypeFilterSubMenu.Bridge]
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        StatusRoundButton {
            id: filterButton
            anchors.top: parent.top
            anchors.topMargin: 100
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32
            height: 32
            border.width: 1
            border.color:  Theme.palette.directColor8
            type: StatusRoundButton.Type.Tertiary
            icon.name: "filter"
            onClicked: {
                activityFilterMenu.popup(filterButton.x, filterButton.y + filterButton.height + 4)
            }
        }
        ActivityFilterMenu {
            id: activityFilterMenu

            selectedTime: d.selectedTime
            onSetSelectedTime: {
                if(selectedTime === ActivityPeriodFilterSubMenu.Custom) {
                    dialog.open()
                }
                d.changeSelectedTime(selectedTime)
            }

            typeFilters: d.typeFilters
            onUpdateTypeFilter: console.warn("onUpdateTypeFilter:: type :: ", type, " checked ::", checked)
        }


        StatusDateRangePicker {
            id: dialog
            anchors.centerIn: parent
            destroyOnClose: false
            fromTimestamp: new Date().setDate(new Date().getDate() - 7) // 7 days ago
            onNewRangeSet: {
                d.setCustomTimeRange(fromTimestamp, toTimestamp)
            }
        }
    }

    LogsAndControlsPanel {
        id: logsAndControlsPanel

        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        logsView.logText: logs.logText

        ButtonGroup {
            buttons: periodRow.children
        }

        Column {
            spacing: 20

            Row {
                id: periodRow
                spacing: 20

                RadioButton {
                    checked: true
                    text: "All"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.All}
                }
                RadioButton {
                    text: "Today"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.Today}
                }
                RadioButton {
                    text: "Yesterday"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.Yesterday}
                }
                RadioButton {
                    text: "ThisWeek"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.ThisWeek}
                }
                RadioButton {
                    text: "LastWeek"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.LastWeek}
                }
                RadioButton {
                    text: "ThisMonth"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.ThisMonth}
                }
                RadioButton {
                    text: "LastMonth"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.LastMonth}
                }
                RadioButton {
                    text: "Custom"
                    onCheckedChanged: if(checked) { d.selectedTime =  ActivityPeriodFilterSubMenu.Custom}
                }
            }

            Row {
                spacing: 20
                CheckBox {
                    id: sendCheckbox
                    text: "Send"
                    checked: true
                }
                CheckBox {
                    id: receiveCheckbox
                    text: "Receive"
                    checked: true
                }
                CheckBox {
                    id: buyCheckbox
                    text: "Buy"
                    checked: true
                }
                CheckBox {
                    id: swapCheckbox
                    text: "Swap"
                    checked: true
                }
                CheckBox {
                    id: bridgeCheckbox
                    text: "Bridge"
                    checked: true
                }
            }

        }
    }
}
