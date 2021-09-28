import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3

import utils 1.0
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    id: popup

    property var pubKeys: []
    property bool selectChatMembers: true
    property int memberCount: 1
    readonly property int maxMembers: 10
    property string channelNameValidationError: ""

    onOpened: {
        groupName.text = "";
        searchBox.text = "";
        selectChatMembers = true;
        memberCount = 1;
        pubKeys = [];

        contactList.membersData.clear();

        getContactListObject(contactList.membersData)

        contactList.membersData.append({
            //% "(You)"
            name: profileModel.profile.username + " " + qsTrId("(you)"),
            pubKey: profileModel.profile.pubKey,
            address: "",
            identicon: profileModel.profile.identicon,
            thumbnailImage: profileModel.profile.thumbnailImage,
            isUser: true
        });
        noContactsRect.visible = !profileModel.contacts.list.hasAddedContacts();
        contactList.visible = !noContactsRect.visible;
        if (!contactList.visible) {
            memberCount = 0;
        }
    }

    function validate() {
        if (groupName.text === "") {
            //% "You need to enter a channel name"
            channelNameValidationError = qsTrId("you-need-to-enter-a-channel-name")
        } else if (!Utils.isValidChannelName(groupName.text)) {
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
        if (pubKeys.length === 0) {
            return;
        }
        chatsModel.groups.create(Utils.filterXSS(groupName.text), JSON.stringify(pubKeys));
        popup.close();
    }

    function groupNameFilter(text) {
        groupName.text = text.toLowerCase().replace(' ', '-');
    }

    header: Item {
      height: 30
      width: parent.width
   
      StyledText {
          id: lblNewGroup
          //% "New group chat"
          text: qsTrId("new-group-chat")
          anchors.left: parent.left
          font.bold: true
          font.pixelSize: 17
          anchors.top: parent.top
      }

      StyledText {
          anchors.top: lblNewGroup.bottom
          //% "%1 / 10 members"
          text: qsTrId("%1-/-10-members").arg(memberCount)
          color: Style.current.secondaryText
          font.pixelSize: 15
      }
    }

    SearchBox {
        id: searchBox
        visible: selectChatMembers
        iconWidth: 17
        iconHeight: 17
        customHeight: 44
        fontPixelSize: 15
    }

    Input {
        id: groupName
        //% "Group name"
        placeholderText: qsTrId("group-name")
        visible: !selectChatMembers
        validationError: channelNameValidationError
        onTextEdited: function (text) {
            groupNameFilter(text)
        }
        validator: RegExpValidator { regExp: /^[a-zA-Z0-9\-\ ]+$/ }
    }

    NoFriendsRectangle {
        id: noContactsRect
        anchors.top: groupName.bottom
        anchors.topMargin: Style.current.xlPadding
        anchors.horizontalCenter: parent.horizontalCenter
    }

    ContactList {
        id: contactList
        searchString: searchBox.text.toLowerCase()
        selectMode: selectChatMembers && memberCount < maxMembers
        anchors.topMargin: 50
        anchors.top: searchBox.bottom
        onItemChecked: function(pubKey, itemChecked){
            var idx = pubKeys.indexOf(pubKey)
            if(itemChecked){
                if(idx === -1){
                    pubKeys.push(pubKey)
                }
            } else {
                if(idx > -1){
                    pubKeys.splice(idx, 1);
                }
            }
            memberCount = pubKeys.length + 1;
            btnSelectMembers.enabled = pubKeys.length > 0
        }
    }

    footer: Item {
        width: parent.width
        height: btnSelectMembers.height

        StatusRoundButton {
            id: btnSelectMembers
            visible: selectChatMembers
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            icon.name: "arrow-right"
            type: "secondary"
            icon.width: 20
            icon.height: 16
            enabled: !!pubKeys.length
            onClicked : {
                if(pubKeys.length > 0)
                    selectChatMembers = false
                    searchBox.text = ""
                    groupName.forceActiveFocus(Qt.MouseFocusReason)
            }
        }

        StatusRoundButton {
            id: btnBack
            visible: !selectChatMembers
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked : {
                selectChatMembers = true
            }
        }

        StatusButton {
            visible: !selectChatMembers
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            //% "Create Group Chat"
            text: qsTrId("create-group-chat")
            enabled: groupName.text !== ""
            onClicked : doJoin()
        }
    }
}

