import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    property var identicon: ""
    property var userName: ""
    property var fromAuthor: ""

    function openPopup(userNameParam, fromAuthorParam, identiconParam) {
        this.userName = userNameParam
        this.fromAuthor = fromAuthorParam
        this.identicon = identiconParam
        popup.open()
    }

    header: Item {
      height: children[0].height
      width: parent.width
      Rectangle {
        id: profilePic
        width: 40
        height: 40
        radius: 30
        border.color: "#10000000"
        border.width: 1
        color: Theme.transparent
        anchors.top: parent.top
        anchors.topMargin: Theme.padding
        Image {
            width: parent.width
            height: parent.height
            fillMode: Image.PreserveAspectFit
            source: identicon
        }
      }

      TextEdit {
          id: profileName
          text: userName
          anchors.top: parent.top
          anchors.topMargin: 18
          anchors.left: profilePic.right
          anchors.leftMargin: Theme.smallPadding
          font.bold: true
          font.pixelSize: 14
          readOnly: true
          wrapMode: Text.WordWrap
      }

      Text {
          text: fromAuthor
          width: 160
          elide: Text.ElideMiddle
          anchors.left: profilePic.right
          anchors.leftMargin: Theme.smallPadding
          anchors.top: profileName.bottom
          anchors.topMargin: 2
          font.pixelSize: 14
          color: Theme.darkGrey
          font.family: "Inter"
      }

      // TODO(pascal): implement qrcode view
      // Rectangle {
      //     id: qrCodeButton
      //     height: 32
      //     width: 32
      //     anchors.top: parent.top
      //     anchors.topMargin: Theme.padding
      //     anchors.right: parent.right
      //     anchors.rightMargin: 32 + Theme.smallPadding
      //     radius: 8

      //     Image {
      //         source: "../../../../shared/img/qr-code-icon.svg"
      //         anchors.horizontalCenter: parent.horizontalCenter
      //         anchors.verticalCenter: parent.verticalCenter
      //     }

      //     MouseArea {
      //         cursorShape: Qt.PointingHandCursor
      //         anchors.fill: parent
      //         hoverEnabled: true
      //         onExited: {
      //             qrCodeButton.color = Theme.white
      //         }
      //         onEntered:{
      //             qrCodeButton.color = Theme.grey
      //         }
      //     }
      // }
    }

    Text {
      id: labelEnsUsername
      text: qsTr("ENS username")
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Theme.darkGrey
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: parent.top
      anchors.topMargin: Theme.smallPadding
    }

    Text {
      id: valueEnsName
      text: "@emily.stateofus.eth"
      font.pixelSize: 14
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: labelEnsUsername.bottom
      anchors.topMargin: Theme.smallPadding
    }

    Text {
      id: labelChatKey
      text: qsTr("Chat key")
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Theme.darkGrey
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: valueEnsName.bottom
      anchors.topMargin: Theme.padding
    }

    Text {
      id: valueChatKey
      text: fromAuthor
      width: 160
      elide: Text.ElideMiddle
      font.pixelSize: 14
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: labelChatKey.bottom
      anchors.topMargin: Theme.smallPadding
    }

    Separator {
      id: separator
      anchors.top: valueChatKey.bottom
      anchors.topMargin: Theme.padding
      anchors.left: parent.left
      anchors.leftMargin: -Theme.padding
      anchors.right: parent.right
      anchors.rightMargin: -Theme.padding
    }

    Text {
      id: labelShareURL
      text: qsTr("Share Profile URL")
      font.pixelSize: 13
      font.weight: Font.Medium
      color: Theme.darkGrey
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: separator.bottom
      anchors.topMargin: Theme.padding
    }

    Text {
      id: valueShareURL
      text: "https://join.status.im/u/" + fromAuthor.substr(0, 4) + "..." + fromAuthor.substr(fromAuthor.length - 5)
      font.pixelSize: 14
      anchors.left: parent.left
      anchors.leftMargin: Theme.smallPadding
      anchors.top: labelShareURL.bottom
      anchors.topMargin: Theme.smallPadding
    }

    // TODO(pascal): implement copy to clipboard component
    // Rectangle {
    //     id: copyToClipboardButton
    //     height: 32
    //     width: 32
    //     anchors.top: labelShareURL.bottom
    //     anchors.topMargin: Theme.padding
    //     anchors.left: valueShareURL.right
    //     anchors.leftMargin: Theme.padding
    //     radius: 8

    //     Image {
    //         source: "../../../../shared/img/copy-to-clipboard-icon.svg"
    //         anchors.horizontalCenter: parent.horizontalCenter
    //         anchors.verticalCenter: parent.verticalCenter
    //     }

    //     MouseArea {
    //         cursorShape: Qt.PointingHandCursor
    //         anchors.fill: parent
    //         hoverEnabled: true
    //         onExited: {
    //             copyToClipboardButton.color = Theme.white
    //         }
    //         onEntered:{
    //             copyToClipboardButton.color = Theme.grey
    //         }
    //     }
    // }

    footer: Item {
        width: parent.width
        height: children[0].height

        StyledButton {
          anchors.right: parent.right
          anchors.rightMargin: addToContactsButton.width + 32
          btnColor: "white"
          btnBorderWidth: 1
          btnBorderColor: "#EEF2F5"
          textColor: "#FF2D55"
          label: "Block User"
          anchors.bottom: parent.bottom
          onClicked: {
            chatsModel.blockContact(fromAuthor)
            // TODO(pascal): Change block user button state based
            // on :contact/blocked state
            profilePopup.close()
          }
        }

        StyledButton {
          id: addToContactsButton
          anchors.right: parent.right
          anchors.rightMargin: Theme.smallPadding
          label: "Add to contacts"
          anchors.bottom: parent.bottom
          onClicked: {
            chatsModel.addContact(fromAuthor)
            // TODO(iuri): Change add contact button state based
            // on contact already added or not
            profilePopup.close()
          }
      }
    }
}
