import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15

Rectangle {
    id: root

    readonly property color visualItemColor: "black"
    readonly property color nonVisualItemColor: "green"

    readonly property color visualItemSelectionColor: "red"
    readonly property color nonVisualItemSelectionColor: "orange"

    readonly property bool selected: containsMouse || forceSelect

    readonly property color baseColor:
        isVisual ? visualItemColor
                 : (showNonVisual ? nonVisualItemColor : "transparent")

    readonly property color selectionColor: isVisual ? visualItemSelectionColor
                                                     : nonVisualItemSelectionColor

    border.color: selected ? selectionColor : baseColor
    border.width: selected ? 2 : 1
    color: 'transparent'

    required property string name
    property string objName
    required property bool isVisual
    property bool showNonVisual: false
    property bool forceSelect: false

    required property Item visualParent
    required property Item visualRoot

    readonly property real topSpacing: mapToItem(visualParent, 0, 0).y

    readonly property real bottomSpacing:
        visualParent.height - mapToItem(visualParent, 0, height).y

    readonly property real leftSpacing: mapToItem(visualParent, 0, 0).x

    readonly property real rightSpacing:
        visualParent.width - mapToItem(visualParent, width, 0).x

    readonly property alias containsMouse: mouseArea.containsMouse

    signal clicked

    Loader {
        active: root.selected

        sourceComponent: Item {
            parent: root.visualRoot
            anchors.fill: parent

            Rectangle {
                id: selectionParentRect

                width: root.visualParent.width
                height: root.visualParent.height

                readonly property point pos:
                    root.visualParent.mapToItem(root.visualRoot, 0, 0)

                x: pos.x
                y: pos.y

                border.color: root.border.color
                border.width: 1
                color: "transparent"
            }

            Rectangle {
                id: selectionRect

                width: root.width
                height: root.height

                readonly property point pos:
                    root.mapToItem(root.visualRoot, 0, 0)

                x: pos.x
                y: pos.y

                border.color: root.border.color
                border.width: root.border.width
                color: root.color
            }

            component DistanceRectangle: Rectangle {
                width: 1
                height: 1
                color: selectionColor
                visible: root.selected
            }

            // top
            DistanceRectangle {
                anchors.top: selectionParentRect.top
                anchors.bottom: selectionRect.top
                anchors.horizontalCenter: selectionRect.horizontalCenter
            }

            // bottom
            DistanceRectangle {
                anchors.top: selectionRect.bottom
                anchors.bottom: selectionParentRect.bottom
                anchors.horizontalCenter: selectionRect.horizontalCenter
            }

            // left
            DistanceRectangle {
                anchors.left: selectionParentRect.left
                anchors.right: selectionRect.left
                anchors.verticalCenter: selectionRect.verticalCenter
            }

            // right
            DistanceRectangle {
                anchors.left: selectionRect.right
                anchors.right: selectionParentRect.right
                anchors.verticalCenter: selectionRect.verticalCenter
            }
        }
    }

    Popup {
        x: parent.width + padding / 2
        y: parent.height + padding / 2

        visible: root.selected
        margins: 0

        ColumnLayout {
            Label {
                text: root.name
                font.bold: true
            }
            Label {
                text: `objectName: ${root.objName}`
                visible: root.objName
            }
            Label {
                text: `x: ${root.x}, y: ${root.y}`
            }
            Label {
                text: `size: ${root.width} x ${root.height}`
            }
            Label {
                text: `top space: ${root.topSpacing}`
            }
            Label {
                text: `bottom space: ${root.bottomSpacing}`
            }
            Label {
                text: `left space: ${root.leftSpacing}`
            }
            Label {
                text: `right space: ${root.rightSpacing}`
            }
        }
    }

    MouseArea {
        id: mouseArea

        visible: isVisual || showNonVisual
        anchors.fill: parent
        hoverEnabled: true

        onClicked: root.clicked()
    }
}
