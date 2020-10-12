import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    id: popup

    onOpened: {
        channelname.text = "";
    }

    function doJoin(){
        // TODO call contract to create the channel and change channel type to 4
        chatsModel.joinChat(channelname.text, Constants.chatTypePublic);
        popup.close();
    }

    title: qsTr("New permissioned chat")

    StyledText {
        id: chatInfo
        visible: selectChatMembers
        text: qsTr("A Permissioned chat is a channel that everyone can look at, but only the allowed members can write. It's perfect to reduce the risk of spam and create communities")
        color: Style.current.darkGrey
        font.pixelSize: 15
        width: parent.width
        wrapMode: Text.WordWrap
    }

    Input {
        id: channelname
        placeholderText: qsTr("Channel name")
        anchors.top: chatInfo.bottom
        anchors.topMargin: Style.current.smallPadding
    }
    
    footer: Item {
        anchors.top: parent.bottom
        anchors.right: parent.right
        anchors.bottom: popup.bottom
        anchors.left: parent.left

        StyledButton {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            label: qsTr("Create Permissioned Group Chat")
            disabled: channelname.text === ""
            onClicked : doJoin()
        }
    }
}

