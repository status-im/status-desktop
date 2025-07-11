import QtQuick
import QtQuick.Shapes
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme

import utils

/*!
   \qmltype ShapeRectangle
   \inherits Shape
   \brief Rectangle-like component with the ability to further customize the outline/border style using a Shape/ShapePath;
          with optional text and icon in the middle

   Example of how to use it:

   \qml
        ShapeRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: parent.width - 4 // the rectangular path is rendered outside
            Layout.preferredHeight: 44
            text: qsTr("Your links will appear here")
        }
   \endqml

   \sa Shape
   \sa ShapePath
*/
Shape {
    id: root

    property string icon
    property string text
    property color textColor: Theme.palette.baseColor1
    property alias font: description.font

    property int radius: Theme.radius
    property int leftTopRadius: radius
    property int rightTopRadius: radius
    property int leftBottomRadius: radius
    property int rightBottomRadius: radius
    readonly property alias path: path

    // design values; Shape doesn't have an implicit size
    implicitWidth: 448
    implicitHeight: 44

    RowLayout {
        spacing: 4
        anchors.centerIn: parent

        StatusIcon {
            id: icon

            visible: root.icon
            color: root.textColor
            icon: root.icon
            Layout.preferredWidth: 16
            Layout.preferredHeight: width
        }

        StatusBaseText {
            id: description
            color: root.textColor
            text: root.text
            font.pixelSize: Theme.additionalTextSize
            visible: !!text
        }
    }

    ShapePath {
        id: path
        fillColor: "transparent"
        strokeColor: Theme.palette.baseColor2
        strokeWidth: 1
        strokeStyle: ShapePath.DashLine
        dashPattern: [4, 4]

        startX: root.leftTopRadius
        startY: 0
        PathLine {
            x: root.width - root.rightTopRadius
            y: 0
        }
        PathArc {
            x: root.width
            y: root.rightTopRadius
            radiusX: root.rightTopRadius
            radiusY: root.rightTopRadius
        }
        PathLine {
            x: root.width
            y: root.height - root.rightBottomRadius
        }
        PathArc {
            x:root.width - root.rightBottomRadius
            y: root.height
            radiusX: root.rightBottomRadius
            radiusY: root.rightBottomRadius
        }
        PathLine {
            x: root.leftBottomRadius
            y: root.height
        }
        PathArc {
            x:0
            y: root.height - root.leftBottomRadius
            radiusX: root.leftBottomRadius
            radiusY: root.leftBottomRadius
        }
        PathLine {
            x: 0
            y: root.leftTopRadius
        }
        PathArc {
            x:root.leftTopRadius
            y: 0
            radiusX: root.leftTopRadius
            radiusY: root.leftTopRadius
        }
    }
}
