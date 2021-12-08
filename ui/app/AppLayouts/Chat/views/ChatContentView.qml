import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
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

    StatusChatToolBar {
        id: topBar
        Layout.fillWidth: true

        chatInfoButton.title: chatContentModule.chatDetails.name
        chatInfoButton.subTitle: {
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
                let cnt = chatContentModule.usersModule.model.count
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
        chatInfoButton.image.source: chatContentModule.chatDetails.icon
        chatInfoButton.image.isIdenticon: chatContentModule.chatDetails.isIdenticon
        chatInfoButton.icon.color: chatContentModule.chatDetails.color
        chatInfoButton.type: chatContentModule.chatDetails.type
        chatInfoButton.pinnedMessagesCount: chatContentModule.pinnedMessagesModel.count
        chatInfoButton.muted: chatContentModule.chatDetails.muted

        chatInfoButton.onPinnedMessagesCountClicked: {
            Global.openPopup(pinnedMessagesPopupComponent, {
                          messageStore: messageStore,
                          pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                          messageToPin: ""
                      })
        }
        chatInfoButton.onUnmute: chatContentModule.unmuteChat()

        chatInfoButton.sensor.enabled: chatContentModule.chatDetails.type !== Constants.chatType.publicChat &&
                                       chatContentModule.chatDetails.type !== Constants.chatType.communityChat
        chatInfoButton.onClicked: {
            // Not Refactored Yet
//            switch (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType) {
//            case Constants.chatType.privateGroupChat:
//                openPopup(groupInfoPopupComponent, {
//                              channelType: GroupInfoPopup.ChannelType.ActiveChannel,
//                              channel: chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel
//                          })
//                break;
//            case Constants.chatType.oneToOne:
//                openProfilePopup(chatContentRoot.rootStore.chatsModelInst.userNameOrAlias(chatsModel.channelView.activeChannel.id),
//                                 chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.id, profileImage
//                                 || chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.identicon,
//                                 "", chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.nickname)
//                break;
//            }
        }

        membersButton.visible: localAccountSensitiveSettings.showOnlineUsers && chatContentModule.chatDetails.isUsersListAvailable
        membersButton.highlighted: localAccountSensitiveSettings.expandUsersList
        notificationButton.visible: localAccountSensitiveSettings.isActivityCenterEnabled
        notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList ? 0 : 14

        notificationCount: chatContentModule.chatDetails.notificationCount

        onSearchButtonClicked: root.openAppSearch()

        onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
        onNotificationButtonClicked: activityCenter.open()

        popupMenu: ChatContextMenuView {
            openHandler: function () {
                currentFleet = chatContentModule.getCurrentFleet()
                isCommunityChat = chatContentModule.chatDetails.belongsToCommunity
                isCommunityAdmin = chatContentModule.amIChatAdmin()
                chatId = chatContentModule.chatDetails.id
                chatName = chatContentModule.chatDetails.name
                chatDescription = chatContentModule.chatDetails.description
                chatType = chatContentModule.chatDetails.type
                chatMuted = chatContentModule.chatDetails.muted
            }

            onMuteChat: {
                chatContentModule.muteChat()
            }

            onUnmuteChat: {
                chatContentModule.unmuteChat()
            }

            onMarkAllMessagesRead: {
                chatContentModule.markAllMessagesRead()
            }

            onClearChatHistory: {
                chatContentModule.clearChatHistory()
            }

            onRequestAllHistoricMessages: {
                // Not Refactored Yet - Check in the `master` branch if this is applicable here.
            }

            onLeaveChat: {
                chatContentModule.leaveChat()
            }

            onDeleteChat: {
                // Not Refactored Yet
            }

            onDownloadMessages: {
                // Not Refactored Yet
            }

            onDisplayProfilePopup: {
                // Not Refactored Yet
            }

            onDisplayGroupInfoPopup: {
                // Not Refactored Yet
            }

            onEditCommunityChannel: {
                // Not Refactored Yet
            }

            onOpenPinnedMessagesList: {
                Global.openPopup(pinnedMessagesPopupComponent, {
                                     messageStore: messageStore,
                                     pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                                     messageToPin: ""
                                 })
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

        // Not Refactored Yet
//        Connections {
//            target: chatContentRoot.rootStore.chatsModelInst
//            onOnlineStatusChanged: {
//                if (connected == isConnected) return;
//                isConnected = connected;
//                if(isConnected){
//                    timer.setTimeout(function(){
//                        connectedStatusRect.visible = false;
//                    }, 5000);
//                } else {
//                    connectedStatusRect.visible = true;
//                }
//            }
//        }
//        Component.onCompleted: {
//            isConnected = chatContentRoot.rootStore.chatsModelInst.isOnline
//            if(!isConnected){
//                connectedStatusRect.visible = true
//            }
//        }
    }

    Item {
        Layout.fillWidth: true
        Layout.preferredHeight: 40
        Layout.alignment: Qt.AlignHCenter
        visible: isBlocked

        Rectangle {
            id: blockedBanner
            anchors.fill: parent
            color: Style.current.red
            opacity: 0.1
        }

        Text {
            id: blockedText
            anchors.centerIn: blockedBanner
            color: Style.current.red
            text: qsTr("Blocked")
        }
    }

    MessageStore{
        id: messageStore
        messageModule: chatContentModule.messagesModule
    }

    MessageContextMenuView {
        id: contextmenu
        reactionModel: chatContentRoot.rootStore.emojiReactionsModel
        onPinMessage: {
            messageStore.pinMessage(messageId)
        }

        onUnpinMessage: {
            messageStore.unpinMessage(messageId)
        }

        onPinnedMessagesLimitReached: {
            Global.openPopup(pinnedMessagesPopupComponent, {
                          messageStore: messageStore,
                          pinnedMessagesModel: chatContentModule.pinnedMessagesModel,
                          messageToPin: messageId
                      })
        }

        onToggleReaction: {
            messageStore.toggleReaction(messageId, emojiId)
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
            messageContextMenuInst: contextmenu
            messageStore: messageStore
        }

        Item {
            id: inputArea
            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
            Layout.fillWidth: true
            Layout.preferredWidth: parent.width
            height: chatInput.height
            Layout.preferredHeight: height

            // Not Refactored Yet
//            Connections {
//                target: chatContentRoot.rootStore.chatsModelInst.messageView
//                onLoadingMessagesChanged:
//                    if(value){
//                        loadingMessagesIndicator.active = true
//                    } else {
//                        timer.setTimeout(function(){
//                            loadingMessagesIndicator.active = false;
//                        }, 5000);
//                    }
//            }

            // Not Refactored Yet
//            Loader {
//                id: loadingMessagesIndicator
//                active: chatContentRoot.rootStore.chatsModelInst.messageView.loadingMessages
//                sourceComponent: loadingIndicator
//                anchors.right: parent.right
//                anchors.bottom: chatInput.top
//                anchors.rightMargin: Style.current.padding
//                anchors.bottomMargin: Style.current.padding
//            }

//            Component {
//                id: loadingIndicator
//                LoadingAnimation { }
//            }

            StatusChatInput {
                id: chatInput
                visible: {
                    // Not Refactored Yet
                    return true
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
                isContactBlocked: isBlocked
                chatInputPlaceholder: isBlocked ?
                                          //% "This user has been blocked."
                                          qsTrId("this-user-has-been-blocked-") :
                                          //% "Type a message."
                                          qsTrId("type-a-message-")
                anchors.bottom: parent.bottom
                recentStickers: chatContentRoot.rootStore.stickersModuleInst.recent
                stickerPackList: chatContentRoot.rootStore.stickersModuleInst.stickerPacks
//                chatType: chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.chatType
                onSendTransactionCommandButtonClicked: {
                    // Not Refactored Yet
                    //                if (chatContentRoot.rootStore.chatsModelInst.channelView.activeChannel.ensVerified) {
                    //                    txModalLoader.sourceComponent = cmpSendTransactionWithEns
                    //                } else {
                    //                    txModalLoader.sourceComponent = cmpSendTransactionNoEns
                    //                }
                    //                txModalLoader.item.open()
                }
                onReceiveTransactionCommandButtonClicked: {
                    // Not Refactored Yet
                    //                txModalLoader.sourceComponent = cmpReceiveTransaction
                    //                txModalLoader.item.open()
                }
                onStickerSelected: {
                    chatContentRoot.rootStore.sendSticker(chatContentModule.getMyChatId(),
                                                hashId,
                                                chatInput.isReply ? SelectedMessage.messageId : "",
                                                packId)
                }
                onSendMessage: {
                    if (chatInput.fileUrls.length > 0){
                        chatContentModule.inputAreaModule.sendImages(JSON.stringify(fileUrls));
                    }
                    let msg = globalUtils.plainText(Emoji.deparse(chatInput.textInput.text))
                    if (msg.length > 0) {
                        msg = chatInput.interpretMessage(msg)

                        chatContentModule.inputAreaModule.sendMessage(
                            msg,
                            chatInput.isReply ? SelectedMessage.messageId : "",
                            Utils.isOnlyEmoji(msg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
                            false)

                        if (event) event.accepted = true
                        sendMessageSound.stop();
                        Qt.callLater(sendMessageSound.play);

                        chatInput.textInput.clear();
                        chatInput.textInput.textFormat = TextEdit.PlainText;
                        chatInput.textInput.textFormat = TextEdit.RichText;
                    }
                }
            }
        }
    }
}
