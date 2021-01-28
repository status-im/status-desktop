import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared"
import "../shared/status"

ModalPopup {
  id: popup
  //% "Invalid seed phrase"
  title: qsTrId("custom-seed-phrase")
  height: 200
  property string error: "Invalid seed phrase."

  StyledText {
      text: popup.error
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 15
  }
  
  footer: StatusButton {
      anchors.right: parent.right
      anchors.rightMargin: Style.current.smallPadding
      //% "Cancel"
      text: qsTrId("browsing-cancel")
      anchors.bottom: parent.bottom
      onClicked: {
          popup.close()
      }
  }
}
