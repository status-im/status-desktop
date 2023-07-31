import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0
import Storybook 1.0
import utils 1.0

import AppLayouts.Communities.panels 1.0

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

            width: 600
            anchors.centerIn: parent

            image: Style.png("community/airdrops8_1")

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
