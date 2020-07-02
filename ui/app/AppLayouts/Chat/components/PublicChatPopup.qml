import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "./"

ModalPopup {
    function doJoin() {
        if(channelName.text === "") return;
        chatsModel.joinChat(channelName.text, Constants.chatTypePublic);
        popup.close();
        
    }

    id: popup
    title: qsTr("Join public chat")

    onOpened: {
        channelName.text = "";
        channelName.forceActiveFocus(Qt.MouseFocusReason)
    }
    
    Row {
        id: description
        Layout.fillHeight: false
        Layout.fillWidth: true
        width: parent.width

        StyledText {
            width: parent.width
            font.pixelSize: 15
            text: qsTr("A public chat is where you get to hang out with others, make friends and talk about subjects of your interest.")
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
        }
    }

    Input {
        id: channelName
        anchors.top: description.bottom
        anchors.topMargin: Style.current.padding
        placeholderText: qsTr("chat-name")
        Keys.onEnterPressed: doJoin()
        Keys.onReturnPressed: doJoin()
        icon: "../../../img/hash.svg"
    }

    RowLayout {
        id: row
        Layout.fillHeight: false
        Layout.fillWidth: true
        anchors.right: parent.right
        anchors.rightMargin: 35
        anchors.left: parent.left
        anchors.leftMargin: 35
        anchors.top: channelName.bottom
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

    footer: Button {
        width: 44
        height: 44
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        background: Rectangle {
            color: "transparent"
        }
        SVGImage {
            source: channelName.text == "" ? "../../../img/arrow-button-inactive.svg" : "../../../img/arrow-btn-active.svg"
            width: 50
            height: 50
        }
        MouseArea {
            id: btnMAJoinChat
            cursorShape: Qt.PointingHandCursor
            anchors.fill: parent
            onClicked : doJoin()
        }
    }
}
