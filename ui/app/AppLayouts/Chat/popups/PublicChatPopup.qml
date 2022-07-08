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
            channelNameValidationError = qsTr("You need to enter a channel name")
        } else if (!Utils.isValidChannelName(channelName.text)) {
            channelNameValidationError = qsTr("The channel name can only contain lowercase letters, numbers and dashes")
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
        text: qsTr("Start chat")
    }
}
