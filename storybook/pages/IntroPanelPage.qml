import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Models
import Storybook
import utils

import StatusQ.Core.Theme

import AppLayouts.Communities.panels

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        id: container

        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: tokenPanel
            border.width: 1
            anchors.margins: -15
            color: "transparent"
        }

        IntroPanel {
            id: tokenPanel

            anchors.margins: 50
            anchors.fill: parent

            image: Assets.png("community/airdrops8_1")

            title: radioButtonsGroup.text
            subtitle: radioButtonsGroup.text

            checkersModel: [
                radioButtonsGroup.text,
                radioButtonsGroup.text,
                radioButtonsGroup.text
            ]
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 100

        SplitView.fillWidth: true

        ColumnLayout {

            ButtonGroup {
                id: radioButtonsGroup

                buttons: radioButtonsRow.children

                readonly property string text: checkedButton.textContent
            }

            RowLayout {
                id: radioButtonsRow

                RadioButton {
                    id: addRadioButton

                    readonly property string textContent:
                        ModelsData.descriptions.shortLoremIpsum

                    text: "Short text"
                    checked: true
                }
                RadioButton {
                    id: updateRadioButton

                    readonly property string textContent:
                        ModelsData.descriptions.mediumLoremIpsum

                    text: "Long text"
                }
            }
        }
    }
}

// category: Panels
