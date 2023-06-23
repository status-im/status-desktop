import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Core.Utils 0.1 as SQUtils

import utils 1.0

import shared.views.chat 1.0

import "../panels"
import "../stores"

Item {
    id: root

    property alias menuButton: menuButton
    property alias membersButton: membersButton
    property alias searchButton: searchButton

    property var rootStore
    property var chatContentModule: root.rootStore.currentChatContentModule() || null
    property var emojiPopup
    property int padding: Style.current.halfPadding

    signal searchButtonClicked()

    function addRemoveGroupMember() {
        root.state = d.stateMembersSelectorContent
    }

    QtObject {
        id: d

        readonly property string stateInfoButtonContent: ""
        readonly property string stateMembersSelectorContent: "selectingMembers"

        readonly property bool selectingMembers: root.state == stateMembersSelectorContent
    }

    MessageStore {
        id: messageStore
        messageModule: chatContentModule ? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    Loader {
        id: loader

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: d.selectingMembers ? parent.right : actionButtons.left

        sourceComponent: d.selectingMembers ? membersSelector : statusChatInfoButton
    }

    RowLayout {
        id: actionButtons

        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.right: parent.right

        spacing: 8
        visible: !d.selectingMembers

        StatusFlatRoundButton {
            id: searchButton
            icon.name: "search"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: root.searchButtonClicked()

            // initializing the tooltip
            tooltip.text: qsTr("Search")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
        }

        StatusFlatRoundButton {
            id: membersButton
            visible: {
                if(!chatContentModule)
                    return false

                return localAccountSensitiveSettings.showOnlineUsers &&
                        chatContentModule.chatDetails.isUsersListAvailable
            }
            highlighted: localAccountSensitiveSettings.expandUsersList
            icon.name: "group-chat"
            type: StatusFlatRoundButton.Type.Secondary
            onClicked: {
                localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList;
            }
            // initializing the tooltip
            tooltip.text: qsTr("Members")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12
        }

        StatusFlatRoundButton {
            id: menuButton
            objectName: "chatToolbarMoreOptionsButton"
            icon.name: "more"
            type: StatusFlatRoundButton.Type.Secondary

            // initializing the tooltip
            tooltip.visible: !!tooltip.text && menuButton.hovered && !contextMenu.opened
            tooltip.text: qsTr("More")
            tooltip.orientation: StatusToolTip.Orientation.Bottom
            tooltip.y: parent.height + 12

            property bool showMoreMenu: false
            onClicked: {
                menuButton.highlighted = true

                let originalOpenHandler = contextMenu.openHandler
                let originalCloseHandler = contextMenu.closeHandler

                contextMenu.openHandler = function () {
                    if (!!originalOpenHandler) {
                        originalOpenHandler()
                    }
                }

                contextMenu.closeHandler = function () {
                    menuButton.highlighted = false
                    if (!!originalCloseHandler) {
                        originalCloseHandler()
                    }
                }

                contextMenu.openHandler = originalOpenHandler
                contextMenu.popup(-contextMenu.width + menuButton.width, menuButton.height + 4)
            }

            ChatContextMenuView {
                id: contextMenu
                objectName: "moreOptionsContextMenu"
                emojiPopup: root.emojiPopup
                openHandler: function () {
                    if(!chatContentModule) {
                        console.debug("error on open chat context menu handler - chat content module is not set")
                        return
                    }
                    currentFleet = chatContentModule.getCurrentFleet()
                    isCommunityChat = chatContentModule.chatDetails.belongsToCommunity
                    amIChatAdmin = chatContentModule.amIChatAdmin()
                    chatId = chatContentModule.chatDetails.id
                    chatName = chatContentModule.chatDetails.name
                    chatDescription = chatContentModule.chatDetails.description
                    chatEmoji = chatContentModule.chatDetails.emoji
                    chatColor = chatContentModule.chatDetails.color
                    chatIcon = chatContentModule.chatDetails.icon
                    chatType = chatContentModule.chatDetails.type
                    chatMuted = chatContentModule.chatDetails.muted
                    channelPosition = chatContentModule.chatDetails.position
                }

                onMuteChat: {
                    if(!chatContentModule) {
                        console.debug("error on mute chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.muteChat(interval)
                }

                onUnmuteChat: {
                    if(!chatContentModule) {
                        console.debug("error on unmute chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.unmuteChat()
                }

                onMarkAllMessagesRead: {
                    if(!chatContentModule) {
                        console.debug("error on mark all messages read from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.markAllMessagesRead()
                }

                onClearChatHistory: {
                    if(!chatContentModule) {
                        console.debug("error on clear chat history from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.clearChatHistory()
                }

                onRequestAllHistoricMessages: {
                    // Not Refactored Yet - Check in the `master` branch if this is applicable here.
                }

                onLeaveChat: {
                    if(!chatContentModule) {
                        console.debug("error on leave chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.leaveChat()
                }

                onDeleteCommunityChat: root.rootStore.removeCommunityChat(chatId)

                onDownloadMessages: {
                    if(!chatContentModule) {
                        console.debug("error on leave chat from context menu - chat content module is not set")
                        return
                    }
                    chatContentModule.downloadMessages(file)
                }

                onDisplayProfilePopup: {
                    Global.openProfilePopup(publicKey)
                }

                onEditCommunityChannel: {
                    root.rootStore.editCommunityChannel(
                                chatId,
                                newName,
                                newDescription,
                                newEmoji,
                                newColor,
                                newCategory,
                                channelPosition // TODO change this to the signal once it is modifiable
                                )
                }
                onAddRemoveGroupMember: {
                    root.addRemoveGroupMember()
                }
                onFetchMoreMessages: {
                    messageStore.requestMoreMessages();
                }
                onLeaveGroup: {
                    chatContentModule.leaveChat();
                }
                onUpdateGroupChatDetails: {
                    root.rootStore.chatCommunitySectionModule.updateGroupChatDetails(
                                chatId,
                                groupName,
                                groupColor,
                                groupImage
                                )
                }
            }
        }

        Rectangle {
            implicitWidth: 1
            implicitHeight: 24
            color: Theme.palette.directColor7
            Layout.alignment: Qt.AlignVCenter
            visible: (menuButton.visible || membersButton.visible || searchButton.visible)
        }
    }

    // Chat toolbar content option 1:
    Component {
        id: statusChatInfoButton

        StatusChatInfoButton {
            readonly property string emojiIcon: chatContentModule? chatContentModule.chatDetails.emoji : "" // Needed for test

            objectName: "chatInfoBtnInHeader"
            title: chatContentModule? chatContentModule.chatDetails.name : ""

            subTitle: {
                if(!chatContentModule)
                    return ""

                // In some moment in future this should be part of the backend logic.
                // (once we add translation on the backend side)
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.privateGroupChat:
                    return qsTr("%n member(s)", "", chatContentModule.usersModule.model.count)
                case Constants.chatType.communityChat:
                    return SQUtils.Utils.linkifyAndXSS(chatContentModule.chatDetails.description).trim()
                default:
                    return ""
                }
            }
            asset.name: chatContentModule? chatContentModule.chatDetails.icon : ""
            asset.isImage: chatContentModule && chatContentModule.chatDetails.icon !== ""
            asset.isLetterIdenticon: chatContentModule && chatContentModule.chatDetails.icon === ""
            ringSettings.ringSpecModel: chatContentModule && chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                            Utils.getColorHashAsJson(chatContentModule.chatDetails.id) : ""
            asset.color: chatContentModule?
                            chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                Utils.colorForPubkey(chatContentModule.chatDetails.id)
                              : chatContentModule.chatDetails.color
            : ""
            asset.emoji: emojiIcon
            asset.emojiSize: "24x24"
            type: chatContentModule ? chatContentModule.chatDetails.type : Constants.chatType.unknown
            pinnedMessagesCount: chatContentModule? chatContentModule.pinnedMessagesModel.count : 0
            muted: chatContentModule? chatContentModule.chatDetails.muted : false

            onPinnedMessagesCountClicked: {
                if(!chatContentModule) {
                    console.warn("error on open pinned messages - chat content module is not set")
                    return
                }
                const chatId = type === Constants.chatType.oneToOne ? chatContentModule.getMyChatId() : ""
                Global.openPinnedMessagesPopupRequested(rootStore, messageStore, chatContentModule.pinnedMessagesModel, "", chatId)
            }
            onUnmute: {
                if(!chatContentModule) {
                    console.debug("error on unmute chat - chat content module is not set")
                    return
                }
                chatContentModule.unmuteChat()
            }

            hoverEnabled: {
                if(!chatContentModule)
                    return false

                return chatContentModule.chatDetails.type !== Constants.chatType.communityChat &&
                        chatContentModule.chatDetails.type !== Constants.chatType.privateGroupChat
            }
            onClicked: {
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.oneToOne:
                    Global.openProfilePopup(chatContentModule.chatDetails.id)
                    break;
                }
            }
            onLinkActivated: Global.openLink(link)
        }
    }

    // Chat toolbar content option 2:
    Component {
        id: membersSelector

        MembersEditSelectorView {
            rootStore: root.rootStore
            usersStore: UsersStore {
                usersModule: root.chatContentModule.usersModule
            }

            onConfirmed: root.state = d.stateInfoButtonContent
            onRejected: root.state = d.stateInfoButtonContent
        }
    }
}
