import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    header: Text {
      text: qsTr("User profile")
      anchors.top: parent.top
      anchors.left: parent.left
      font.bold: true
      font.pixelSize: 17
      anchors.leftMargin: 16
      anchors.topMargin: Theme.padding
      anchors.bottomMargin: Theme.padding
    }

    Rectangle {
      id: profilePic
      width: 120
      height: 120
      radius: 100
      border.color: "#10000000"
      border.width: 1
      color: Theme.transparent
      anchors.horizontalCenter: parent.horizontalCenter
      anchors.top: parent.top
      anchors.topMargin: 16
      Image {
          width: 120
          height: 120
          fillMode: Image.PreserveAspectFit
          source: identicon
      }
    }

    Text {
      id: userNameText
      text: userName
      anchors.top: profilePic.bottom
      anchors.topMargin: 16
      anchors.horizontalCenter: parent.horizontalCenter
      font.bold: true
      font.pixelSize: 16
    }

    TextEdit {
      text: fromAuthor.substr(0, 6) + "..." + fromAuthor.substr(fromAuthor.length - 4)
      anchors.top: userNameText.bottom
      anchors.topMargin: 12
      anchors.horizontalCenter: parent.horizontalCenter
      wrapMode: Text.Wrap
      readOnly: true
      selectByMouse: true
      color: Theme.darkGrey
      font.pixelSize: 15
    }

    footer: StyledButton {
        anchors.right: parent.right
        anchors.rightMargin: Theme.smallPadding
        label: "Close"
        anchors.bottom: parent.bottom
        onClicked: {
          profilePopup.close()
        }
    }
}
