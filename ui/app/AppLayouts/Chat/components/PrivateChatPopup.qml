import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

Item {
  function open() {
    popup.open()
    chatKey.text = "";
    chatKey.forceActiveFocus(Qt.MouseFocusReason)
  }

  function close() {
    popup.close()
  }

  Popup {
    id: popup
    modal: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    Overlay.modal: Rectangle {
        color: "#60000000"
    }
    parent: Overlay.overlay
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2)
    width: 480
    height: 509
    background: Rectangle {
        color: Theme.white
        radius: 8
    }
    padding: 0
    contentItem: Item {
        Text {
            id: modalDialogTitle
            text: qsTr("New chat")
            anchors.top: parent.top
            anchors.left: parent.left
            font.bold: true
            font.pixelSize: 17
            anchors.leftMargin: 16
            anchors.topMargin: 16
        }

        Image {
            id: closeModalImg
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.topMargin: 16
            source: "../../../img/close.svg"
            MouseArea {
                id: closeModalMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    popup.close()
                }
            }
        }
        
        Separator {
            id: separator
            anchors.top: modalDialogTitle.bottom
        }

        Rectangle {
            id: chatKeyBox
            height: 44
            color: Theme.grey
            anchors.top: separator.bottom
            anchors.topMargin: 16
            radius: 8
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16

            TextField {
                id: chatKey
                placeholderText: qsTr("Enter ENS username or chat key")
                anchors.left: parent.left
                anchors.leftMargin: 16
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                background: Rectangle {
                    color: "#00000000"
                }
                width: popup.width - 65
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked : {
                    chatKey.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }

        Separator {
            id: separator2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
        }

        Button {
            id: btnNewChat
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 16
            anchors.rightMargin: 16
            width: 44
            height: 44
            Image {
              source: chatKey.text == "" ? "../../../img/arrow-button-inactive.svg" : "../../../img/arrow-btn-active.svg"
            }
            background: Rectangle {
              color: "transparent"
            }
            MouseArea {
                id: btnMAnewChat
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    if(chatKey.text === "") return;
                    chatsModel.joinChat(chatKey.text, Constants.chatTypeOneToOne);
                    popup.close();
                }
            }
        }
    }
  }
}
