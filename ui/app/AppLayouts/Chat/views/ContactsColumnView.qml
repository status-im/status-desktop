import QtQuick 2.13
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13


import utils 1.0
import shared 1.0
import shared.popups 1.0

import "../panels"
import "../popups"
import "../popups/community"

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

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
        }
        spacing: Style.current.padding

        // Chat headline row
        RowLayout {
            Layout.fillWidth: true

            StatusNavigationPanelHeadline {
                Layout.alignment: Qt.AlignVCenter
                text: qsTr("Chat")
            }

            Item {
                Layout.fillWidth: true
            }

            StatusRoundButton {
                Layout.alignment: Qt.AlignVCenter
                icon.name: "public-chat"
                icon.color: Theme.palette.directColor1
                icon.height: editBtn.icon.height
                icon.width: editBtn.icon.width
                implicitWidth: editBtn.implicitWidth
                implicitHeight: editBtn.implicitHeight
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
                id: editBtn
                Layout.alignment: Qt.AlignVCenter
                icon.name: "edit"
                icon.color: Theme.palette.directColor1
                checked: root.store.openCreateChat
                highlighted: checked
                onClicked: {
                    root.store.openCreateChat = !root.store.openCreateChat
                    if (root.store.openCreateChat) {
                        Global.openCreateChatView()
                    } else {
                        Global.closeCreateChatView()
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
        StatusBaseInput {
            id: searchInput
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            placeholderText: qsTr("Search")
            icon.name: "search"
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

        // contact requests
        StatusContactRequestsIndicatorListItem {
            id: contactRequests
            Layout.fillWidth: true
            Layout.preferredHeight: visible ? implicitHeight : 0

            readonly property int nbRequests: root.store.contactRequestsModel.count

            visible: nbRequests > 0
            title: qsTr("Contact requests")
            requestsCount: nbRequests

            sensor.onClicked: Global.openPopup(contactRequestsPopup)
        }

        // chat list
        ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: channelList.childrenRect.height

            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            clip: true

            StatusChatList {
                id: channelList
                width: parent.width
                model: root.chatSectionModule.model
                highlightItem: !root.store.openCreateChat
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
                    onDisplayGroupInfoPopup: {
                        chatSectionModule.prepareChatContentModuleForChatId(chatId)
                        let chatContentModule = chatSectionModule.getChatContentModule()
                        Global.openPopup(root.store.groupInfoPopupComponent, {
                                             chatContentModule: chatContentModule,
                                             chatDetails: chatContentModule.chatDetails
                                         })
                    }
                    onRenameGroupChat: {
                        chatSectionModule.renameGroupChat(
                                    chatId,
                                    groupName
                                    )
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
        id: privateChatPopupComponent
        PrivateChatPopup {
            store: root.store
            contactsStore: root.contactsStore
            onJoinPrivateChat: {
                chatSectionModule.createOneToOneChat("", publicKey, ensName)
            }
            onClosed: {
                destroy()
            }
            onProfileClicked: {
                root.openProfileClicked();
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

    Component {
        id: contactRequestsPopup
        ContactRequestsPopup {
            store: root.store
            onClosed: {
                destroy()
            }
        }
    }

    Connections {
        target: root.store.communitiesModuleInst
        function onImportingCommunityStateChanged(state, errorMsg) {
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

    Connections {
        target: root.store.mainModuleInst

        function onOpenContactRequestsPopup() {
            Global.openPopup(contactRequestsPopup)
        }
    }
}
