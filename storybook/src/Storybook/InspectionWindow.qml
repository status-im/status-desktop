import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15


ApplicationWindow {
    title: "Storybook Inspector"

    width: 1024
    height: 768

    function inspect(sourceItem) {
        const properties = {
            sourceItem,
            propagateClipping: Qt.binding(() => clipCheckBox.checked),
            showNonVisualItems: Qt.binding(() => showNonVisualCheckBox.checked),
            showScreenshot: Qt.binding(() => screenshotCheckBox.checked)
        }

        loader.setSource("InspectionPanel.qml", properties)
        pinchHandler.target.scale = 1
    }

    Connections {
        target: loader.item

        function onClicked(index) {
            itemsListView.positionViewAtIndex(index, ListView.Center)
        }
    }

    SplitView {
        anchors.fill: parent

        InspectionItemsList {
            id: itemsListView

            SplitView.preferredWidth: 300
            SplitView.fillHeight: true

            model: loader.item ? loader.item.model : null

            clip: true
        }

        ColumnLayout {
            SplitView.fillWidth: true
            SplitView.fillHeight: true

            Flickable {
                id: flickable

                Layout.fillWidth: true
                Layout.fillHeight: true

                clip: true

                contentWidth: content.width * content.scale
                contentHeight: content.height * content.scale

                Item {
                    id: content

                    width: Math.max(flickable.width, loader.implicitWidth)
                    height: Math.max(flickable.height, loader.implicitHeight)

                    Rectangle {
                        border.color: "gray"
                        color: "transparent"
                        anchors.fill: loader
                    }

                    Loader {
                        id: loader
                        anchors.centerIn: parent
                    }
                }
            }
            PinchHandler {
                id: pinchHandler
                target: content
                maximumRotation: 0
                minimumRotation: 0
            }

            Pane {
                Layout.fillWidth: true

                RowLayout {
                    CheckBox {
                        id: screenshotCheckBox
                        text: "Show screenshot"
                        checked: true
                    }

                    CheckBox {
                        id: clipCheckBox
                        text: "Propagate clipping"
                    }

                    CheckBox {
                        id: showNonVisualCheckBox
                        text: "Show non-visual items"
                    }
                }
            }
        }
    }
}
