import QtQuick 2.14
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import StatusQ.Core.Theme 0.1
import StatusQ.Core 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups.Dialog 0.1

StatusDialog {
    id: root

    property double fromTimestamp: Date.now()
    property double toTimestamp: Date.now()

    signal newRangeSet(double fromTimestamp, double toTimestamp)

    title: qsTr("Filter activity by period")

    QtObject {
        id: d

        function getFromTimestampUTC(date) {
            date.setHours(0, 0, 0, 0)
            return date.valueOf()
        }

        function getToTimestampUTC(date) {
            date.setDate(date.getDate() + 1) // next day...
            date.setHours(0, 0, 0, -1) // ... but just 1ms before midnight -> whole day included
            return date.valueOf()
        }
    }

    contentItem: Item {
        GridLayout {
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            columns: 3
            columnSpacing: 16
            rowSpacing: 8

            StatusBaseText {
                text: qsTr("From")
            }

            RowLayout {
                Layout.fillWidth: true
                StatusBaseText {
                    text: qsTr("To")
                }
                Item { Layout.fillWidth: true }
                StatusFlatButton {
                    horizontalPadding: 0
                    verticalPadding: 0
                    hoverColor: Theme.palette.transparent
                    text: qsTr("Now")
                    enabled: !toInput.isTodaySelected
                    onClicked: toInput.selectedDate = new Date()
                }
            }

            StatusDatePicker {
                Layout.alignment: Qt.AlignTop
                Layout.row: 1
                Layout.preferredWidth: 168
                readonly property bool hasChange: selectedDate.valueOf() !== root.fromTimestamp
                id: fromInput
                selectedDate: new Date(fromTimestamp)
                customTodayText: qsTr("Now")
                validationError: {
                    if (selectedDate.valueOf() > toInput.selectedDate.valueOf() && !toInput.isTodaySelected) // from > to; today in both is fine
                        return qsTr("'From' can't be later than 'To'")

                    if (selectedDate.valueOf() > new Date()) // from > now
                        return qsTr("Can't set date to future")

                    return ""
                }
            }

            StatusDatePicker {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 168
                readonly property bool hasChange: selectedDate.valueOf() !== root.toTimestamp
                id: toInput
                selectedDate: new Date(toTimestamp)
                customTodayText: qsTr("Now")
                validationError: selectedDate.valueOf() > new Date() // to > now
                                 ? qsTr("Can't set date to future") : ""
            }

            StatusButton {
                Layout.alignment: Qt.AlignTop
                Layout.preferredHeight: toInput.control.height
                text: qsTr("Reset")
                enabled: fromInput.hasChange || toInput.hasChange
                normalColor: Theme.palette.transparent
                borderColor: Theme.palette.baseColor2
                onClicked: {
                    fromInput.selectedDate = new Date(root.fromTimestamp)
                    toInput.selectedDate = new Date(root.toTimestamp)
                }
            }
        }
    }

    footer: StatusDialogFooter {
        rightButtons: ObjectModel {
            StatusButton {
                text: qsTr("Apply")
                enabled: !fromInput.validationError && !toInput.validationError && (fromInput.hasChange || toInput.hasChange)
                onClicked: {
                    root.newRangeSet(d.getFromTimestampUTC(fromInput.selectedDate),
                                     toInput.isTodaySelected ? new Date().valueOf() // now means now, including the time today
                                                             : d.getToTimestampUTC(toInput.selectedDate))
                    root.close()
                }
            }
        }
    }
}
