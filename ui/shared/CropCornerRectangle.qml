import QtQuick 2.13
import "../imports"

Rectangle {
    id: root
    width: 25
    height: 25
    border.width: 2
    border.color: Style.current.orange
    color: Utils.setColorAlpha(Style.current.orange, 0.5)

    Drag.active: dragArea.drag.active

    MouseArea {
        id: dragArea
        property int oldX
        property int oldY

        anchors.fill: parent
        drag.target: parent
        cursorShape: Qt.PointingHandCursor
    }
}
