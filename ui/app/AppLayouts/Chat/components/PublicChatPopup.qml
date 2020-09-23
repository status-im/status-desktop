import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../data/channelList.js" as ChannelJSON
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

    ScrollView {
        id: sview
        clip: true

        anchors.top: channelName.bottom
        anchors.topMargin: Style.current.smallPadding
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom

        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOn
        Layout.fillHeight: true
        Layout.fillWidth: true
        contentHeight: {
            var totalHeight = 0
            for (let i = 0; i < sectionRepeater.count; i++) {
                totalHeight += sectionRepeater.itemAt(i).height + Style.current.padding
            }
            return totalHeight + Style.current.padding
        }

        SuggestedChannels {
            id: sectionRepeater
            width: parent.width
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
