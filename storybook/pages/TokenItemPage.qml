import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Models
import Storybook
import utils

import AppLayouts.Communities.controls

SplitView {
    id: root

    orientation: Qt.Vertical

    component CustomTokenItem: TokenItem {
        name: nameTextField.text
        shortName: shortNameTextField.text
        amount: amountTextField.text
        iconSource: ModelsData.assets.socks

        Layout.fillWidth: true
    }

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            anchors.fill: column
            anchors.margins: -1
            border.color: "lightgray"
        }

        ColumnLayout {
            id: column

            anchors.centerIn: parent

            width: 300

            CustomTokenItem {}

            CustomTokenItem {
                selected: true
            }

            CustomTokenItem {
                showSubItemsIcon: true
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        SplitView.fillWidth: true

        ColumnLayout {
            RowLayout {
                Label {
                    text: "Name:\t"

                }
                TextField {
                    id: nameTextField

                    text: "Token name"
                }
            }
            RowLayout {
                Label {
                    text: "Short name:\t"

                }
                TextField {
                    id: shortNameTextField

                    text: "TN"
                }
            }
            RowLayout {
                Label {
                    text: "Amount:\t"

                }
                TextField {
                    id: amountTextField

                    text: "200"
                }
            }
        }
    }
}

// category: Components
