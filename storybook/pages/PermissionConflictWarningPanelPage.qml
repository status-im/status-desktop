import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14

import Storybook 1.0

import AppLayouts.Communities.panels 1.0

SplitView {
    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Item {
            id: container
            width: widthSlider.value
            height: conflictPanel.implicitHeight
            anchors.centerIn: parent

            PermissionConflictWarningPanel {
                id: conflictPanel
                anchors.left: parent.left
                anchors.right: parent.right
                holdings: holdingsField.text
                permissions: permissionsField.text
                channels: channelsField.text
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 250

        ColumnLayout {
            spacing: 10
            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Width:"
                }

                Slider {
                    id: widthSlider
                    value: 400
                    from: 200
                    to: 600
                }
            }
            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Holdings:"
                }

                TextField {
                    id: holdingsField
                    text: "1 ETH"
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Permissions:"
                }

                TextField {
                    id: permissionsField
                    text: "View and Post"
                }
            }

            Row {
                Label {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Channels:"
                }

                TextField {
                    id: channelsField
                    text: "#general"
                }
            }

        }
    }
}
