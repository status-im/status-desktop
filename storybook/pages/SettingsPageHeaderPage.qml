import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Storybook 1.0

import AppLayouts.Communities.controls 1.0
import StatusQ.Controls 0.1

SplitView {
    id: root

    orientation: Qt.Vertical

    readonly property list<StatusButton> sampleButtons: [
        StatusButton {
            text: "button 1"
        },
        StatusButton {
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

            width: widthSlider.value || undefined

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

                    from: 0
                    to: 700
                    stepSize: 1
                }

                Label {
                    text: widthSlider.value || "implicit"
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
