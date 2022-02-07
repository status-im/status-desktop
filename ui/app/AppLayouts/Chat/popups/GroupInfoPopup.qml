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
    property var chatSectionModule
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

    property var chatContentModule

    function resetSelectedMembers(){
        pubKeys = []

        memberCount = popup.chatContentModule.usersModule.model.rowCount()
        currMemberCount = memberCount
        popup.store.addToGroupContacts.clear()
    }

    function doAddMembers(){
        if(pubKeys.length === 0) return;
        if (popup.channel) {
            popup.chatSectionModule.addGroupMembers(popup.channel.id, JSON.stringify(pubKeys));
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
        chatSectionModule.clearMyContacts()
        popup.destroy();
    }

    onOpened: {
        popup.chatContentModule = popup.store.currentChatContentModule()

        chatSectionModule.populateMyContacts()

        addMembers = false;
        if (popup.channel) {
            popup.isAdmin = popup.chatSectionModule.activeItem.amIChatAdmin
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
            visible: popup.chatContentModule.usersModule.model.rowCount() > 0
            Layout.fillHeight: true
            Layout.fillWidth: true
            model: chatSectionModule.listOfMyContacts
            selectMode: memberCount < maxMembers
            searchString: searchBox.text.toLowerCase()
            checkedPubKeyList: pubKeys
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
                memberCount = popup.chatContentModule.usersModule.model.rowCount() + pubKeys.length;
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
            onClicked: Global.openPopup(pinnedMessagesPopupComponent, {store: popup.store})
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
            model: popup.chatContentModule.usersModule.model
            delegate: StatusListItem {
                id: contactRow

                title: model.name
                //% "Admin"
                statusListItemTitle.font.pixelSize: 17
                statusListItemTitleAside.font.pixelSize: 17
                label: model.isAdmin ? qsTrId("group-chat-admin"): ""
                image.source: model.icon
                image.isIdenticon: model.isIdenticon
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
                                onTriggered: popup.chatSectionModule.makeAdmin(popup.channel.id,  model.id)
                            }
                            StatusMenuItem {
                                icon.name: "remove-contact"
                                icon.width: 16
                                icon.height: 16
                                type: StatusMenuItem.Type.Danger
                                //% "Remove From Group"
                                text: qsTrId("remove-from-group")
                                onTriggered: popup.chatSectionModule.removeMemberFromGroupChat(popup.channel.id,  model.id)
                            }
                        }
                    }
                ]
                onTitleClicked:  {
                    Global.openProfilePopup(model.publicKey, popup)
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
        activeChannelName: popup.chatSectionModule.activeItem.name
        onDoRename: {
            popup.chatSectionModule.renameGroupChat(popup.chatSectionModule.activeItem.id, groupName)
            popup.header.title = groupName
            close()
        }
    }
}
