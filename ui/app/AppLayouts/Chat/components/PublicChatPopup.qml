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
    //% "Join public chat"
    title: qsTrId("new-public-group-chat")

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
            //% "A public chat is where you get to hang out with others, make friends and talk about subjects of your interest."
            text: qsTrId("a-public-chat-is-where-you-get-to-hang-out-with-others,-make-friends-and-talk-about-subjects-of-your-interest.")
            wrapMode: Text.WordWrap
            verticalAlignment: Text.AlignTop
        }
    }

    Input {
        id: channelName
        anchors.top: description.bottom
        anchors.topMargin: Style.current.padding
        //% "chat-name"
        placeholderText: qsTrId("chat-name")
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

            SuggestedChannel { channel: "ethereum"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "status"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "general"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "dapps"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "crypto"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "introductions"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "tech"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "ama"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "gaming"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "sexychat"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "nsfw"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "science"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "music"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "movies"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "sports"; onJoin: function() { popup.close() } }
            SuggestedChannel { channel: "politics"; onJoin: function() { popup.close() } }
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
