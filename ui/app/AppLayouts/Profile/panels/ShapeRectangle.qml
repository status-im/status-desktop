import QtQuick 2.15
import QtQuick.Shapes 1.15

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

/*!
   \qmltype ShapeRectangle
   \inherits Shape
   \brief Rectangle-like component with the ability to further customize the outline/border style using a Shape/ShapePath;
          with optional text in the middle

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

    property string text

    readonly property int radius: Style.current.radius
    readonly property alias path: path

    asynchronous: true

    // design values; Shape doesn't have an implicit size
    implicitWidth: 448
    implicitHeight: 44

    StatusBaseText {
        anchors.centerIn: parent
        color: Theme.palette.baseColor1
        text: root.text
    }

    ShapePath {
        id: path
        fillColor: "transparent"
        strokeColor: Theme.palette.baseColor2
        strokeWidth: 1
        strokeStyle: ShapePath.DashLine
        dashPattern: [4, 4]

        startX: root.radius
        startY: 0
        PathLine {
            x: root.width - root.radius
            y: 0
        }
        PathCubic {
            control1X: root.width
            control2X: root.width
            control1Y: 0
            control2Y: 0
            x: root.width
            y: root.radius
        }
        PathLine {
            x: root.width
            y: root.height - root.radius
        }
        PathCubic {
            control1X: root.width
            control2X: root.width
            control1Y: root.height
            control2Y: root.height
            x: root.width - root.radius
            y: root.height
        }
        PathLine {
            x: root.radius
            y: root.height
        }
        PathCubic {
            control1X: 0
            control2X: 0
            control1Y: root.height
            control2Y: root.height
            x: 0
            y: root.height - root.radius
        }
        PathLine {
            x: 0
            y: root.radius
        }
        PathCubic {
            control1X: 0
            control2X: 0
            control1Y: 0
            control2Y: 0
            x: root.radius
            y: 0
        }
    }
}
