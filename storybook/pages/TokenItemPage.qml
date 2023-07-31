import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

import Models 1.0
import Storybook 1.0
import utils 1.0

import AppLayouts.Communities.controls 1.0

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
