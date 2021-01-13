import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Layouts 1.3
import QtQml.Models 2.3
import "../../../../imports"
import "../../../../shared"
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
        btnSelectMembers.state = "inactive";

        contactList.membersData.clear();

        chatView.getContactListObject(contactList.membersData)

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
            channelNameValidationError = qsTr("You need to enter a channel name")
        } else if (!Utils.isValidChannelName(groupName.text)) {
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
        if (pubKeys.length === 0) {
            return;
        }
        chatsModel.groups.create(Utils.filterXSS(groupName.text), JSON.stringify(pubKeys));
        popup.close();
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
          color: Style.current.darkGrey
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
            btnSelectMembers.state = pubKeys.length > 0 ? "active" : "inactive"
        }
    }

    footer: Item {
        width: parent.width
        height: btnSelectMembers.height

        Button {
            id: btnSelectMembers
            visible: selectChatMembers
            width: 44
            height: 44
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            state: "inactive"
            states: [
                State {
                    name: "inactive"
                    PropertyChanges {
                        target: btnSelectMembersImg
                        source: "../../../img/arrow-right-btn-inactive.svg"
                    }
                },
                State {
                    name: "active"
                    PropertyChanges {
                        target: btnSelectMembersImg
                        source: "../../../img/arrow-right-btn-active.svg"
                    }
                }
            ]
            SVGImage {
                id: btnSelectMembersImg
                width: 50
                height: 50
            }
            background: Rectangle {
                color: "transparent"
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    if(pubKeys.length > 0)
                        selectChatMembers = false
                        searchBox.text = ""
                        groupName.forceActiveFocus(Qt.MouseFocusReason)
                }
            }
        }

        Button {
            id: btnBack
            visible: !selectChatMembers
            width: 44
            height: 44
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            SVGImage {
                source: "../../../img/arrow-left-btn-active.svg"
                width: 50
                height: 50
            }
            background: Rectangle {
                color: "transparent"
            }
            MouseArea {
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                onClicked : {
                    selectChatMembers = true
                }
            }
        }

        StyledButton {
            visible: !selectChatMembers
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            //% "Create Group Chat"
            label: qsTrId("create-group-chat")
            disabled: groupName.text === ""
            onClicked : doJoin()
        }
    }
}

