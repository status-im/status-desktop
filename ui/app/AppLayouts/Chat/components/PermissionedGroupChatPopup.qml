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

    function doCreate(channelName){
        // TODO call contract to create the channel and change channel type to 4
        chatsModel.joinChat(channelName, Constants.chatTypePublic);
        popup.close();
    }

    function doJoin(channelName){
        chatsModel.joinChat(channelName, Constants.chatTypePublic);
        popup.close();
    }

    function checkChannelExistence(channelName) {
        const request = {
            type: "channels",
            payload: [utilsModel.channelHash(channelName)]
        }
        ethersChannel.postMessage(request, (channel) => {
                                      if (channel === Constants.zeroAddress) {
                                          // New channel, call create
                                          return doCreate(channelName)
                                      }
                                      doJoin(channelName)
                                  })
    }

    title: qsTr("New Moderated Chat")

    StyledText {
        id: chatInfo
        text: qsTr("A Moderated chat is a channel that everyone can look at, but only the allowed members can write. It's perfect to reduce the risk of spam and create communities")
        color: Style.current.darkGrey
        font.pixelSize: 15
        width: parent.width
        wrapMode: Text.WordWrap
    }

    Input {
        id: channelname
        label: qsTr("Channel name")
        placeholderText: qsTr("Channel name")
        textField.text: Constants.moderatedChannelPrefix
        textField.onTextChanged: {
            if (!textField.text.startsWith(Constants.moderatedChannelPrefix)) {
                // Make sure moderated- is always at the start
                // The regex makes it so that we don,t just duplicate moderated- but instead replaces what's there
                textField.text = textField.text.replace(/m?o?d?e?r?a?t?e?d?-?/, Constants.moderatedChannelPrefix)
            }
        }
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
            label: qsTr("Check if the channel exists")
            disabled: channelname.text === ""
            onClicked : checkChannelExistence(channelname.text)
        }
    }
}

