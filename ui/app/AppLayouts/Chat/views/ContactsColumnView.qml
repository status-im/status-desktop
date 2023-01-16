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
import shared.popups 1.0

import SortFilterProxyModel 0.2

import "../panels"
import "../popups"
import "../popups/community"

Item {
    id: root
    width: 304
    height: parent.height

    // Important:
    // We're here in case of ChatSection
    // This module is set from `ChatLayout` (each `ChatLayout` has its own chatSectionModule)
    property var chatSectionModule

    property var store
    property var contactsStore
    property var emojiPopup

    // Not Refactored Yet
    //property int chatGroupsListViewCount: channelList.model.count
    signal openProfileClicked()
    signal openAppSearch()
    signal importCommunityClicked()
    signal createCommunityClicked()

    // main layout
    ColumnLayout {
        anchors {
            fill: parent
            margins: Style.current.padding
            topMargin: Style.current.smallPadding
            bottomMargin: 0
        }
        spacing: Style.current.padding

        // Chat headline row
        RowLayout {
            Layout.fillWidth: true

            StatusNavigationPanelHeadline {
                objectName: "ContactsColumnView_MessagesHeadline"
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Messages")
            }

            Item {
                Layout.fillWidth: true
            }

            StatusRoundButton {
                Layout.alignment: Qt.AlignVCenter
                icon.name: "public-chat"
                icon.color: Theme.palette.directColor1
                icon.height: startChatButton.icon.height
                icon.width: startChatButton.icon.width
                implicitWidth: startChatButton.implicitWidth
                implicitHeight: startChatButton.implicitHeight
                type: StatusRoundButton.Type.Tertiary

                onClicked: Global.openPopup(publicChatPopupComponent)

                StatusToolTip {
                    text: qsTr("Join public chats")
                    visible: parent.hovered
                    orientation: StatusToolTip.Orientation.Bottom
                    y: parent.height + 12
                }
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
        StatusInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            maximumHeight: 36
            placeholderText: qsTr("Search")
            input.asset.name: "search"
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

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            clip: true

            // chat list
            StatusScrollView {
                id: scroll

                clip: false
                padding: 0
                anchors.fill: parent
                anchors.bottomMargin: Style.current.padding

                StatusChatList {
                    id: channelList
                    objectName: "ContactsColumnView_chatList"
                    width: scroll.availableWidth
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
                            amIChatAdmin = obj.amIChatAdmin
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
                            root.chatSectionModule.muteChat(chatId)
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
                    }
                }
            }
        }
    }

    Component {
        id: publicChatPopupComponent
        PublicChatPopup {
            onJoinPublicChat: {
                chatSectionModule.createPublicChat(name)
                close()
            }
            onSuggestedMessageClicked: {
                chatSectionModule.createPublicChat(channel)
                close()
            }
            onClosed: {
                destroy()
            }
        }
    }

    Component {
        id: communitiesPopupComponent
        CommunitiesPopup {
            anchors.centerIn: parent
            communitiesList: root.store.communitiesList
            onSetActiveCommunity: {
                root.store.setActiveCommunity(id)
            }
            onSetObservedCommunity: {
                root.store.setObservedCommunity(id)
            }
            onClosed: {
                destroy()
            }
            onOpenCommunityDetail: {
                Global.openPopup(communityDetailPopup);
            }
            onImportCommunityClicked: {
                root.importCommunityClicked();
            }
            onCreateCommunityClicked: {
                root.createCommunityClicked();
            }
        }
    }

    Component {
        id: communityDetailPopup
        CommunityDetailPopup {
            anchors.centerIn: parent
            store: root.store
            onClosed: {
                Global.openPopup(communitiesPopupComponent)
                destroy()
            }
        }
    }

    Connections {
        target: root.store
        function onImportingCommunityStateChanged(communityId, state, errorMsg) {
            let title = ""
            let loading = false

            if (state === Constants.communityImported)
            {
                title = qsTr("Community imported")
            }
            else if (state === Constants.communityImportingInProgress)
            {
                title = qsTr("Importing community is in progress")
                loading = true
            }
            else if (state === Constants.communityImportingError)
            {
                title = errorMsg
            }

            if(title == "")
            {
                console.error("unknown state while importing community: ", state)
                return
            }

            Global.displayToastMessage(title,
                                       "",
                                       "",
                                       loading,
                                       Constants.ephemeralNotificationType.normal,
                                       "")
        }
    }
}
