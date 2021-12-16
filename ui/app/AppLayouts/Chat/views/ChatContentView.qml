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

ColumnLayout {
    id: root
    spacing: 0

    property var store

    property Component sendTransactionNoEnsModal
    property Component receiveTransactionModal
    property Component sendTransactionWithEnsModal

    StatusChatToolBar {
        id: topBar
        Layout.fillWidth: true

        chatInfoButton.title: root.store.chatContentModule.chatDetails.name
        chatInfoButton.subTitle: {
            // In some moment in future this should be part of the backend logic.
            // (once we add transaltion on the backend side)
            switch (root.store.chatContentModule.chatDetails.type) {
            case Constants.chatType.oneToOne:
                return (root.store.chatContentModule.isMyContact(root.store.chatContentModule.chatDetails.id) ?
                            //% "Contact"
                            qsTrId("chat-is-a-contact") :
                            //% "Not a contact"
                            qsTrId("chat-is-not-a-contact"))
            case Constants.chatType.publicChat:
                //% "Public chat"
                return qsTrId("public-chat")
            case Constants.chatType.privateGroupChat:
                let cnt = root.store.chatContentModule.usersModule.model.count
                //% "%1 members"
                if(cnt > 1) return qsTrId("-1-members").arg(cnt);
                //% "1 member"
                return qsTrId("1-member");
            case Constants.chatType.communityChat:
                return Utils.linkifyAndXSS(root.store.chatContentModule.chatDetails.description).trim()
            default:
                return ""
            }
        }
        chatInfoButton.image.source: root.store.chatContentModule.chatDetails.icon
        chatInfoButton.image.isIdenticon: root.store.chatContentModule.chatDetails.isIdenticon
        chatInfoButton.icon.color: root.store.chatContentModule.chatDetails.color
        chatInfoButton.type: root.store.chatContentModule.chatDetails.type
        chatInfoButton.pinnedMessagesCount: root.store.chatContentModule.pinnedMessagesModel.count
        chatInfoButton.muted: root.store.chatContentModule.chatDetails.muted
        chatInfoButton.onPinnedMessagesCountClicked: {
            Global.openPopup(pinnedMessagesPopupComponent, {
                          pinnedMessagesModel: root.store.chatContentModule.pinnedMessagesModel,
                          messageToPin: ""
                      })
        }
        chatInfoButton.onUnmute: root.store.chatContentModule.unmuteChat()

        chatInfoButton.sensor.enabled: root.store.chatContentModule.chatDetails.type !== Constants.chatType.publicChat &&
                                       root.store.chatContentModule.chatDetails.type !== Constants.chatType.communityChat
        chatInfoButton.onClicked: {
            // Not Refactored Yet
//            switch (root.rootStore.chatsModelInst.channelView.activeChannel.chatType) {
//            case Constants.chatType.privateGroupChat:
//                openPopup(groupInfoPopupComponent, {
//                              channelType: GroupInfoPopup.ChannelType.ActiveChannel,
//                              channel: root.rootStore.chatsModelInst.channelView.activeChannel
//                          })
//                break;
//            case Constants.chatType.oneToOne:
//                openProfilePopup(root.rootStore.chatsModelInst.userNameOrAlias(chatsModel.channelView.activeChannel.id),
//                                 root.rootStore.chatsModelInst.channelView.activeChannel.id, profileImage
//                                 || root.rootStore.chatsModelInst.channelView.activeChannel.identicon,
//                                 "", root.rootStore.chatsModelInst.channelView.activeChannel.nickname)
//                break;
//            }
        }

        membersButton.visible: localAccountSensitiveSettings.showOnlineUsers && root.store.chatContentModule.chatDetails.isUsersListAvailable
        membersButton.highlighted: localAccountSensitiveSettings.expandUsersList
        notificationButton.visible: localAccountSensitiveSettings.isActivityCenterEnabled
        notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList ? 0 : 14

        notificationCount: root.store.chatContentModule.chatDetails.notificationCount

        onSearchButtonClicked: root.openAppSearch()

        onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
        onNotificationButtonClicked: activityCenter.open()

        popupMenu: ChatContextMenuView {
            openHandler: function () {
                currentFleet = root.store.chatContentModule.getCurrentFleet()
                isCommunityChat = root.store.chatContentModule.chatDetails.belongsToCommunity
                isCommunityAdmin = root.store.chatContentModule.amIChatAdmin()
                chatId = root.store.chatContentModule.chatDetails.id
                chatName = root.store.chatContentModule.chatDetails.name
                chatDescription = root.store.chatContentModule.chatDetails.description
                chatType = root.store.chatContentModule.chatDetails.type
                chatMuted = root.store.chatContentModule.chatDetails.muted
            }

            onMuteChat: {
                root.store.chatContentModule.muteChat()
            }

            onUnmuteChat: {
                root.store.chatContentModule.unmuteChat()
            }

            onMarkAllMessagesRead: {
                root.store.chatContentModule.markAllMessagesRead()
            }

            onClearChatHistory: {
                root.store.chatContentModule.clearChatHistory()
            }

            onRequestAllHistoricMessages: {
                // Not Refactored Yet - Check in the `master` branch if this is applicable here.
            }

            onLeaveChat: {
                root.store.chatContentModule.leaveChat(chatId);
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
                                     pinnedMessagesModel: root.store.chatContentModule.pinnedMessagesModel,
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

    MessageContextMenuView {
        id: contextmenu
        reactionModel: root.store.emojiReactionsModel
        onPinMessage: {
            root.store.messageStore.pinMessage(messageId)
        }

        onUnpinMessage: {
            root.store.messageStore.unpinMessage(messageId)
        }

        onPinnedMessagesLimitReached: {
            Global.openPopup(pinnedMessagesPopupComponent, {
                          messageStore: root.store.messageStore,
                          pinnedMessagesModel: root.store.chatContentModule.pinnedMessagesModel,
                          messageToPin: messageId
                      })
        }

        onToggleReaction: {
            root.store.messageStore.toggleReaction(messageId, emojiId)
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
            store: root.store
            messageContextMenuInst: contextmenu
            messageStore: root.store.messageStore
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
                chatType: chatContentModule.chatDetails.type
                onSendTransactionCommandButtonClicked: {
                    if (chatContentRoot.rootStore.isEnsVerified(chatContentModule.getMyChatId())) {
                        Global.openPopup(chatContentRoot.sendTransactionWithEnsModal)
                    } else {
                        Global.openPopup(chatContentRoot.sendTransactionNoEnsModal)
                    }
                }
                onReceiveTransactionCommandButtonClicked: {
                    Global.openPopup(chatContentRoot.receiveTransactionModal)
                }
                onStickerSelected: {
//                    root.store.sendSticker(root.store.chatContentModule.getMyChatId(),
//                                                hashId,
//                                                chatInput.isReply ? SelectedMessage.messageId : "",
//                                                packId)
                }
                onSendMessage: {
//                    if (chatInput.fileUrls.length > 0){
//                        root.store.chatContentModule.inputAreaModule.sendImages(JSON.stringify(fileUrls));
//                    }
//                    let msg = globalUtils.plainText(Emoji.deparse(chatInput.textInput.text))
//                    if (msg.length > 0) {
//                        msg = chatInput.interpretMessage(msg)

//                        root.store.chatContentModule.inputAreaModule.sendMessage(
//                            msg,
//                            chatInput.isReply ? SelectedMessage.messageId : "",
//                            Utils.isOnlyEmoji(msg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
//                            false)

//                        if (event) event.accepted = true
//                        sendMessageSound.stop();
//                        Qt.callLater(sendMessageSound.play);

//                        chatInput.textInput.clear();
//                        chatInput.textInput.textFormat = TextEdit.PlainText;
//                        chatInput.textInput.textFormat = TextEdit.RichText;
//                    }
                }
            }
        }
    }
}
