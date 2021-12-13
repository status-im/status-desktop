import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1
import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1

import utils 1.0

import shared.views 1.0
import shared.panels 1.0
import shared.status 1.0

import "../panels"

StatusModal {
    id: popup

    enum ChannelType {
        ActiveChannel,
        ContextChannel
    }
    property var store
    property bool addMembers: false
    property int currMemberCount: 1
    property int memberCount: 1
    readonly property int maxMembers: 10
    property var pubKeys: []
    property int channelType: GroupInfoPopup.ChannelType.ActiveChannel
    property QtObject channel
    property bool isAdmin: false
    property Component pinnedMessagesPopupComponent

    function resetSelectedMembers(){
        pubKeys = []

        memberCount = channel ? channel.members.rowCount() : 0
        currMemberCount = memberCount
        popup.store.addToGroupContacts.clear()
        popup.store.reCalculateAddToGroupContacts(channel)
    }

    function doAddMembers(){
        if(pubKeys.length === 0) return;
        if (popup.channel) {
            // Not Refactored Yet
//            chatsModel.groups.addMembers(popup.channel.id, JSON.stringify(pubKeys));
        }
        popup.close();
    }

    height: 504
    anchors.centerIn: parent

    //% "Add members"
    header.title: addMembers ? qsTrId("add-members") : (popup.channel ? popup.channel.name : "")
    header.subTitle:  {
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
    header.editable: !addMembers && popup.isAdmin
    header.icon.isLetterIdenticon: true
    header.icon.name: popup.channel ? popup.channel.name : ""
    header.icon.background.color: popup.channel ? popup.channel.color : "transparent"

    onEditButtonClicked: renameGroupPopup.open()

    onClosed: {
        popup.destroy();
    }

    onOpened: {
        addMembers = false;
        if (popup.channel) {
            popup.isAdmin = popup.channel.isAdmin(userProfile.pubKey)
        }
        btnSelectMembers.enabled = false;
        resetSelectedMembers();
    }

    ColumnLayout {
        id: addMembersItem

        width: parent.width - 2*Style.current.padding
        height: parent.height
        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter

        visible: addMembers

        spacing: Style.current.padding

        StatusBaseInput {
            id: searchBox
            implicitHeight: 36
            //% "Search"
            placeholderText: qsTrId("search")
            placeholderFont.pixelSize: 15
            icon.name: "search"
            icon.width: 17
            icon.height: 17
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
        }

        NoFriendsRectangle {
            visible: popup.store.addToGroupContacts.count === 0 && memberCount === 0
            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.bottomMargin: childrenRect.height
        }

        NoFriendsRectangle {
            visible: popup.store.addToGroupContacts.count === 0 && memberCount > 0
            //% "All your contacts are already in the group"
            text: qsTrId("group-chat-all-contacts-invited")
            textColor: Style.current.textColor
            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.bottomMargin: childrenRect.height
        }

        ContactListPanel {
            id: contactList
            visible: popup.store.addToGroupContacts.count > 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: popup.store.addToGroupContacts
            selectMode: memberCount < maxMembers
            searchString: searchBox.text.toLowerCase()
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
                memberCount = popup.channel.members.rowCount() + pubKeys.length;
                btnSelectMembers.enabled = pubKeys.length > 0
            }
        }
    }

    ColumnLayout {
        id: groupInfoItem

        width: parent.width - 2*Style.current.padding
        height: parent.height - 2*Style.current.padding
        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

        visible: !addMembers
        spacing: Style.current.padding

        StatusSettingsLineButton {
            // Not Refactored Yet
            property int pinnedCount: 0 // popup.store.chatsModelInst.messageView.pinnedMessagesList.count

            id: pinnedMessagesBtn
            visible: pinnedCount > 0
            //% "Pinned messages"
            text: qsTrId("pinned-messages")
            currentValue: pinnedCount
            onClicked: Global.openPopup(pinnedMessagesPopupComponent)
            iconSource: Style.svg("pin")
        }

        Separator {
            id: separator2
            visible: pinnedMessagesBtn.visible
        }

        // Not Refactored Yet
//        Connections {
//            target: popup.store.chatsModelInst.channelView
//            onActiveChannelChanged: {
//                if (popup.channelType === GroupInfoPopup.ChannelType.ActiveChannel) {
//                    popup.channel = popup.store.chatsModelInst.channelView.activeChannel
//                    resetSelectedMembers()
//                }
//            }
//            onContextChannelChanged: {
//                if (popup.channelType === GroupInfoPopup.ChannelType.ContextChannel) {
//                    popup.channel = popup.store.chatsModelInst.channelView.contextChannel
//                    resetSelectedMembers()
//                }
//            }
//        }

        ListView {
            id: memberList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: popup.channel? popup.channel.members : []
            delegate: StatusListItem {
                id: contactRow

                property string nickname: appMain.getUserNickname(model.publicKey)

                title: !model.userName.endsWith(".eth") && !!contactRow.nickname ?
                           contactRow.nickname : Utils.removeStatusEns(model.userName)
                //% "(You)"
                titleAsideText: model.publicKey === userProfile.pubKey ? qsTrId("-you-") : ""
                //% "Admin"
                statusListItemTitle.font.pixelSize: 17
                statusListItemTitleAside.font.pixelSize: 17
                label: model.isAdmin ? qsTrId("group-chat-admin"): ""
                image.source: appMain.getProfileImage(model.publicKey) || model.identicon
                image.isIdenticon: model.identicon
                components: [
                    StatusFlatRoundButton {
                        id: moreActionsBtn
                        type: StatusFlatRoundButton.Type.Tertiary
                        color: "transparent"
                        icon.name: "more"
                        icon.color: Theme.palette.baseColor1
                        visible: !model.isAdmin && popup.isAdmin
                        onClicked: {
                            contextMenu.popup(-contextMenu.width / 2 + moreActionsBtn.width / 2, moreActionsBtn.height + 10)
                        }
                        StatusPopupMenu {
                            id: contextMenu
                            StatusMenuItem {
                                icon.name: "admin"
                                icon.width: 16
                                icon.height: 16
                                //% "Make Admin"
                                text: qsTrId("make-admin")
                                // Not Refactored Yet
//                                onTriggered: popup.store.chatsModelInst.groups.makeAdmin(popup.channel.id,  model.publicKey)
                            }
                            StatusMenuItem {
                                icon.name: "remove-contact"
                                icon.width: 16
                                icon.height: 16
                                type: StatusMenuItem.Type.Danger
                                //% "Remove From Group"
                                text: qsTrId("remove-from-group")
                                // Not Refactored Yet
//                                onTriggered: popup.store.chatsModelInst.groups.kickMember(popup.channel.id,  model.publicKey)
                            }
                        }
                    }
                ]
                onTitleClicked:  {
                    const userProfileImage = appMain.getProfileImage(model.publicKey)
                    openProfilePopup(model.userName, model.publicKey, userProfileImage || model.identicon, '', contactRow.nickname, popup)
                }
            }
        }
    }

    leftButtons: [
        StatusRoundButton {
            visible: popup.addMembers
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            icon.rotation: 180
            onClicked: {
                popup.addMembers = false;
                popup.resetSelectedMembers();
            }
        }
    ]

    rightButtons: [
        StatusButton {
            visible: !popup.addMembers
            //% "Add members"
            text: qsTrId("add-members")
            onClicked: {
                popup.addMembers = true;
            }
        },
        StatusButton {
            id: btnSelectMembers
            visible: popup.addMembers
            enabled: popup.memberCount >= popup.currMemberCount
            //% "Add selected"
            text: qsTrId("add-selected")
            onClicked: popup.doAddMembers()
        }
    ]

    RenameGroupPopup {
        id: renameGroupPopup
        // Not Refactored Yet
//        activeChannelName: popup.store.chatsModelInst.channelView.activeChannel.name
//        onDoRename: {
//            popup.store.chatsModelInst.groups.rename(groupName)
//            popup.header.title = groupName
//            close()
//        }
    }
}
