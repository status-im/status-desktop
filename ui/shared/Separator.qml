import QtQuick 2.13
import "../imports"

Rectangle {
    id: root
    width: parent.width
    height: root.visible ? 1 : 0
    anchors.topMargin: Style.current.padding
    color: "transparent"
    Rectangle {
          id: separator
          width: parent.width
          height: 1
          color: Style.current.border
          anchors.verticalCenter: parent.verticalCenter
    }
}
