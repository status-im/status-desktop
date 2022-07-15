import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import utils 1.0
import shared 1.0
import shared.popups 1.0
import shared.status 1.0
import shared.controls 1.0
import shared.views.chat 1.0

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"
import "../stores"

ColumnLayout {
    id: root
    spacing: 0

    // Important:
    // Each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var chatSectionModule
    property var rootStore
    property var contactsStore
    property bool isActiveChannel: false
    property bool isConnected: false
    property var emojiPopup
    property bool activityCenterVisible: false
    property int activityCenterNotificationsCount
    property alias textInputField: chatInput
    property UsersStore usersStore: UsersStore {}
    property Component pinnedMessagesPopupComponent

    onChatContentModuleChanged: {
        root.usersStore.usersModule = root.chatContentModule.usersModule
    }

    signal openAppSearch()
    signal notificationButtonClicked()
    signal openStickerPackPopup(string stickerPackId)

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool isBlocked: false

    property bool stickersLoaded: false

    // NOTE: Used this property change as it is the current way used for displaying new channel/chat data of content view.
    // If in the future content is loaded dynamically, input focus should be activated when loaded / created content view.
    onHeightChanged: {
        if(root.height > 0) {
            chatInput.forceInputActiveFocus()
        }
    }  

    Keys.onEscapePressed: { topBar.toolbarComponent = statusChatInfoButton }

    // Chat toolbar content option 1:
    Component {
        id: statusChatInfoButton

        StatusChatInfoButton {
            width: Math.min(implicitWidth, parent.width)
            title: chatContentModule? chatContentModule.chatDetails.name : ""
            subTitle: {
                if(!chatContentModule)
                    return ""

                // In some moment in future this should be part of the backend logic.
                // (once we add transaltion on the backend side)
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.oneToOne:
                    return (chatContentModule.isMyContact(chatContentModule.chatDetails.id) ?
                                qsTr("Contact") :
                                qsTr("Not a contact"))
                case Constants.chatType.publicChat:
                    return qsTr("Public chat")
                case Constants.chatType.privateGroupChat:
                    let cnt = root.usersStore.usersModule.model.count
                    if(cnt > 1) return qsTr("%1 members").arg(cnt);
                    return qsTr("1 member");
                case Constants.chatType.communityChat:
                    return Utils.linkifyAndXSS(chatContentModule.chatDetails.description).trim()
                default:
                    return ""
                }
            }
            image.source: chatContentModule? chatContentModule.chatDetails.icon : ""
            ringSettings.ringSpecModel: chatContentModule && chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                                           Utils.getColorHashAsJson(chatContentModule.chatDetails.id) : ""
            icon.color: chatContentModule?
                                            chatContentModule.chatDetails.type === Constants.chatType.oneToOne ?
                                                Utils.colorForPubkey(chatContentModule.chatDetails.id)
                                                : chatContentModule.chatDetails.color
                                            : ""
            icon.emoji: chatContentModule? chatContentModule.chatDetails.emoji : ""
            icon.emojiSize: "24x24"
            type: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown
            pinnedMessagesCount: chatContentModule? chatContentModule.pinnedMessagesModel.count : 0
            muted: chatContentModule? chatContentModule.chatDetails.muted : false

            onPinnedMessagesCountClicked: {
                if(!chatContentModule) {
                    console.debug("error on open pinned messages - chat content module is not set")
                    return
                }
                Global.openPopup(pinnedMessagesPopupComponent, {
                                     store: rootStore,
                                     messageStore: messageStore,
                                     pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                     messageToPin: ""
                                 })
            }
            onUnmute: {
                if(!chatContentModule) {
                    console.debug("error on unmute chat - chat content module is not set")
                    return
                }
                chatContentModule.unmuteChat()
            }

            sensor.enabled: {
                if(!chatContentModule)
                    return false

                return chatContentModule.chatDetails.type !== Constants.chatType.publicChat &&
                        chatContentModule.chatDetails.type !== Constants.chatType.communityChat
            }
            onClicked: {
                switch (chatContentModule.chatDetails.type) {
                case Constants.chatType.privateGroupChat:
                    Global.openPopup(root.rootStore.groupInfoPopupComponent, {
                                         chatContentModule: chatContentModule,
                                         chatDetails: chatContentModule.chatDetails
                                     })
                    break;
                case Constants.chatType.oneToOne:
                    Global.openProfilePopup(chatContentModule.chatDetails.id)
                    break;
                }
            }
        }
    }

    // Chat toolbar content option 2:
    Component {
        id: contactsSelector
        GroupChatPanel {
            sectionModule: root.chatSectionModule
            chatContentModule: root.chatContentModule
            rootStore: root.rootStore
            maxHeight: root.height
            onPanelClosed: topBar.toolbarComponent = statusChatInfoButton
        }
    }

    StatusChatToolBar {
        id: topBar
        z: parent.z + 1
        Layout.fillWidth: true
        toolbarComponent: statusChatInfoButton

        membersButton.visible: {
            if(!chatContentModule || chatContentModule.chatDetails.type === Constants.chatType.publicChat)
                return false

            return localAccountSensitiveSettings.showOnlineUsers &&
                    chatContentModule.chatDetails.isUsersListAvailable
        }
        membersButton.highlighted: localAccountSensitiveSettings.expandUsersList
        notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList && membersButton.visible ? 0 : 14

        notificationCount: root.activityCenterNotificationsCount

        onSearchButtonClicked: root.openAppSearch()

        onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
        notificationButton.highlighted: root.activityCenterVisible
        onNotificationButtonClicked: root.notificationButtonClicked()

        popupMenu: ChatContextMenuView {
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
                chatType = chatContentModule.chatDetails.type
                chatMuted = chatContentModule.chatDetails.muted
                channelPosition = chatContentModule.chatDetails.position
            }

            onMuteChat: {
                if(!chatContentModule) {
                    console.debug("error on mute chat from context menu - chat content module is not set")
                    return
                }
                chatContentModule.muteChat()
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

            onDisplayGroupInfoPopup: {
                Global.openPopup(root.rootStore.groupInfoPopupComponent, {
                                     chatContentModule: chatContentModule,
                                     chatDetails: chatContentModule.chatDetails
                                 })
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
                topBar.toolbarComponent = contactsSelector
            }
            onFetchMoreMessages: {
                root.rootStore.messageStore.requestMoreMessages();
            }
            onLeaveGroup: {
                chatContentModule.leaveChat();
            }
            onRenameGroupChat: {
                root.rootStore.chatCommunitySectionModule.renameGroupChat(
                    chatId,
                    groupName
                )
            }
        }
    }

    Rectangle {
        id: connectedStatusRect
        Layout.fillWidth: true
        height: 40
        Layout.alignment: Qt.AlignHCenter
        z: 60
        visible: false
        color: isConnected ? Style.current.green : Style.current.darkGrey
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            color: Style.current.white
            id: connectedStatusLbl
            text: isConnected ?
                      qsTr("Connected") :
                      qsTr("Disconnected")
        }

        Connections {
            target: mainModule
            onOnlineStatusChanged: {
                if (connected === isConnected) return;
                isConnected = connected;
                if(isConnected) {
                    onlineStatusTimer.start();
                } else {
                    connectedStatusRect.visible = true;
                }
            }
        }
        Component.onCompleted: {
            isConnected = mainModule.isOnline
            if(!isConnected){
                connectedStatusRect.visible = true
            }
        }
    }

    Timer {
        id: onlineStatusTimer
        interval: 5000
        onTriggered: {
            connectedStatusRect.visible = false;
        }
    }

    StatusBanner {
        Layout.fillWidth: true
        visible: root.isBlocked
        type: StatusBanner.Type.Danger
        statusText: qsTr("Blocked")
    }

    MessageStore {
        id: messageStore
        messageModule: chatContentModule? chatContentModule.messagesModule : null
        chatSectionModule: root.rootStore.chatCommunitySectionModule
    }

    MessageContextMenuView {
        id: contextmenu
        store: root.rootStore
        reactionModel: root.rootStore.emojiReactionsModel
        onPinMessage: {
            messageStore.pinMessage(messageId)
        }

        onUnpinMessage: {
            messageStore.unpinMessage(messageId)
        }

        onPinnedMessagesLimitReached: {
            if(!chatContentModule) {
                console.debug("error on open pinned messages limit reached from message context menu - chat content module is not set")
                return
            }
            Global.openPopup(Global.pinnedMessagesPopup, {
                                 store: rootStore,
                                 messageStore: messageStore,
                                 pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                 messageToPin: messageId
                             })
        }

        onToggleReaction: {
            messageStore.toggleReaction(messageId, emojiId)
        }

        onOpenProfileClicked: {
            Global.openProfilePopup(publicKey, null, state)
        }

        onDeleteMessage: {
            messageStore.deleteMessage(messageId)
        }

        onEditClicked: messageStore.setEditModeOn(messageId)

        onCreateOneToOneChat: {
            Global.changeAppSectionBySectionType(Constants.appSection.chat)
            root.rootStore.chatCommunitySectionModule.createOneToOneChat("", chatId, ensName)
        }
        onShowReplyArea: {
            let obj = messageStore.getMessageByIdAsJson(messageId)
            if (!obj) {
                return
            }
            chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.senderIcon, obj.contentType, obj.messageImage, obj.sticker)
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        Layout.fillHeight: true
        clip: true

        ChatMessagesView {
            id: chatMessages
            Layout.fillWidth: true
            Layout.fillHeight: true
            store: root.rootStore
            contactsStore: root.contactsStore
            messageContextMenuInst: contextmenu
            messageStore: messageStore
            emojiPopup: root.emojiPopup
            usersStore: root.usersStore
            stickersLoaded: root.stickersLoaded
            isChatBlocked: root.isBlocked
            channelEmoji: chatContentModule.chatDetails.emoji || ""
            isActiveChannel: root.isActiveChannel
            onShowReplyArea: {
                let obj = messageStore.getMessageByIdAsJson(messageId)
                if (!obj) {
                    return
                }
                chatInput.showReplyArea(messageId, obj.senderDisplayName, obj.messageText, obj.senderIcon, obj.contentType, obj.messageImage, obj.sticker)
            }
            onOpenStickerPackPopup: {
                root.openStickerPackPopup(stickerPackId);
            }
        }

        Item {
            id: inputArea
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: chatInput.height
            Layout.preferredHeight: height

            Loader {
                id: loadingMessagesIndicator
                active: root.rootStore.loadingHistoryMessagesInProgress
                visible: root.rootStore.loadingHistoryMessagesInProgress
                sourceComponent: LoadingAnimation { }
                anchors {
                    right: parent.right
                    bottom: chatInput.top
                    rightMargin: Style.current.padding
                    bottomMargin: Style.current.padding
                }
            }

            StatusChatInput {
                id: chatInput
                store: root.rootStore
                usersStore: root.usersStore

                messageContextMenu: contextmenu
                emojiPopup: root.emojiPopup
                isContactBlocked: root.isBlocked
                isActiveChannel: root.isActiveChannel
                anchors.bottom: parent.bottom
                recentStickers: root.rootStore.stickersModuleInst.recent
                stickerPackList: root.rootStore.stickersModuleInst.stickerPacks
                chatType: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown

                Binding on chatInputPlaceholder {
                    when: root.isBlocked
                    value: qsTr("This user has been blocked.")
                }

                onSendTransactionCommandButtonClicked: {
                    if(!chatContentModule) {
                        console.debug("error on sending transaction command - chat content module is not set")
                        return
                    }

                    if (Utils.getContactDetailsAsJson(chatContentModule.getMyChatId()).ensVerified) {
                        Global.openPopup(root.sendTransactionWithEnsModal)
                    } else {
                        Global.openPopup(root.sendTransactionNoEnsModal)
                    }
                }
                onReceiveTransactionCommandButtonClicked: {
                    Global.openPopup(root.receiveTransactionModal)
                }
                onStickerSelected: {
                    root.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                          hashId,
                                                          chatInput.isReply ? chatInput.replyMessageId : "",
                                                          packId)
                }


                onSendMessage: {
                    if (!chatContentModule) {
                        console.debug("error on sending message - chat content module is not set")
                        return
                    }

                    if(root.rootStore.sendMessage(event,
                                                             chatInput.textInput.text,
                                                             chatInput.isReply? chatInput.replyMessageId : "",
                                                             chatInput.fileUrls
                                                             ))
                    {
                        Global.sendMessageSound.stop();
                        Qt.callLater(Global.sendMessageSound.play);

                        chatInput.textInput.clear();
                        chatInput.textInput.textFormat = TextEdit.PlainText;
                        chatInput.textInput.textFormat = TextEdit.RichText;
                    }
                }

                onUnblockChat: {
                    chatContentModule.unblockChat()
                }
            }
        }
    }
}
