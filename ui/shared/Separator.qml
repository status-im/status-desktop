import QtQuick 2.13

import utils 1.0

Item {
    id: root
    property color color: Style.current.separator
    width: parent.width
    height: root.visible ? 1 : 0
    anchors.topMargin: Style.current.padding
    Rectangle {
          id: separator
          width: parent.width
          height: 1
          color: root.color
          anchors.verticalCenter: parent.verticalCenter
    }
}
