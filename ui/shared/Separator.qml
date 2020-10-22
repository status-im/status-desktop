import QtQuick 2.13
import "../imports"

Rectangle {
      id: separator
      width: parent.width
      height: visible ? 1 : 0
      color: Style.current.border
      anchors.topMargin: Style.current.padding
}
