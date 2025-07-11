import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Core.Theme

import AppLayouts.Communities.controls

import Storybook

SplitView {
    orientation: Qt.Horizontal

    Logs { id: logs }

    Pane {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        background: Rectangle {
            color: Theme.palette.baseColor4
        }

        IssuePill {
            width: ctrlWidth.value || implicitWidth
            anchors.centerIn: parent
            type: ctrlType.currentIndex
            count: ctrlCount.value
            icon: ctrlIcon.text

            Binding on text {
                value: ctrlText.text
                when: ctrlCustomText.checked && !!ctrlText.text
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.fillHeight: true
        SplitView.preferredWidth: 300

        logsView.logText: logs.logText

        ColumnLayout {
            anchors.fill: parent

            RowLayout {
                Layout.fillWidth: true
                Label { text: "Type:" }
                ComboBox {
                    Layout.fillWidth: true
                    id: ctrlType
                    model: ["Warning", "Error", "Primary"]
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Count:" }
                Slider {
                    id: ctrlCount
                    from: 0
                    to: 100
                    value: 5
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Icon:" }
                TextField {
                    id: ctrlIcon
                    text: "warning"
                }
            }
            RowLayout {
                Layout.fillWidth: true
                CheckBox {
                    id: ctrlCustomText
                    text: "Custom text:"
                    onToggled: if (checked) ctrlText.forceActiveFocus()
                }
                TextField {
                    Layout.fillWidth: true
                    id: ctrlText
                    enabled: ctrlCustomText.checked
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label { text: "Width:" }
                SpinBox {
                    id: ctrlWidth
                    from: 0
                    to: 400
                    value: 0 // 0 == implicitWidth
                    stepSize: 20
                    textFromValue: function(value, locale) { return value === 0 ? "Implicit" : value }
                }
            }
            Item { Layout.fillHeight: true }
        }
    }
}

// category: Controls
