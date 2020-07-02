import QtQuick 2.13
import QtQuick.Controls 2.13
import "../imports"
import "../shared"

ModalPopup {
  id: popup
  title: qsTr("Invalid seed phrase")
  height: 200
  property string error: "Invalid seed phrase."

  StyledText {
      text: qsTr(popup.error)
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.verticalCenter: parent.verticalCenter
      font.pixelSize: 15
  }
  
  footer: StyledButton {
      anchors.right: parent.right
      anchors.rightMargin: Style.current.smallPadding
      label: qsTr("Cancel")
      anchors.bottom: parent.bottom
      onClicked: {
          popup.close()
      }
  }
}
