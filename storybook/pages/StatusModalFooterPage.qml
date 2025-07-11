import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Storybook

import StatusQ.Controls
import StatusQ.Popups

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        PopupBackground {
            anchors.fill: parent
        }

        StatusModal {
            id: footer

            anchors.centerIn: parent
            height: 300
            visible: true
            modal: false
            closePolicy: Popup.NoAutoClose

            title: "Some modal"

            width: Math.floor(root.width * slider.value)

            rightButtons: [
                StatusButton {
                    text: qsTr("Some button")
                },

                StatusButton {
                    text: qsTr("Some other button")
                }
            ]
            leftButtons: StatusBackButton {
                Layout.minimumWidth: implicitWidth
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        SplitView.fillWidth: true

        ColumnLayout {
            Label {
                text: `Popup width: ${footer.width}`
            }

            Slider {
                id: slider

                from: 0.2
                to: 1
                value: 0.5
            }
        }
    }
}

// category: Components
