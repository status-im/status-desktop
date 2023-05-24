import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import StatusQ.Core 0.1

import Storybook 1.0
import Models 1.0
import utils 1.0

import shared.views 1.0

SplitView {
    id: root

    Logs { id: logs }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        DeviceSyncingView {
            devicesModel: ListModel {
                ListElement {
                    name: "Device 1"
                    deviceType: "osx"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 2"
                    deviceType: "windows"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 3"
                    deviceType: "android"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 4"
                    deviceType: "ios"
                    timestamp: 0
                    isCurrentDevice: false
                }
                ListElement {
                    name: "Device 5"
                    deviceType: "desktop"
                    timestamp: 0
                    isCurrentDevice: false
                }
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Pane {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        ScrollView {

//            GridLayout {
//                Layout.fillWidth: true
//                columns: 2
//                columnSpacing: 10

//                ComboBox {
//                    id: contentComboBox
//                    Layout.columnSpan: 2
//                    Layout.fillWidth: true
//                    Layout.bottomMargin: 20
//                    model: ["rectangle", "text"]
//                }

//                Label {
//                    text: "fill width"
//                }
//                CheckBox {
//                    id: widthFillCheckBox
//                    checked: true
//                }

//                Label {
//                    text: "rectangle width"
//                }
//                SpinBox {
//                    id: widthSpinBox
//                    enabled: !widthFillCheckBox.checked
//                    editable: true
//                    height: 30
//                    value: 500
//                    stepSize: 100
//                    from: 0
//                    to: 1000
//                }

//                Label {
//                    text: "fill height"
//                }
//                CheckBox {
//                    id: heightFillCheckBox
//                    checked: false
//                }

//                Label {
//                    text: "rectangle height"
//                }
//                SpinBox {
//                    id: heightSpinBox
//                    editable: true
//                    height: 30
//                    value: 800
//                    stepSize: 100
//                    from: 0
//                    to: 1000
//                }
//            }
        }
    }
}
