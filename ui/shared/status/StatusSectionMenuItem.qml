import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../imports"
import "../../shared"

Button {
  id: control
  property string label: ""
  property string description: ""
  property string info: ""

  width: parent.width
  horizontalPadding: 0

  background: Rectangle {
    anchors.fill: parent
    color: "transparent"
  }

  contentItem: RowLayout {
      id: item
      width: parent.width

      Column {
          spacing: 2

          StyledText {
              text: control.label
              font.pixelSize: 15
          }

          StyledText {
              text: control.description
              color: Style.current.secondaryText
              font.pixelSize: 15
          }
      }

      Item {
          Layout.alignment: Qt.AlignRight
          height: info.height
          StyledText {
              id: info
              text: control.info
              color: Style.current.secondaryText
              font.pixelSize: 15
              anchors.right: icon.left
              anchors.rightMargin: icon.width + Style.current.padding
          }

          SVGImage {
              id: icon
              source: "/../../app/img/caret-right.svg"
              width: 7
              height: 13
              anchors.verticalCenter: parent.verticalCenter
          }
      }
  }

  MouseArea {
      cursorShape: Qt.PointingHandCursor
      anchors.fill: parent
      onPressed: mouse.accepted = false
  }
}
