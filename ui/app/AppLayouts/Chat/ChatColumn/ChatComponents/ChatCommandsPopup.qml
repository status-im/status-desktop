import QtQuick 2.13
import QtQuick.Controls 2.13
import QtGraphicalEffects 1.13
import "../../../../../imports"
import "../../../../../shared"

Popup {
  id: root
  width: buttonRow.width
  height: buttonRow.height
  padding: 0
  margins: 0

  background: Rectangle {
      color: Style.current.background
      radius: Style.current.radius
      border.width: 0
      layer.enabled: true
      layer.effect: DropShadow{
          verticalOffset: 3
          radius: 8
          samples: 15
          fast: true
          cached: true
          color: "#22000000"
      }
  }

  Row {
      id: buttonRow
      anchors.left: parent.left
      anchors.leftMargin: 0
      anchors.top: parent.top
      anchors.topMargin: 0
      padding: Style.current.halfPadding
      spacing: Style.current.halfPadding

      ChatCommandButton {
          iconColor: Style.current.purple
          iconSource: "../../../../img/send.svg"
          text: qsTr("Send transaction")
      }

      ChatCommandButton {
          iconColor: Style.current.orange
          iconSource: "../../../../img/send.svg"
          rotatedImage: true
          text: qsTr("Request transaction")
      }
  }
}
