import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    id: popup
    property bool addMembers: false
    property int currMemberCount: 1
    property int memberCount: 1
    readonly property int maxMembers: 10
    property var pubKeys: []
    property bool isAdmin: false

    function resetSelectedMembers(){
        pubKeys = [];
        memberCount = chatsModel.activeChannel.members.rowCount();
        currMemberCount = memberCount;
        data.clear();
        const nbContacts = profileModel.contacts.list.rowCount()
        for(let i = 0; i < nbContacts; i++){
            if(chatsModel.activeChannel.contains(profileModel.contacts.list.rowData(i, "pubKey"))) continue;
            if(profileModel.contacts.list.rowData(i, "isContact") === "false") continue;
            data.append({
                name: profileModel.contacts.list.rowData(i, "name"),
                localNickname: profileModel.contacts.list.rowData(i, "localNickname"),
                pubKey: profileModel.contacts.list.rowData(i, "pubKey"),
                address: profileModel.contacts.list.rowData(i, "address"),
                identicon: profileModel.contacts.list.rowData(i, "identicon"),
                thumbnailImage: profileModel.contacts.list.rowData(i, "thumbnailImage"),
                isUser: false
            });
        }
    }

    onOpened: {
        addMembers = false;
        popup.isAdmin = chatsModel.activeChannel.isAdmin(profileModel.profile.pubKey)
        btnSelectMembers.enabled = false;
        resetSelectedMembers();
    }

    function doAddMembers(){
        if(pubKeys.length === 0) return;
        chatsModel.groups.addMembers(chatsModel.activeChannel.id, JSON.stringify(pubKeys));
        popup.close();
    }

    header: Item {
      height: children[0].height
      width: parent.width


      StatusLetterIdenticon {
          id: letterIdenticon
          width: 36
          height: 36
          anchors.top: parent.top
          color: chatsModel.activeChannel.color
          chatName: chatsModel.activeChannel.name
      }
    
      StyledTextEdit {
          id: groupName
          //% "Add members"
          text: addMembers ? qsTrId("add-members") : chatsModel.activeChannel.name
          anchors.top: parent.top
          anchors.topMargin: 2
          anchors.left: letterIdenticon.right
          anchors.leftMargin: Style.current.smallPadding
          font.bold: true
          font.pixelSize: 14
          readOnly: true
          wrapMode: Text.WordWrap
      }

      StyledText {
          text: {
            let cnt = memberCount;
            if(addMembers){
                //% "%1 / 10 members"
                return qsTrId("%1-/-10-members").arg(cnt)
            } else {
                //% "%1 members"
                if(cnt > 1) return qsTrId("%1-members").arg(cnt);
                //% "1 member"
                return qsTrId("1-member");
            }
          }
          width: 160
          anchors.left: letterIdenticon.right
          anchors.leftMargin: Style.current.smallPadding
          anchors.top: groupName.bottom
          anchors.topMargin: 2
          font.pixelSize: 14
          color: Style.current.darkGrey
      }

      Rectangle {
            id: editGroupNameBtn
            visible: !addMembers && popup.isAdmin
            height: 24
            width: 24
            anchors.verticalCenter: groupName.verticalCenter
            anchors.leftMargin: 4
            anchors.left: groupName.right
            radius: 8

            SVGImage {
                id: editGroupImg
                source: "../../../img/edit-group.svg"
                height: 16
                width: 16
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.verticalCenter: parent.verticalCenter
            }

            MouseArea {
                id: closeModalMouseArea
                cursorShape: Qt.PointingHandCursor
                anchors.fill: parent
                hoverEnabled: true
                onExited: {
                    editGroupNameBtn.color = Style.current.white
                }
                onEntered: {
                    editGroupNameBtn.color = Style.current.grey
                }
                onClicked: renameGroupPopup.open()
            }
        }

        RenameGroupPopup {
            id: renameGroupPopup
        }
    }

    Item {
        id: addMembersItem
        anchors.fill: parent

        SearchBox {
            id: searchBox
            visible: addMembers
            iconWidth: 17
            iconHeight: 17
            customHeight: 44
            fontPixelSize: 15
        }

        Rectangle {
            id: noContactsRect
            width: 320
            visible: data.count == 0
            anchors.top: searchBox.bottom
            anchors.topMargin: Style.current.xlPadding
            anchors.horizontalCenter: parent.horizontalCenter
            StyledText {
                id: noContacts
                //% "All your contacts are already in the group"
                text: qsTrId("group-chat-all-contacts-invited")
                color: Style.current.textColor
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                anchors.right: parent.right
                wrapMode: Text.WordWrap
                horizontalAlignment: Text.AlignHCenter
            }
            StyledButton {
                //% "Invite friends"
                label: qsTrId("invite-friends")
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.top: noContacts.bottom
                anchors.topMargin: Style.current.padding
                onClicked: {
                    inviteFriendsPopup.open()
                }
            }
            InviteFriendsPopup {
                id: inviteFriendsPopup
            }
        }

        ScrollView {
            visible: addMembers && data.count > 0
            anchors.fill: parent
            anchors.topMargin: 50
            anchors.top: searchBox.bottom
            Layout.fillWidth: true
            Layout.fillHeight: true

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            ScrollBar.vertical.policy: groupMembers.contentHeight > groupMembers.height ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff

            ListView {
                anchors.fill: parent
                model: ListModel {
                    id: data
                }
                spacing: 0
                clip: true
                id: groupMembers
                delegate: Contact {
                    isVisible: searchBox.text === "" || model.name.includes(searchBox.text)
                    showCheckbox: memberCount < maxMembers
                    pubKey: model.pubKey
                    isUser: model.isUser
                    name: model.name.endsWith(".eth") || !model.localNickname ?
                              Utils.removeStatusEns(model.name) : model.localNickname
                    address: model.address
                    identicon: model.thumbnailImage || model.identicon
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
                        memberCount = chatsModel.activeChannel.members.rowCount() + pubKeys.length;
                        btnSelectMembers.enabled = pubKeys.length > 0
                    }
                }
            }
        }

    }

    Item {
        id: groupInfoItem
        anchors.fill: parent

        StyledText {
            id: memberLabel
            //% "Members"
            text: qsTrId("members-title")
            anchors.left: parent.left
            anchors.leftMargin: Style.current.padding
            font.pixelSize: 15
            color: Style.current.darkGrey
        }

        ListView {
            id: memberList
            anchors.fill: parent
            anchors.top: memberLabel.bottom
            anchors.bottom: popup.bottom
            anchors.topMargin: 30
            anchors.bottomMargin: Style.current.padding
            spacing: 4
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: chatsModel.activeChannel.members
            delegate: Item {
                id: contactRow
                width: parent.width
                height: identicon.height

                property string nickname: {
                    // Get contact nickname
                    const contactList = profileModel.contacts.list
                    const contactCount = contactList.rowCount()
                    let nickname = ""
                    for (let i = 0; i < contactCount; i++) {
                        if (contactList.rowData(i, 'pubKey') === model.pubKey) {
                            return contactList.rowData(i, 'localNickname')
                        }
                    }
                    return ""
                }

                StatusImageIdenticon {
                    id: identicon
                    anchors.left: parent.left
                    source: chatView.getProfileImage(model.pubKey)|| model.identicon
                }

                StyledText {
                    text: !model.userName.endsWith(".eth") && !!contactRow.nickname ?
                              contactRow.nickname : Utils.removeStatusEns(model.userName)
                    anchors.left: identicon.right
                    anchors.leftMargin: Style.current.smallPadding
                    anchors.right: adminLabel.left
                    anchors.rightMargin: Style.current.smallPadding
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            const userProfileImage = chatView.getProfileImage(model.pubKey)
                            openProfilePopup(model.userName, model.pubKey, userProfileImage || model.identicon, '', contactRow.nickname)
                        }
                    }
                }

                StyledText {
                    id: adminLabel
                    visible: model.isAdmin
                    //% "Admin"
                    text: qsTrId("group-chat-admin")
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    font.pixelSize: 13
                }

                StyledText {
                    id: moreActionsBtn
                    visible: !model.isAdmin && popup.isAdmin
                    text: "..."
                    anchors.right: parent.right
                    anchors.rightMargin: Style.current.smallPadding
                    anchors.verticalCenter: parent.verticalCenter
                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            contextMenu.popup(-contextMenu.width / 2 + moreActionsBtn.width / 2, moreActionsBtn.height + 10)
                        }
                        cursorShape: Qt.PointingHandCursor
                        PopupMenu {
                            id: contextMenu
                            Action {
                                icon.source: "../../../img/make-admin.svg"
                                //% "Make Admin"
                                text: qsTrId("make-admin")
                                onTriggered: chatsModel.groups.makeAdmin(chatsModel.activeChannel.id,  model.pubKey)
                            }
                            Action {
                                icon.source: "../../../img/remove-from-group.svg"
                                icon.color: Style.current.red
                                //% "Remove From Group"
                                text: qsTrId("remove-from-group")
                                onTriggered: chatsModel.groups.kickMember(chatsModel.activeChannel.id,  model.pubKey)
                            }
                        }
                    }
                }
            }
        }
    }

    footer: Item {
        visible: popup.isAdmin
        width: parent.width
        height: children[0].height
        StyledButton {
          visible: !addMembers
          anchors.right: parent.right
          //% "Add members"
          label: qsTrId("add-members")
          anchors.bottom: parent.bottom
          onClicked: {
            addMembers = true;
          }
        }

        Button {
            id: btnBack
            visible: addMembers
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
                    addMembers = false;
                    resetSelectedMembers();
                }
            }
        }

        StyledButton {
          id: btnSelectMembers
          visible: addMembers
          disabled: memberCount <= currMemberCount
          anchors.right: parent.right
          //% "Add selected"
          label: qsTrId("add-selected")
          anchors.bottom: parent.bottom
          onClicked: doAddMembers()
        }
    }

    content: addMembers ? addMembersItem : groupInfoItem
}
