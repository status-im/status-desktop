import QtQuick 2.0
import "../imports"

Rectangle {
    property int size: 36
    property color bg: Theme.blue
    property url imgPath: ""

    width: size
    height: size
    color: bg
    radius: 50

    Image {
        width: 12
        height: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: imgPath
    }
}

/*##^##
Designer {
    D{i:0;formeditorZoom:1.75}
}
##^##*/
