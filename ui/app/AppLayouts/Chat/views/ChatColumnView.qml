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

import "../helpers"
import "../controls"
import "../popups"
import "../panels"
import "../../Wallet"

Item {
    id: root
    anchors.fill: parent
    property var rootStore
    property alias pinnedMessagesPopupComponent: pinnedMessagesPopupComponent
    property int chatGroupsListViewCount: 0
    property bool isReply: false
    property bool isImage: false
    property bool isExtendedInput: isReply || isImage
    property bool isConnected: false
    property string contactToRemove: ""
    property string activeChatId: root.rootStore.chatsModelInst.channelView.activeChannel.id
    property bool isBlocked: root.rootStore.contactsModuleInst.model.isContactBlocked(activeChatId)
    property bool isContact: root.rootStore.contactsModuleInst.model.isAdded(activeChatId)
//    property bool contactRequestReceived: root.rootStore.contactsModuleInst.model.contactRequestReceived(activeChatId)
    property string currentNotificationChatId
    property string currentNotificationCommunityId
    property var currentTime: 0
    property var idMap: ({})
    property Timer timer: Timer { }
    property var userList
//    property var onActivated: function () {
//        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
//            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
//    }

    signal openAppSearch()

    function hideChatInputExtendedArea () {
        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.hideExtendedArea()
    }

    function showReplyArea() {
        isReply = true;
        isImage = false;
        let replyMessageIndex = root.rootStore.chatsModelInst.messageView.messageList.getMessageIndex(SelectedMessage.messageId);
        if (replyMessageIndex === -1) return;
        let userName = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "userName")
        let message = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "message")
        let identicon = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "identicon")
        let image = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "image")
        let sticker = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker")
        let contentType = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "contentType")

        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.showReplyArea(userName, message, identicon, contentType, image, sticker)
    }

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  root.rootStore.utilsModelInst.eth2Wei(amount.toString(), tokenDecimals)
        root.rootStore.chatsModelInst.transactions.requestAddress(activeChatId,
                                               address,
                                               amount,
                                               tokenAddress)
        txModalLoader.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  root.rootStore.utilsModelInst.eth2Wei(amount.toString(), tokenDecimals)
        root.rootStore.chatsModelInst.transactions.request(activeChatId,
                                        address,
                                        amount,
                                        tokenAddress)
        txModalLoader.close()
    }

    function clickOnNotification() {
        // So far we're just showing this app as the top most window. Once we decide about the way
        // how to notify the app what channle should be displayed within the app when user clicks
        // notificaiton bubble this part should be updated accordingly.
        //
        // I removed part of this function which caused app crash.
        applicationWindow.show()
        applicationWindow.raise()
        applicationWindow.requestActivate()
    }

    function positionAtMessage(messageId, isSearch = false) {
        stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].message.scrollToMessage(messageId, isSearch);
    }

    Timer {
        interval: 60000; // 1 min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.currentTime = Date.now()
        }
    }

    MessageContextMenuView {
        id: contextmenu
        store: root.rootStore
        reactionModel: root.rootStore.emojiReactionsModel
    }

    StackLayout {
        anchors.fill: parent
        currentIndex:  root.rootStore.chatsModelInst.channelView.activeChannelIndex > -1
                       && chatGroupsListViewCount > 0 ? 0 : 1

        StatusImageModal {
            id: imagePopup
            onClicked: {
                if (button === Qt.LeftButton) {
                    imagePopup.close()
                }
                else if(button === Qt.RightButton) {
                    contextmenu.imageSource = imagePopup.imageSource
                    contextmenu.hideEmojiPicker = true
                    contextmenu.isRightClickOnImage = true;
                    contextmenu.show()
                }
            }
        }

        ColumnLayout {
            spacing: 0

            StatusChatToolBar {
                id: topBar
                Layout.fillWidth: true

                property string chatId: root.rootStore.chatsModelInst.channelView.activeChannel.id
                property string profileImage: appMain.getProfileImage(chatId) || ""

                chatInfoButton.title: Utils.removeStatusEns(root.rootStore.chatsModelInst.channelView.activeChannel.name)
                chatInfoButton.subTitle: {
                    switch (root.rootStore.chatsModelInst.channelView.activeChannel.chatType) {
                    case Constants.chatTypeOneToOne:
                        return (root.rootStore.contactsModuleInst.model.isAdded(topBar.chatId) ?
                                    //% "Contact"
                                    qsTrId("chat-is-a-contact") :
                                    //% "Not a contact"
                                    qsTrId("chat-is-not-a-contact"))
                    case Constants.chatTypePublic:
                        //% "Public chat"
                        return qsTrId("public-chat")
                    case Constants.chatTypePrivateGroupChat:
                        let cnt = root.rootStore.chatsModelInst.channelView.activeChannel.members.rowCount();
                        //% "%1 members"
                        if(cnt > 1) return qsTrId("-1-members").arg(cnt);
                        //% "1 member"
                        return qsTrId("1-member");
                    case Constants.chatTypeCommunity:
                        return Utils.linkifyAndXSS(root.rootStore.chatsModelInst.channelView.activeChannel.description).trim()
                    default:
                        return ""
                    }
                }
                chatInfoButton.image.source: profileImage || root.rootStore.chatsModelInst.channelView.activeChannel.identicon
                chatInfoButton.image.isIdenticon: !!!profileImage && root.rootStore.chatsModelInst.channelView.activeChannel.identicon
                chatInfoButton.icon.color: root.rootStore.chatsModelInst.channelView.activeChannel.color
                chatInfoButton.type: root.rootStore.chatsModelInst.channelView.activeChannel.chatType
                chatInfoButton.pinnedMessagesCount: root.rootStore.chatsModelInst.messageView.pinnedMessagesList.count
                chatInfoButton.muted: root.rootStore.chatsModelInst.channelView.activeChannel.muted

                chatInfoButton.onPinnedMessagesCountClicked: openPopup(pinnedMessagesPopupComponent)
                chatInfoButton.onUnmute: root.rootStore.chatsModelInst.channelView.unmuteChatItem(chatsModel.channelView.activeChannel.id)

                chatInfoButton.sensor.enabled: root.rootStore.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypePublic &&
                                               root.rootStore.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypeCommunity
                chatInfoButton.onClicked: {
                    switch (root.rootStore.chatsModelInst.channelView.activeChannel.chatType) {
                    case Constants.chatTypePrivateGroupChat:
                        openPopup(groupInfoPopupComponent, {
                            channelType: GroupInfoPopup.ChannelType.ActiveChannel,
                            channel: root.rootStore.chatsModelInst.channelView.activeChannel
                        })
                        break;
                    case Constants.chatTypeOneToOne:
                        openProfilePopup(root.rootStore.chatsModelInst.userNameOrAlias(chatsModel.channelView.activeChannel.id),
                                         root.rootStore.chatsModelInst.channelView.activeChannel.id, profileImage
                                         || root.rootStore.chatsModelInst.channelView.activeChannel.identicon,
                                         "", root.rootStore.chatsModelInst.channelView.activeChannel.nickname)
                        break;
                    }
                }

                membersButton.visible: (localAccountSensitiveSettings.showOnlineUsers || root.rootStore.chatsModelInst.communities.activeCommunity.active)
                                       && root.rootStore.chatsModelInst.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne
                membersButton.highlighted: localAccountSensitiveSettings.expandUsersList
                notificationButton.visible: localAccountSensitiveSettings.isActivityCenterEnabled
                notificationButton.tooltip.offset: localAccountSensitiveSettings.expandUsersList ? 0 : 14
                notificationCount: root.rootStore.chatsModelInst.activityNotificationList.unreadCount

                onSearchButtonClicked: root.openAppSearch()

                onMembersButtonClicked: localAccountSensitiveSettings.expandUsersList = !localAccountSensitiveSettings.expandUsersList
                onNotificationButtonClicked: activityCenter.open()

                popupMenu: ChatContextMenuView {
                    store: root.rootStore
                    onOpened: {
                        chatItem = root.rootStore.chatsModelInst.channelView.activeChannel
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
                    target: root.rootStore.chatsModelInst
                    onOnlineStatusChanged: {
                        if (connected == isConnected) return;
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
                    isConnected = root.rootStore.chatsModelInst.isOnline
                    if(!isConnected){
                        connectedStatusRect.visible = true
                    }
                }
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

            StackLayout {
                id: stackLayoutChatMessages
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                currentIndex: root.rootStore.chatsModelInst.messageView.getMessageListIndex(root.rootStore.chatsModelInst.channelView.activeChannelIndex)
                Repeater {
                    model: root.rootStore.chatsModelInst.messageView
                    ColumnLayout {
                        property alias chatInput: chatInput
                        property alias message: messageLoader.item
                        Loader {
                            id: messageLoader
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            Layout.preferredWidth: parent.width

                            active: stackLayoutChatMessages.currentIndex === index
                            sourceComponent: ChatMessagesView {
                                id: chatMessages
                                store: root.rootStore
                                messageList: messages
                                messageContextMenuInst: contextmenu
                                Component.onCompleted: {
                                    root.userList = chatMessages.messageList.userList;
                                }
                            }
                        }
                        Item {
                            id: inputArea
                            Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                            Layout.fillWidth: true
                            Layout.preferredWidth: parent.width
                            height: chatInput.height
                            Layout.preferredHeight: height

                            Connections {
                                target: root.rootStore.chatsModelInst.messageView
                                onLoadingMessagesChanged:
                                    if(value){
                                        loadingMessagesIndicator.active = true
                                    } else {
                                        timer.setTimeout(function(){
                                            loadingMessagesIndicator.active = false;
                                        }, 5000);
                                    }
                            }

                            Loader {
                                id: loadingMessagesIndicator
                                active: root.rootStore.chatsModelInst.messageView.loadingMessages
                                sourceComponent: loadingIndicator
                                anchors.right: parent.right
                                anchors.bottom: chatInput.top
                                anchors.rightMargin: Style.current.padding
                                anchors.bottomMargin: Style.current.padding
                            }

                            Component {
                                id: loadingIndicator
                                LoadingAnimation { }
                            }

                            StatusChatInput {
                                id: chatInput
                                visible: {
                                    if (root.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat) {
                                        return root.rootStore.chatsModelInst.channelView.activeChannel.isMember
                                    }
                                    if (root.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypeOneToOne) {
                                        return isContact
                                    }
                                    const community = root.rootStore.chatsModelInst.communities.activeCommunity
                                    return !community.active ||
                                            community.access === Constants.communityChatPublicAccess ||
                                            community.admin ||
                                            root.rootStore.chatsModelInst.channelView.activeChannel.canPost
                                }
                                isContactBlocked: isBlocked
                                chatInputPlaceholder: isBlocked ?
                                                          //% "This user has been blocked."
                                                          qsTrId("this-user-has-been-blocked-") :
                                                          //% "Type a message."
                                                          qsTrId("type-a-message-")
                                anchors.bottom: parent.bottom
                                recentStickers: root.rootStore.chatsModelInst.stickers.recent
                                stickerPackList: root.rootStore.chatsModelInst.stickers.stickerPacks
                                chatType: root.rootStore.chatsModelInst.channelView.activeChannel.chatType
                                onSendTransactionCommandButtonClicked: {
                                    if (root.rootStore.chatsModelInst.channelView.activeChannel.ensVerified) {
                                        txModalLoader.sourceComponent = cmpSendTransactionWithEns
                                    } else {
                                        txModalLoader.sourceComponent = cmpSendTransactionNoEns
                                    }
                                    txModalLoader.item.open()
                                }
                                onReceiveTransactionCommandButtonClicked: {
                                    txModalLoader.sourceComponent = cmpReceiveTransaction
                                    txModalLoader.item.open()
                                }
                                onStickerSelected: {
                                    root.rootStore.chatsModelInst.stickers.send(hashId, chatInput.isReply ? SelectedMessage.messageId : "", packId)
                                }
                                onSendMessage: {
                                    if (chatInput.fileUrls.length > 0){
                                        root.rootStore.chatsModelInst.sendImages(JSON.stringify(fileUrls));
                                    }
                                    let msg = root.rootStore.chatsModelInst.plainText(Emoji.deparse(chatInput.textInput.text))
                                    if (msg.length > 0){
                                        msg = chatInput.interpretMessage(msg)
                                        root.rootStore.chatsModelInst.messageView.sendMessage(msg, chatInput.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType, false);
                                        if(event) event.accepted = true
                                        sendMessageSound.stop();
                                        Qt.callLater(sendMessageSound.play);

                                        chatInput.textInput.clear();
                                        chatInput.textInput.textFormat = TextEdit.PlainText;
                                        chatInput.textInput.textFormat = TextEdit.RichText;
                                    }
                                }
                            }
                        }
                        Connections {
                            target: root.rootStore.chatsModelInst.channelView
                            onActiveChannelChanged: {
                                isBlocked = root.rootStore.contactsModuleInst.model.isContactBlocked(activeChatId);
                                chatInput.suggestions.hide();
                                if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
                                    stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
                            }
                        }
                    }
                }
            }

            ChatRequestMessagePanel {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
                visible: root.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatTypeOneToOne
                    && (!isContact /*|| !contactRequestReceived*/)
                onAddContactClicked: root.rootStore.contactsModuleInst.addContact(activeChatId)
            }
        }

        EmptyChatPanel {
            //TODO move profileModule to store
            onShareChatKeyClicked: openProfilePopup(root.rootStore.profileModelInst.profile.username, root.rootStore.profileModelInst.profile.pubKey, profileModule.model.thumbnailImage);
        }

        Loader {
            id: txModalLoader
            function close() {
                if (!this.item) {
                    return
                }
                this.item.close()
                this.closed()
            }
            function closed() {
                this.sourceComponent = undefined
            }
        }

        Component {
            id: cmpSendTransactionNoEns
            ChatCommandModal {
                id: sendTransactionNoEns
                store: root.rootStore
                onClosed: {
                    txModalLoader.closed()
                }
                sendChatCommand: root.requestAddressForTransaction
                isRequested: false
                //% "Send"
                commandTitle: qsTrId("command-button-send")
                header.title: commandTitle
                //% "Request Address"
                finalButtonLabel: qsTrId("request-address")
                selectRecipient.selectedRecipient: {
                    return {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        alias: root.rootStore.chatsModelInst.channelView.activeChannel.alias,
                        identicon: root.rootStore.chatsModelInst.channelView.activeChannel.identicon,
                        name: root.rootStore.chatsModelInst.channelView.activeChannel.name,
                        type: RecipientSelector.Type.Contact
                    }
                }
                selectRecipient.selectedType: RecipientSelector.Type.Contact
                selectRecipient.readOnly: true
            }
        }

        Component {
            id: cmpReceiveTransaction
            ChatCommandModal {
                id: receiveTransaction
                store: root.rootStore
                onClosed: {
                    txModalLoader.closed()
                }
                sendChatCommand: root.requestTransaction
                isRequested: true
                //% "Request"
                commandTitle: qsTrId("wallet-request")
                header.title: commandTitle
                //% "Request"
                finalButtonLabel: qsTrId("wallet-request")
                selectRecipient.selectedRecipient: {
                    return {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        alias: root.rootStore.chatsModelInst.channelView.activeChannel.alias,
                        identicon: root.rootStore.chatsModelInst.channelView.activeChannel.identicon,
                        name: root.rootStore.chatsModelInst.channelView.activeChannel.name,
                        type: RecipientSelector.Type.Contact
                    }
                }
                selectRecipient.selectedType: RecipientSelector.Type.Contact
                selectRecipient.readOnly: true
            }
        }

        Component {
            id: cmpSendTransactionWithEns
            SendModal {
                id: sendTransactionWithEns
                onOpened: {
                    root.rootStore.walletModelInst.gasView.getGasPrice()
                }
                onClosed: {
                    txModalLoader.closed()
                }
                selectRecipient.readOnly: true
                selectRecipient.selectedRecipient: {
                    return {
                        address: "",
                        alias: root.rootStore.chatsModelInst.channelView.activeChannel.alias,
                        identicon: root.rootStore.chatsModelInst.channelView.activeChannel.identicon,
                        name: root.rootStore.chatsModelInst.channelView.activeChannel.name,
                        type: RecipientSelector.Type.Contact,
                        ensVerified: true
                    }
                }
                selectRecipient.selectedType: RecipientSelector.Type.Contact
            }
        }

        ActivityCenterPopup {
            id: activityCenter
            height: root.height - (topBar.height * 2) // TODO get screen size
            y: topBar.height
            store: root.rootStore
        }

        Connections {
            target: root.rootStore.contactsModuleInst.model
            onContactListChanged: {
                isBlocked = root.rootStore.contactsModuleInst.model.isContactBlocked(activeChatId);
            }
        }

        Connections {
            target: root.rootStore.chatsModelInst.channelView
            onActiveChannelChanged: {
                root.rootStore.chatsModelInst.messageView.hideLoadingIndicator()
                SelectedMessage.reset();
                chatColumn.isReply = false;
            }
        }

        Connections {
            target: systemTray
            onMessageClicked: function () {
                clickOnNotification()
            }
        }

        Component {
            id: pinnedMessagesPopupComponent
            PinnedMessagesPopup {
                id: pinnedMessagesPopup
                rootStore: root.rootStore
                messageStore: root.rootStore.messageStore
                onClosed: destroy()
            }
        }

        Connections {
            target: root.rootStore.chatsModelInst.messageView

            onSearchedMessageLoaded: {
                positionAtMessage(messageId, true);
            }

            onMessageNotificationPushed: function(messageId, communityId, chatId, msg, contentType, chatType, timestamp, identicon, username, hasMention, isAddedContact, channelName) {
                if (localAccountSensitiveSettings.notificationSetting == Constants.notifyAllMessages ||
                        (localAccountSensitiveSettings.notificationSetting == Constants.notifyJustMentions && hasMention)) {
                    if (chatId === root.rootStore.chatsModelInst.channelView.activeChannel.id && applicationWindow.active === true) {
                        // Do not show the notif if we are in the channel already and the window is active and focused
                        return
                    }

                    root.currentNotificationChatId = chatId
                    root.currentNotificationCommunityId = null

                    let name;
                    if (localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous) {
                        name = "Status"
                    } else if (chatType === Constants.chatTypePublic) {
                        name = chatId
                    } else {
                        name = chatType === Constants.chatTypePrivateGroupChat ? Utils.filterXSS(channelName) : Utils.removeStatusEns(username)
                    }

                    let message;
                    if (localAccountSensitiveSettings.notificationMessagePreviewSetting > Constants.notificationPreviewNameOnly) {
                        switch(contentType){
                            //% "Image"
                        case Constants.imageType: message = qsTrId("image"); break
                            //% "Sticker"
                        case Constants.stickerType: message = qsTrId("sticker"); break
                        default: message = msg // don't parse emojis here as it emits HTML
                        }
                    } else {
                        //% "You have a new message"
                        message = qsTrId("you-have-a-new-message")
                    }

                    currentlyHasANotification = true

                    // Note:
                    // Show notification should be moved to the nim side.
                    // Left here only cause we don't have a way to deal with translations on the nim side.
                    root.rootStore.chatsModelInst.showOSNotification(name,
                                                  message,
                                                  Constants.osNotificationType.newMessage,
                                                  communityId,
                                                  chatId,
                                                  messageId,
                                                  localAccountSensitiveSettings.useOSNotifications)
                }
            }
        }

        Component.onCompleted: {
            if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
                stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
        }

        Connections {
            target: root.rootStore.chatsModelInst.stickers
            onTransactionWasSent: {
                //% "Transaction pending..."
                toastMessage.title = qsTr("Transaction pending...")
                toastMessage.source = Style.svg("loading")
                toastMessage.iconColor = Style.current.primary
                toastMessage.iconRotates = true
                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txResult}`
                toastMessage.open()
            }
            onTransactionCompleted: {
                toastMessage.title = !success ?
                                     //% "Could not buy Stickerpack"
                                     qsTrId("could-not-buy-stickerpack")
                                     :
                                     //% "Stickerpack bought successfully"
                                     qsTrId("stickerpack-bought-successfully");
                if (success) {
                    toastMessage.source = Style.svg("check-circle")
                    toastMessage.iconColor = Style.current.success
                } else {
                    toastMessage.source = Style.svg("block-icon")
                    toastMessage.iconColor = Style.current.danger
                }

                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
                toastMessage.open()
            }
        }
    }
}

/*##^##
Designer {
    D{i:0;formeditorColor:"#ffffff";height:770;width:800}
}
##^##*/
