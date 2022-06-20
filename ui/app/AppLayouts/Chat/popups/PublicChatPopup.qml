import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import utils 1.0
import shared.controls 1.0

import StatusQ.Controls 0.1

import shared.panels 1.0
import shared.popups 1.0
import "../helpers/channelList.js" as ChannelJSON
import "../panels"

// TODO: replace with StatusModal
ModalPopup {
    property string channelNameValidationError: ""
    signal joinPublicChat(string name)
    signal suggestedMessageClicked(string channel)
    function validate() {
        if (channelName.text === "") {
            //% "You need to enter a channel name"
            channelNameValidationError = qsTrId("you-need-to-enter-a-channel-name")
        } else if (!Utils.isValidChannelName(channelName.text)) {
            //% "The channel name can only contain lowercase letters, numbers and dashes"
            channelNameValidationError = qsTrId("the-channel-name-can-only-contain-lowercase-letters--numbers-and-dashes")
        } else {
            channelNameValidationError = ""
        }

        return channelNameValidationError === ""
    }

    function doJoin() {
        if (!validate()) {
            return
        }
        popup.joinPublicChat(channelName.text);
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
            font.pixelSize: Style.current.primaryTextFontSize
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
        icon: Style.svg("hash")
        validationError: channelNameValidationError
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

        SuggestedChannelsPanel {
            id: sectionRepeater
            width: parent.width
            onSuggestedMessageClicked: {
                popup.suggestedMessageClicked(channel);
            }
        }
    }

    footer: StatusButton {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        onClicked : doJoin()
        //% "Start chat"
        text: qsTrId("start-chat")
    }
}
