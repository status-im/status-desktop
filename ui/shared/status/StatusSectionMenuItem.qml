import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.13
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
              source: "../../app/img/caret.svg"
              width: 13
              height: 7
              rotation: -90
              anchors.verticalCenter: parent.verticalCenter
          }

          ColorOverlay {
              anchors.fill: icon
              source: icon
              color: Style.current.darkGrey
              rotation: -90
              antialiasing: true
          }
      }
  }

  MouseArea {
      cursorShape: Qt.PointingHandCursor
      anchors.fill: parent
      onPressed: mouse.accepted = false
  }
}
