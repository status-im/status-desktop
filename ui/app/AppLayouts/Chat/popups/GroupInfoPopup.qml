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
    property int currMemberCount: chatContentModule.usersModule.model.count
    property int memberCount: 1

    property int channelType: GroupInfoPopup.ChannelType.ActiveChannel
    property var chatDetails
    property bool isAdmin: popup.chatSectionModule.activeItem.amIChatAdmin
    property Component pinnedMessagesPopupComponent

    property var chatContentModule

    readonly property int maxMembers: 20

    function resetSelectedMembers() {
        contactList.selectedPubKeys = []

        memberCount = popup.chatContentModule.usersModule.model.count
    }

    function doAddMembers() {
        if (popup.chatDetails.id && contactList.selectedPubKeys.length > 0) {
            popup.chatSectionModule.addGroupMembers(popup.chatDetails.id, JSON.stringify(contactList.selectedPubKeys));
        }
        popup.close();
    }

    height: 504
    anchors.centerIn: parent

    //% "Add members"
    header.title: addMembers ? qsTrId("add-members") : (popup.chatDetails ? popup.chatDetails.name : "")
    header.subTitle:  {
        if (addMembers) {
            return qsTr("%1/%2 members").arg(memberCount).arg(maxMembers)
        } else {
            //% "%1 members"
            if (currMemberCount > 1) {
                return qsTrId("%1-members").arg(currMemberCount);
            }
            //% "1 member"
            return qsTrId("1-member");
        }
    }
    header.editable: !addMembers && popup.isAdmin
    header.icon.isLetterIdenticon: true
    header.icon.name: popup.chatDetails ? popup.chatDetails.name : ""
    header.icon.background.color: popup.chatDetails ? popup.chatDetails.color : "transparent"

    onEditButtonClicked: renameGroupPopup.open()

    onClosed: {
        chatSectionModule.clearMyContacts()
        popup.destroy();
    }

    onOpened: {
        chatSectionModule.populateMyContacts(popup.chatContentModule.usersModule.getMembersPublicKeys())

        addMembers = false;

        btnSelectMembers.enabled = false;
        resetSelectedMembers();
    }

    ColumnLayout {
        id: addMembersItem

        anchors.top: parent.top
        anchors.topMargin: Style.current.halfPadding
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width - 2 * Style.current.padding
        height: parent.height

        visible: addMembers

        spacing: Style.current.padding

        StatusBaseInput {
            id: searchBox
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop

            implicitHeight: 36
            //% "Search"
            placeholderText: qsTrId("search")
            placeholderFont.pixelSize: 15

            icon.name: "search"
            icon.width: 17
            icon.height: 17
        }

        NoFriendsRectangle {
            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.bottomMargin: childrenRect.height

            visible: popup.store.contactsStore.myContactsModel.count === 0
        }

        NoFriendsRectangle {
            Layout.preferredHeight: childrenRect.height
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            Layout.bottomMargin: childrenRect.height

            visible: chatSectionModule.listOfMyContacts.count === 0
            //% "All your contacts are already in the group"
            text: qsTrId("group-chat-all-contacts-invited")
            textColor: Style.current.textColor
        }

        ContactListPanel {
            id: contactList

            Layout.fillHeight: true
            Layout.fillWidth: true

            visible: popup.addMembers && chatSectionModule.listOfMyContacts.count > 0
            model: chatSectionModule.listOfMyContacts
            selectMode: memberCount < maxMembers
            searchString: searchBox.text.toLowerCase()
            onSelectedPubKeysChanged: {
                memberCount = popup.chatContentModule.usersModule.model.count + selectedPubKeys.length;
                btnSelectMembers.enabled = selectedPubKeys.length > 0
            }
        }
    }

    ColumnLayout {
        id: groupInfoItem

        anchors.top: parent.top
        anchors.topMargin: Style.current.padding
        anchors.horizontalCenter: parent.horizontalCenter

        width: parent.width - 2*Style.current.padding
        height: parent.height - 2*Style.current.padding

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
                statusListItemTitle.font.pixelSize: 17
                statusListItemTitleAside.font.pixelSize: 17
                label: model.isAdmin ? qsTrId("group-chat-admin"): ""
                image.source: model.icon
                ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.id)
                icon: StatusIconSettings {
                    color: Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(model.id)]
                    charactersLen: 2
                    isLetterIdenticon: model.icon === ""
                    height: isLetterIdenticon ? 40 : 20
                    width: isLetterIdenticon ? 40 : 20
                }

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
                                onTriggered: popup.chatSectionModule.makeAdmin("", popup.chatDetails.id,  model.id)
                            }
                            StatusMenuItem {
                                icon.name: "remove-contact"
                                icon.width: 16
                                icon.height: 16
                                type: StatusMenuItem.Type.Danger
                                //% "Remove From Group"
                                text: qsTrId("remove-from-group")
                                onTriggered: popup.chatSectionModule.removeMemberFromGroupChat("", popup.chatDetails.id,  model.id)
                            }
                        }
                    }
                ]
                onTitleClicked: {
                    Global.openProfilePopup(model.id, popup)
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
            visible: !popup.addMembers && popup.isAdmin
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
        activeChannelName: popup.chatDetails ? popup.chatDetails.name : ""
        onDoRename: {
            popup.chatSectionModule.renameGroupChat(popup.chatSectionModule.activeItem.id, groupName)
            popup.header.title = groupName
            close()
        }
    }
}
