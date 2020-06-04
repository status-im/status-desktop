import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup
    title: qsTr("New chat")

    onOpened: {
        chatKey.text = "";
        chatKey.forceActiveFocus(Qt.MouseFocusReason)
    }

    Rectangle {
        id: chatKeyBox
        height: 44
        color: Theme.grey
        anchors.top: parent.top
        radius: 8
        anchors.right: parent.right
        anchors.left: parent.left

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
            width: chatKeyBox.width - 32
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            onClicked : {
                chatKey.forceActiveFocus(Qt.MouseFocusReason)
            }
        }
    }



    footer: Button {
        width: 44
        height: 44
        anchors.bottom: parent.bottom
        anchors.right: parent.right
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
