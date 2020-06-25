import QtQuick 2.13
import "../imports"

Rectangle {
    id: root
    property int size: 36
    property color bg: Theme.blue
    property url imgPath: ""
    signal clicked

    width: size
    height: size
    color: bg
    radius: size / 2

    SVGImage {
        id: roundedIconImage
        width: 12
        height: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: imgPath
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.clicked()
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.75}
}
##^##*/
