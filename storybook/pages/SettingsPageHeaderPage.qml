import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import AppLayouts.Communities.controls
import StatusQ.Controls

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property list<StatusButton> sampleButtons: [
        StatusButton {
            Layout.fillWidth: true
            text: "button 1"
        },
        StatusButton {
            Layout.fillWidth: true
            text: "button 2"
        }
    ]

    Item {
        id: container

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: settingsPageHeader
            border.width: 1
            anchors.margins: -15
        }

        SettingsPageHeader {
            id: settingsPageHeader

            width: widthSlider.value

            title: titleTextField.text
            subtitle: subtitleTextField.text

            anchors.centerIn: parent

            buttons: buttonsCheckBox.checked ? root.sampleButtons : null
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        SplitView.fillWidth: true

        ColumnLayout {
            RowLayout {
                Label {
                    text: "Title:"

                }
                TextField {
                    id: titleTextField

                    text: "Mint Collectible"
                }
            }
            RowLayout {
                Label {
                    text: "Subtitle:"

                }
                TextField {
                    id: subtitleTextField

                    text: "SNT"
                }
            }

            RowLayout {
                Label {
                    text: "Width:"
                }

                Slider {
                    id: widthSlider

                    value: 500
                    from: 200
                    to: 800
                    stepSize: 1
                }

                Label {
                    text: widthSlider.value
                }
            }

            CheckBox {
                id: buttonsCheckBox

                text: "Show buttons"
                checked: true
            }
        }
    }
}

// category: Components
