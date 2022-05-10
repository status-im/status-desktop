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
    property var messageStore
    property bool addMembers: false
    property int currMemberCount: chatContentModule.usersModule.model.count
    property int memberCount: 1

    property int channelType: GroupInfoPopup.ChannelType.ActiveChannel
    property var chatDetails
    property bool isAdmin: popup.chatSectionModule.activeItem.amIChatAdmin

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

    header.title: addMembers ? qsTr("Add members") : (popup.chatDetails ? popup.chatDetails.name : "")
    header.subTitle:  {
        if (addMembers) {
            return qsTr("%1/%2 members").arg(memberCount).arg(maxMembers)
        } else {
            if (currMemberCount > 1) {
                return qsTr("%1 members").arg(currMemberCount);
            }
            return qsTr("1 member");
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
            placeholderText: qsTr("Search")
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
            text: qsTr("All your contacts are already in the group")
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
            property int pinnedCount: popup.chatContentModule.pinnedMessagesModel.count

            id: pinnedMessagesBtn
            visible: pinnedCount > 0
            text: qsTr("Pinned messages")
            currentValue: pinnedCount
            onClicked: {
                popup.store.messageStore.messageModule = popup.chatContentModule.messagesModule
                popup.store.messageStore.chatSectionModule = popup.chatSectionModule

                Global.openPopup(Global.pinnedMessagesPopup, {
                    store: popup.store,
                    messageStore: popup.store.messageStore,
                    pinnedMessagesModel: popup.chatContentModule.pinnedMessagesModel,
                    messageToPin: ""
                })
            }
            iconSource: Style.svg("pin")
            anchors.left: undefined
            anchors.right: undefined
            width: parent.width
        }

        Separator {
            id: separator2
            visible: pinnedMessagesBtn.visible
        }

        ListView {
            id: memberList
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            model: popup.chatContentModule.usersModule.model
            delegate: StatusListItem {
                id: contactRow

                title: model.displayName
                statusListItemTitle.font.pixelSize: 17
                statusListItemTitleAside.font.pixelSize: 17
                label: model.isAdmin ? qsTr("Admin"): ""
                image.source: model.icon
                ringSettings.ringSpecModel: Utils.getColorHashAsJson(model.pubKey)
                icon: StatusIconSettings {
                    color: Theme.palette.userCustomizationColors[Utils.colorIdForPubkey(model.pubKey)]
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
                                text: qsTr("Make Admin")
                                onTriggered: popup.chatSectionModule.makeAdmin("", popup.chatDetails.id,  model.pubKey)
                            }
                            StatusMenuItem {
                                icon.name: "remove-contact"
                                icon.width: 16
                                icon.height: 16
                                type: StatusMenuItem.Type.Danger
                                text: qsTr("Remove From Group")
                                onTriggered: popup.chatSectionModule.removeMemberFromGroupChat("", popup.chatDetails.id,  model.pubKey)
                            }
                        }
                    }
                ]
                onTitleClicked: {
                    Global.openProfilePopup(model.pubKey, popup)
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
            text: qsTr("Add members")
            onClicked: {
                popup.addMembers = true;
            }
        },
        StatusButton {
            id: btnSelectMembers
            visible: popup.addMembers
            enabled: popup.memberCount >= popup.currMemberCount
            text: qsTr("Add selected")
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
