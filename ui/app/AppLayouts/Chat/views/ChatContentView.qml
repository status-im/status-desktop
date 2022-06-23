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
    id: chatContentRoot
    spacing: 0

    // Important:
    // Each chat/channel has its own ChatContentModule
    property var chatContentModule
    property var rootStore
    property var contactsStore
    property bool isActiveChannel: false
    property var emojiPopup
    property alias textInputField: chatInput
    property UsersStore usersStore: UsersStore {}

    onChatContentModuleChanged: {
        chatContentRoot.usersStore.usersModule = chatContentRoot.chatContentModule.usersModule
    }

    signal openStickerPackPopup(string stickerPackId)

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    property bool isBlocked: false

    property bool stickersLoaded: false

    // NOTE: Used this property change as it is the current way used for displaying new channel/chat data of content view.
    // If in the future content is loaded dynamically, input focus should be activated when loaded / created content view.
    onHeightChanged: {
        if(chatContentRoot.height > 0) {
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
                                //% "Contact"
                                qsTrId("chat-is-a-contact") :
                                //% "Not a contact"
                                qsTrId("chat-is-not-a-contact"))
                case Constants.chatType.publicChat:
                    //% "Public chat"
                    return qsTrId("public-chat")
                case Constants.chatType.privateGroupChat:
                    let cnt = chatContentRoot.usersStore.usersModule.model.count
                    //% "%1 members"
                    if(cnt > 1) return qsTrId("-1-members").arg(cnt);
                    //% "1 member"
                    return qsTrId("1-member");
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
                    Global.openPopup(groupInfoPopupComponent, {
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
            sectionModule: chatSectionModule
            chatContentModule: chatContentRoot.chatContentModule
            rootStore: chatContentRoot.rootStore
            maxHeight: chatContentRoot.height

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

        notificationCount: activityCenter.unreadNotificationsCount

        onSearchButtonClicked: root.openAppSearch()

        onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
        onNotificationButtonClicked: activityCenter.open()
        notificationButton.highlighted: activityCenter.visible

        popupMenu: ChatContextMenuView {
            emojiPopup: chatContentRoot.emojiPopup
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
                Global.openPopup(groupInfoPopupComponent, {
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
                chatContentRoot.rootStore.messageStore.requestMoreMessages();
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
                      //% "Connected"
                      qsTrId("connected") :
                      //% "Disconnected"
                      qsTrId("disconnected")
        }

        Connections {
            target: mainModule
            onOnlineStatusChanged: {
                if (connected === isConnected) return;
                isConnected = connected;
                if(isConnected){
                    timer.setTimeout(function(){
                        connectedStatusRect.visible = false;
                    }, 5000);
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

    StatusBanner {
        Layout.fillWidth: true
        visible: chatContentRoot.isBlocked
        type: StatusBanner.Type.Danger
        statusText: qsTr("Blocked")
    }

    MessageStore {
        id: messageStore
        messageModule: chatContentModule? chatContentModule.messagesModule : null
        chatSectionModule: chatContentRoot.rootStore.chatCommunitySectionModule
    }

    MessageContextMenuView {
        id: contextmenu
        store: chatContentRoot.rootStore
        reactionModel: chatContentRoot.rootStore.emojiReactionsModel
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
            Global.openPopup(pinnedMessagesPopupComponent, {
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
            store: chatContentRoot.rootStore
            contactsStore: chatContentRoot.contactsStore
            messageContextMenuInst: contextmenu
            messageStore: messageStore
            emojiPopup: chatContentRoot.emojiPopup
            usersStore: chatContentRoot.usersStore
            stickersLoaded: chatContentRoot.stickersLoaded
            isChatBlocked: chatContentRoot.isBlocked
            channelEmoji: chatContentModule.chatDetails.emoji || ""
            isActiveChannel: chatContentRoot.isActiveChannel
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
                store: chatContentRoot.rootStore
                usersStore: chatContentRoot.usersStore

                visible: {
                    return true
                        // Not Refactored Yet
                        //                if (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.privateGroupChat) {
                        //                    return chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.isMember
                        //                }
                        //                if (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.oneToOne) {
                        //                    return isContact
                        //                }
                        //                const community = chatContentRoot.rootStore.chatsModelInst.communities.activeCommunity
                        //                return !community.active ||
                        //                        community.access === Constants.communityChatPublicAccess ||
                        //                        community.admin ||
                        //                        chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.canPost
                }
                messageContextMenu: contextmenu
                emojiPopup: chatContentRoot.emojiPopup
                isContactBlocked: chatContentRoot.isBlocked
                isActiveChannel: chatContentRoot.isActiveChannel
                chatInputPlaceholder: chatContentRoot.isBlocked ?
                                          //% "This user has been blocked."
                                          qsTrId("this-user-has-been-blocked-") :
                                          //% "Type a message."
                                          qsTrId("type-a-message-")
                anchors.bottom: parent.bottom
                recentStickers: chatContentRoot.rootStore.stickersModuleInst.recent
                stickerPackList: chatContentRoot.rootStore.stickersModuleInst.stickerPacks
                chatType: chatContentModule? chatContentModule.chatDetails.type : Constants.chatType.unknown
                onSendTransactionCommandButtonClicked: {
                    if(!chatContentModule) {
                        console.debug("error on sending transaction command - chat content module is not set")
                        return
                    }

                    if (Utils.getContactDetailsAsJson(chatContentModule.getMyChatId()).ensVerified) {
                        Global.openPopup(chatContentRoot.sendTransactionWithEnsModal)
                    } else {
                        Global.openPopup(chatContentRoot.sendTransactionNoEnsModal)
                    }
                }
                onReceiveTransactionCommandButtonClicked: {
                    Global.openPopup(chatContentRoot.receiveTransactionModal)
                }
                onStickerSelected: {
                    chatContentRoot.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                          hashId,
                                                          chatInput.isReply ? chatInput.replyMessageId : "",
                                                          packId)
                }


                onSendMessage: {
                    if (!chatContentModule) {
                        console.debug("error on sending message - chat content module is not set")
                        return
                    }

                    if(chatContentRoot.rootStore.sendMessage(event,
                                                             chatInput.textInput.text,
                                                             chatInput.isReply? chatInput.replyMessageId : "",
                                                             chatInput.fileUrls
                                                             ))
                    {
                        sendMessageSound.stop();
                        Qt.callLater(sendMessageSound.play);

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
