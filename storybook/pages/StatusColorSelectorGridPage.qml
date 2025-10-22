import QtQuick
import QtQuick.Controls

import StatusQ.Core
import StatusQ.Controls

Item {
    id: root

    Rectangle {
        id: topRect

        border.color: "red"
        color: "transparent"

        x: 50
        y: 50

        state: "implicit"

        states: [
            State {
                name: "implicit"

                PropertyChanges {
                    target: topRect
                    width: content.implicitWidth
                    height: content.implicitHeight
                }

                AnchorChanges {
                    target: handleRect
                    anchors.right: parent.right
                }
            },
            State {
                name: "custom"

                PropertyChanges {
                    target: topRect
                    width: handleRect.x + handleRect.width
                    height: content.implicitHeight
                }

                AnchorChanges {
                    target: content
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    anchors.left: parent.left
                    anchors.right: parent.right
                }
            }
        ]

        StatusColorSelectorGrid {
            id: content

            padding: 30

            titleText: "Color"
            selectedColorIndex: 2
        }

        Rectangle {
            id: handleRect

            width: 20
            height: 20

            x: 200
            anchors.bottom: parent.bottom

            color: "green"

            DragHandler {
                xAxis.minimum: 30
                yAxis.enabled: false
                yAxis.minimum: 30

                onActiveChanged: topRect.state = "custom"
            }
        }
    }

    Row {
        id: selectedColor

        anchors.bottom: parent.bottom
        anchors.left: parent.left
        spacing: 10

        Button {
            text: "implicit size"

            onClicked: {
                topRect.state = "implicit"
            }

            enabled: topRect.state !== "implicit"
        }

        StatusBaseText {
            text: "SelectedColor is"

            anchors.verticalCenter: parent.verticalCenter
        }

        Rectangle {
            width: 100
            height: 20
            radius: width/2
            color: content.selectedColor

            anchors.verticalCenter: parent.verticalCenter
        }
    }
}

// category: Components
// status: good
