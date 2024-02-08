import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtQml.Models 2.15

import Storybook 1.0

import StatusQ.Controls 0.1
import StatusQ.Popups.Dialog 0.1

SplitView {
    id: root

    orientation: Qt.Vertical

    Item {
        SplitView.fillWidth: true
        SplitView.fillHeight: true

        Rectangle {
            border.color: "lightgray"
            anchors.fill: footer
            anchors.margins: -5
        }

        StatusDialogFooter {
            id: footer

            anchors.centerIn: parent
            width: widthNotSpecifiedCheckBox.checked
                   ? undefined
                   : Math.floor(root.width * slider.value)

            rightButtons: ObjectModel {
                StatusButton {
                    id: rejectBtn

                    text: qsTr("I  I don't want to be the owner")
                }

                StatusButton {
                    id: acceptBtn

                    text: qsTr("Finalize owhership")
                }
            }
            leftButtons: ObjectModel {
                StatusBackButton {
                    id: backButton

                    Layout.minimumWidth: implicitWidth
                }
            }
        }
    }

    LogsAndControlsPanel {
        SplitView.minimumHeight: 100
        SplitView.preferredHeight: 200

        SplitView.fillWidth: true

        ColumnLayout {
            Label {
                text: `Footer width: ${footer.width}`
            }
            Label {
                text: `Footer implicitWidth: ${footer.implicitWidth}`
            }

            Slider {
                id: slider

                enabled: !widthNotSpecifiedCheckBox.checked

                from: 0.2
                to: 1
                value: 0.5
            }
            CheckBox {
                id: widthNotSpecifiedCheckBox

                text: "width not specified"
            }
        }
    }
}

// category: Components
