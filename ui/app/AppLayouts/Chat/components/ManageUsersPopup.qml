import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"
import "./"

ModalPopup {
    id: popup
    property int currMemberCount: 1
    property int memberCount: 1
    property var pubKeys: []

    function resetSelectedMembers(){
        // TODO get operators from the contract once we can have it as an array
        //        pubKeys = [];
        //        memberCount = chatsModel.activeChannel.members.rowCount();
        //        currMemberCount = memberCount;
        //        data.clear();
        //        const nbContacts = profileModel.contactList.rowCount()
        //        for(let i = 0; i < nbContacts; i++){
        //            if(chatsModel.activeChannel.contains(profileModel.contactList.rowData(i, "pubKey"))) continue;
        //            if(profileModel.contactList.rowData(i, "isContact") === "false") continue;
        //            data.append({
        //                name: profileModel.contactList.rowData(i, "name"),
        //                localNickname: profileModel.contactList.rowData(i, "localNickname"),
        //                pubKey: profileModel.contactList.rowData(i, "pubKey"),
        //                address: profileModel.contactList.rowData(i, "address"),
        //                identicon: profileModel.contactList.rowData(i, "identicon"),
        //                isUser: false
        //            });
        //        }
    }

    onOpened: {
        resetSelectedMembers();
    }

    function doChangeUsers() {
        if(pubKeys.length === 0) return;
        chatsModel.addGroupMembers(chatsModel.activeChannel.id, JSON.stringify(pubKeys));
        popup.close();
    }

    // TODO put this back bigger once we have the list
    height: 265

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
            text: qsTr("Manage Users")
            anchors.verticalCenter: letterIdenticon.verticalCenter
            anchors.left: letterIdenticon.right
            anchors.leftMargin: Style.current.smallPadding
            font.bold: true
            font.pixelSize: 14
            readOnly: true
            wrapMode: Text.WordWrap
        }
    }

    /*Item {
        id: addMembersItem
        anchors.fill: parent

        SearchBox {
            id: searchBox
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
                    isVisible: searchBox.text == "" || model.name.includes(searchBox.text)
                    showCheckbox: memberCount < maxMembers
                    pubKey: model.pubKey
                    isUser: model.isUser
                    name: model.name.endsWith(".eth") && !!model.localNickname ?
                              Utils.removeStatusEns(model.name) : model.localNickname
                    address: model.address
                    identicon: model.identicon
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
    }*/

    Column {
        spacing: Style.current.padding
        width: parent.width

        Item {
            height: addOperatorField.height
            width: parent.width

            Input {
                id: addOperatorField
                label: qsTr("Add a user")
                placeholderText: qsTr("User address")
                anchors.right: btnAddOperator.left
                anchors.rightMargin: Style.current.halfPadding
            }

            StyledButton {
                id: btnAddOperator
                label: qsTr("Add")
                anchors.right: parent.right
                anchors.bottom: addOperatorField.bottom
                onClicked: {
                    console.log('ADD ME', addOperatorField.text)
                }
            }
        }

        Item {
            height: removeOperatorField.height
            width: parent.width

            Input {
                id: removeOperatorField
                label: qsTr("Remove a user")
                placeholderText: qsTr("User address")
                anchors.right: btnRemoveOperator.left
                anchors.rightMargin: Style.current.halfPadding
            }

            StyledButton {
                id: btnRemoveOperator
                label: qsTr("Remove")
                anchors.right: parent.right
                anchors.bottom: removeOperatorField.bottom
                onClicked: {
                    console.log('REMOVE ME', removeOperatorField.text)
                }
            }
        }
    }
}
