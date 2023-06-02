import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import utils 1.0
import shared 1.0
import shared.controls 1.0
import shared.popups 1.0

import SortFilterProxyModel 0.2

import "../panels"
import "../popups"
import "../popups/community"

Item {
    id: root
    width: Constants.chatSectionLeftColumnWidth
    height: parent.height

    // Important:
    // We're here in case of ChatSection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own chatSectionModule)
    property var chatSectionModule

    property var store
    property var contactsStore
    property var emojiPopup

    signal openProfileClicked()
    signal openAppSearch()
    signal addRemoveGroupMemberClicked()

    // main layout
    ColumnLayout {
        anchors {
            fill: parent
            topMargin: Style.current.smallPadding
        }
        spacing: Style.current.halfPadding

        // Chat headline row
        RowLayout {
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding

            StatusNavigationPanelHeadline {
                objectName: "ContactsColumnView_MessagesHeadline"
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Messages")
            }

            Item {
                Layout.fillWidth: true
            }

            StatusIconTabButton {
                id: startChatButton
                Layout.alignment: Qt.AlignVCenter
                objectName: "startChatButton"
                icon.name: "edit"
                icon.color: Theme.palette.directColor1
                checked: root.store.openCreateChat
                highlighted: checked
                onClicked: {
                    if (root.store.openCreateChat) {
                        Global.closeCreateChatView()
                    } else {
                        Global.openCreateChatView()
                    }
                }

                StatusToolTip {
                    text: qsTr("Start chat")
                    visible: parent.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                }
            }
        }

        // search field
        SearchBox {
            id: searchInput
            Layout.fillWidth: true
            Layout.leftMargin: Style.current.padding
            Layout.rightMargin: Style.current.padding
            Layout.preferredHeight: 36
            maximumHeight: 36
            leftPadding: 10
            topPadding: 4
            bottomPadding: 4
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: root.openAppSearch()
            }
        }

        ChatsLoadingPanel {
            Layout.fillWidth: true
            chatSectionModule: root.chatSectionModule
        }

        // chat list
        StatusScrollView {
            id: scrollView
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentWidth: availableWidth

            StatusChatList {
                id: channelList
                objectName: "ContactsColumnView_chatList"
                width: scrollView.availableWidth
                model: SortFilterProxyModel {
                    sourceModel: root.chatSectionModule.model
                    sorters: RoleSorter {
                        roleName: "lastMessageTimestamp"
                        sortOrder: Qt.DescendingOrder
                    }
                }

                highlightItem: !root.store.openCreateChat
                isEnsVerified: function(pubKey) { return Utils.isEnsVerified(pubKey) }
                onChatItemSelected: {
                    Global.closeCreateChatView()
                    root.chatSectionModule.setActiveItem(id, "")
                }
                onChatItemUnmuted: root.chatSectionModule.unmuteChat(id)

                popupMenu: ChatContextMenuView {
                    id: chatContextMenuView
                    emojiPopup: root.emojiPopup

                    openHandler: function (id) {
                        let jsonObj = root.chatSectionModule.getItemAsJson(id)
                        let obj = JSON.parse(jsonObj)
                        if (obj.error) {
                            console.error("error parsing chat item json object, id: ", id, " error: ", obj.error)
                            close()
                            return
                        }

                        currentFleet = root.chatSectionModule.getCurrentFleet()
                        isCommunityChat = root.chatSectionModule.isCommunity()
                        amIChatAdmin = obj.memberRole === Constants.memberRole.owner || obj.memberRole === Constants.memberRole.admin
                        chatId = obj.itemId
                        chatName = obj.name
                        chatDescription = obj.description
                        chatEmoji = obj.emoji
                        chatColor = obj.color
                        chatIcon = obj.icon
                        chatType = obj.type
                        chatMuted = obj.muted
                    }

                    onMuteChat: {
                        root.chatSectionModule.muteChat(chatId, interval)
                    }

                    onUnmuteChat: {
                        root.chatSectionModule.unmuteChat(chatId)
                    }

                    onMarkAllMessagesRead: {
                        root.chatSectionModule.markAllMessagesRead(chatId)
                    }

                    onClearChatHistory: {
                        root.chatSectionModule.clearChatHistory(chatId)
                    }

                    onRequestAllHistoricMessages: {
                        // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                    }

                    onLeaveChat: {
                        root.chatSectionModule.leaveChat(chatId)
                    }

                    onDeleteCommunityChat: {
                        // Not Refactored Yet
                    }

                    onDownloadMessages: {
                        root.chatSectionModule.downloadMessages(chatId, file)
                    }
                    onDisplayProfilePopup: {
                        Global.openProfilePopup(publicKey)
                    }
                    onLeaveGroup: {
                        chatSectionModule.leaveChat("", chatId, true);
                    }
                    onUpdateGroupChatDetails: {
                        chatSectionModule.updateGroupChatDetails(
                                    chatId,
                                    groupName,
                                    groupColor,
                                    groupImage
                                    )
                    }
                    onAddRemoveGroupMember: {
                        root.addRemoveGroupMemberClicked()
                    }
                }
            }
        }
    }

    Connections {
        target: root.store

        function onImportingCommunityStateChanged(communityId, state, errorMsg) {

            const community = root.store.getCommunityDetailsAsJson(communityId)
            let title = ""
            let subTitle = ""
            let loading = false

            switch (state)
            {
            case Constants.communityImported:
                title = qsTr("'%1' community imported").arg(community.name);
                break
            case Constants.communityImportingInProgress:
                title = qsTr("Importing community is in progress")
                loading = true
                break
            case Constants.communityImportingError:
                title = qsTr("Failed to import community '%1'").arg(community.name)
                subTitle = errorMsg
                break
            default:
                console.error("unknown state while importing community: %1").arg(state)
                return
            }

            Global.displayToastMessage(title,
                                       subTitle,
                                       "",
                                       loading,
                                       Constants.ephemeralNotificationType.normal,
                                       "")
        }

        function onCommunityInfoAlreadyRequested() {
            Global.displayToastMessage(qsTr("Community data not loaded yet."),
                                       qsTr("Please wait for the unfurl to show"),
                                       "",
                                       true,
                                       Constants.ephemeralNotificationType.normal,
                                       "")
        }
    }
}
