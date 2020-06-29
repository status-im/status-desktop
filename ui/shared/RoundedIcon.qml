import QtQuick 2.13
import QtGraphicalEffects 1.0
import "../imports"

Rectangle {
    id: root
    property alias source: roundedIconImage.source
    default property alias content: content.children
    property alias icon: roundedIconImage
    signal clicked
    width: 36
    height: 36
    property alias iconWidth: roundedIconImage.width
    property alias iconHeight: roundedIconImage.height
    property alias rotation: roundedIconImage.rotation

    color: Style.current.blue
    radius: width / 2

    SVGImage {
        id: roundedIconImage
        width: 12
        height: 12
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        fillMode: Image.PreserveAspectFit
        source: "../img/new_chat.svg"
    }

    Item {
        id: content
        anchors.left: roundedIconImage.right
        anchors.leftMargin: 6 + (root.width - roundedIconImage.width)
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
