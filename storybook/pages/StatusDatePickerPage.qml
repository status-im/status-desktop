import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import StatusQ.Components

import Storybook

SplitView {
    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        Item {
            Layout.fillWidth: true
            SplitView.preferredHeight: 200
            StatusDatePicker {
                id: picker
                anchors.centerIn: parent
                onSelectedDateChanged: logs.logEvent("Selected date: %1".arg(picker.selectedDate.toISOString()))
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText

            ColumnLayout {
                width: parent.width
                Button {
                    text: "Select today"
                    onClicked: picker.selectedDate = new Date()
                }
                Switch {
                    text: "Week numbers"
                    checked: picker.weekNumbersVisible
                    onToggled: {
                        picker.weekNumbersVisible = checked
                        logs.logEvent("Week numbers shown: %1".arg(checked ? "true" : "false"))
                    }
                }
                Switch {
                    text: "Short format"
                    checked: picker.dateFormat === Locale.ShortFormat
                    onToggled: {
                        picker.dateFormat = checked ? Locale.ShortFormat : Locale.LongFormat
                        logs.logEvent("Using short date format: %1".arg(checked ? "true" : "false"))
                    }
                }
                TextField {
                    Layout.preferredWidth: 200
                    placeholderText: "Custom \"today\" text"
                    onEditingFinished: {
                        picker.customTodayText = text
                        logs.logEvent("Custom \"Today\" text: %1".arg(picker.customTodayText))
                    }
                }
                TextField {
                    Layout.preferredWidth: 200
                    placeholderText: "Locale code ('fr'); empty = default"
                    onEditingFinished: picker.control.locale = Qt.locale(text)
                }
            }
        }
    }
}

// category: Components
// status: good
