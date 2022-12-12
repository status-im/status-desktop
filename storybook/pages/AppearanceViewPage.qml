import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.views 1.0

import Storybook 1.0

import utils 1.0

SplitView {
    Logs { id: logs }

    property var model: QtObject {
        property int currentFontSize: 1
        property int currentZoom: 100
        property int currentTheme: 0
    }

    SplitView {
        orientation: Qt.Vertical
        SplitView.fillWidth: true

        AppearanceView {
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            contentWidth: parent.width

            currentFontSize: model.currentFontSize
            currentZoom: model.currentZoom
            currentTheme: model.currentTheme

            onFontSizeChanged: (value) => {
                logs.logEvent("onFontSizeChanged", ["value"], arguments)
                model.currentFontSize = value

                Style.changeFontSize(value)
                Theme.updateFontSize(value)
            }

            onZoomChanged: (value) => {
                logs.logEvent("onZoomChanged", ["value"], arguments)
                model.currentZoom = value
            }

            onThemeChanged: (value) => {
                logs.logEvent("onThemeChanged", ["value"], arguments)
                model.currentTheme = value
            }
        }

        LogsAndControlsPanel {
            id: logsAndControlsPanel

            SplitView.minimumHeight: 100
            SplitView.preferredHeight: 200

            logsView.logText: logs.logText
        }
    }

    Control {
        SplitView.minimumWidth: 300
        SplitView.preferredWidth: 300

        font.pixelSize: 13

        ColumnLayout {

            Row {
                spacing: 4

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "font size:\t"
                }

                SpinBox {
                    editable: true
                    height: 30
                    from: 0; to: 5
                    value:  model.currentFontSize
                    onValueChanged: model.currentFontSize = value
                }
            }

            Row {
                spacing: 4

                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "zoom:\t"
                }

                SpinBox {
                    editable: true
                    height: 30
                    from: 50; to: 200; stepSize: 50;
                    value:  model.currentZoom
                    onValueChanged: model.currentZoom = value
                }
            }

            Row {
                spacing: 4

                Label {
                    text: "theme"
                }

                Flow {
                    Layout.fillWidth: true

                    CheckBox {
                        text: "Light"
                        checked: model.currentTheme == 0
                        onToggled: model.currentTheme = 0
                    }

                    CheckBox {
                        text: "Dark"
                        checked: model.currentTheme == 1
                        onToggled: model.currentTheme = 1
                    }

                    CheckBox {
                        text: "System"
                        checked: model.currentTheme == 2
                        onToggled: model.currentTheme = 2
                    }
                }

            }

        }

    }
}
