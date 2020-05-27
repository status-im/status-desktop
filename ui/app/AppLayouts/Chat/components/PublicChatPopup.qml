import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

Item {
  function open(){
    popup.open()
    channelName.forceActiveFocus(Qt.MouseFocusReason)
  }

  function close(){
    popup.close()
  }

  Popup {
    id: popup
    modal: true
    closePolicy: Popup.NoAutoClose
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
            text: qsTr("Join public chat")
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

        Row {
            id: description
            Layout.fillHeight: false
            Layout.fillWidth: true
            anchors.top: separator.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            width: parent.width
            padding: 20

            Text {
                width: parent.width - 20
                font.pixelSize: 15
                text: qsTr("A public chat is where you get to hang out with others, make friends and talk about subjects of your interest.")
                wrapMode: Text.WordWrap
                verticalAlignment: Text.AlignTop
            }
        }

        Rectangle {
            id: channelNameBox
            height: 44
            color: Theme.grey
            anchors.top: description.bottom
            radius: 8
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.left: parent.left
            anchors.leftMargin: 16

            TextField {
                id: channelName
                placeholderText: qsTr("chat-name")
                anchors.left: parent.left
                anchors.leftMargin: 32
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: 15
                background: Rectangle {
                    color: "#00000000"
                }
                width: popup.width - 65
            }

            Image {
                id: image4
                anchors.left: parent.left
                anchors.leftMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                fillMode: Image.PreserveAspectFit
                source: "../../../img/hash.svg"
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                onClicked : {
                    channelName.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }

        RowLayout {
            id: row
            Layout.fillHeight: false
            Layout.fillWidth: true
            anchors.right: parent.right
            anchors.rightMargin: 65
            anchors.left: parent.left
            anchors.leftMargin: 65
            anchors.top: channelNameBox.bottom
            anchors.topMargin: 37

            Flow {
                Layout.fillHeight: false
                Layout.fillWidth: true
                spacing: 20

                SuggestedChannel { channel: "ethereum" }
                SuggestedChannel { channel: "status" }
                SuggestedChannel { channel: "general" }
                SuggestedChannel { channel: "dapps" }
                SuggestedChannel { channel: "crypto" }
                SuggestedChannel { channel: "introductions" }
                SuggestedChannel { channel: "tech" }
                SuggestedChannel { channel: "ama" }
                SuggestedChannel { channel: "gaming" }
                SuggestedChannel { channel: "sexychat" }
                SuggestedChannel { channel: "nsfw" }
                SuggestedChannel { channel: "science" }
                SuggestedChannel { channel: "music" }
                SuggestedChannel { channel: "movies" }
                SuggestedChannel { channel: "sports" }
                SuggestedChannel { channel: "politics" }
            }
        }

        Separator {
            id: separator2
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 75
        }

        Button {
            id: btnJoinChat
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            anchors.bottomMargin: 16
            anchors.rightMargin: 16
            width: 44
            height: 44
            Image {
              source: channelName.text == "" ? "../../../img/arrow-button-inactive.svg" : "../../../img/arrow-btn-active.svg"
            }
            background: Rectangle {
              color: "transparent"
            }
            MouseArea {
                id: btnMAJoinChat
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    if(channelName.text === "") return;

                    chatsModel.joinChat(channelName.text)
                    popup.close()
                }
            }
        }
    }
  }
}
