import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {

    function doJoin(){
        if(chatKey.text === "") return;
        chatsModel.joinChat(chatKey.text, Constants.chatTypeOneToOne);
        popup.close();
    }

    id: popup
    title: qsTr("New chat")

    onOpened: {
        chatKey.text = "";
        chatKey.forceActiveFocus(Qt.MouseFocusReason)
    }

    Input {
        id: chatKey
        placeholderText: qsTr("Enter ENS username or chat key")
        Keys.onEnterPressed: doJoin()
        Keys.onReturnPressed: doJoin()
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
            onClicked : doJoin()
        }
    }
}
