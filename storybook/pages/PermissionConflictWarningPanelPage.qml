import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import AppLayouts.Communities.panels

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

// category: Panels

// https://www.figma.com/file/17fc13UBFvInrLgNUKJJg5/Kuba%E2%8E%9CDesktop?node-id=22253%3A486103&t=JrCIfks1zVzsk3vn-0
