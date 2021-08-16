import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0

import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1

import "../../../shared"
import "../../../shared/status"
import "../../../imports"
import "./components"
import "./ChatColumn"
import "./ChatColumn/ChatComponents"
import "./data"
import "../Wallet"


Item {
    id: chatColumnLayout
    anchors.fill: parent

    property alias pinnedMessagesPopupComponent: pinnedMessagesPopupComponent
    property int chatGroupsListViewCount: 0
    property bool isReply: false
    property bool isImage: false
    property bool isExtendedInput: isReply || isImage
    property bool isConnected: false
    property string contactToRemove: ""
    property bool showUsers: false
    property string activeChatId: chatsModel.channelView.activeChannel.id
    property bool isBlocked: profileModel.contacts.isContactBlocked(activeChatId)
    property bool isContact: profileModel.contacts.isAdded(activeChatId)
    property bool contactRequestReceived: profileModel.contacts.contactRequestReceived(activeChatId)
    property string currentNotificationChatId
    property string currentNotificationCommunityId
    property alias input: chatInput
    property string hoveredMessage
    property string activeMessage
    property var currentTime: 0
    property var idMap: ({})
    property var suggestionsObj: ([])
    property Timer timer: Timer { }
    property var userList
    property var onActivated: function () {
        chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
    }

    function setHovered(messageId, hovered) {
        if (hovered) {
            hoveredMessage = messageId
        } else if (hoveredMessage === messageId) {
            hoveredMessage = ""
        }
    }

    function setMessageActive(messageId, active) {
        if (active) {
            activeMessage = messageId
        } else if (activeMessage === messageId) {
            activeMessage = ""
        }
    }

    function addSuggestionFromMessageList(i){
        const contactAddr = chatsModel.messageView.messageList.getMessageData(i, "publicKey");
        if(idMap[contactAddr]) return;
        suggestionsObj.push({
                                alias: chatsModel.messageView.messageList.getMessageData(i, "alias"),
                                ensName: chatsModel.messageView.messageList.getMessageData(i, "ensName"),
                                address: contactAddr,
                                identicon: chatsModel.messageView.messageList.getMessageData(i, "identicon"),
                                localNickname: chatsModel.messageView.messageList.getMessageData(i, "localName")
                            })
        chatInput.suggestionsList.append(suggestionsObj[suggestionsObj.length - 1]);
        idMap[contactAddr] = true;
    }

    function populateSuggestions() {
        chatInput.suggestionsList.clear()

        idMap = {}

        let isCommunity = chatsModel.communities.activeCommunity.active
        let dataSource = isCommunity ? chatsModel.communities.activeCommunity.members : chatsModel.suggestionList

        const len = dataSource.rowCount()
        for (let i = 0; i < len; i++) {
            const contactAddr = dataSource.rowData(i, "address");
            if(idMap[contactAddr]) continue;
            suggestionsObj.push({
                                    alias: dataSource.rowData(i, "alias"),
                                    ensName: dataSource.rowData(i, "ensName"),
                                    address: contactAddr,
                                    identicon: getProfileImage(contactAddr, false, false) || dataSource.rowData(i, "identicon"),
                                    localNickname: dataSource.rowData(i, "localNickname")
                                })

            chatInput.suggestionsList.append(suggestionsObj[suggestionsObj.length - 1]);
            idMap[contactAddr] = true;
        }

        if (isCommunity) return;

        const len2 = chatsModel.messageView.messageList.rowCount();
        for (let f = 0; f < len2; f++) {
            addSuggestionFromMessageList(f);
        }
    }

    function showReplyArea() {
        isReply = true;
        isImage = false;
        let replyMessageIndex = chatsModel.messageView.messageList.getMessageIndex(SelectedMessage.messageId);
        if (replyMessageIndex === -1) return;
        let userName = chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "userName")
        let message = chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "message")
        let identicon = chatsModel.messageView.messageList.getMessageData(replyMessageIndex, "identicon")

        chatInput.showReplyArea(userName, message, identicon)
    }

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  utilsModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.transactions.requestAddress(activeChatId,
                                               address,
                                               amount,
                                               tokenAddress)
        txModalLoader.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  utilsModel.eth2Wei(amount.toString(), tokenDecimals)
        chatsModel.transactions.request(activeChatId,
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

    function positionAtMessage(messageId) {
        stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].item.scrollToMessage(messageId)
    }

    Timer {
        interval: 60000; // 1 min
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            chatColumnLayout.currentTime = Date.now()
        }
    }

    StackLayout {
        anchors.fill: parent
        currentIndex:  chatsModel.channelView.activeChannelIndex > -1 && chatGroupsListViewCount > 0 ? 0 : 1

        StatusImageModal {
            id: imagePopup
            onClicked: {
                if (button === Qt.LeftButton) {
                    imagePopup.close()
                }
                else if(button === Qt.RightButton) {
                    messageContextMenu.imageSource = imagePopup.imageSource
                    messageContextMenu.hideEmojiPicker = true
                    messageContextMenu.isRightClickOnImage = true;
                    messageContextMenu.show()
                }
            }
        }

        ColumnLayout {
            spacing: 0

            StatusChatToolBar {
                id: topBar
                Layout.fillWidth: true

                property string chatId: chatsModel.channelView.activeChannel.id
                property string profileImage: appMain.getProfileImage(chatId) || ""

                chatInfoButton.title: Utils.removeStatusEns(chatsModel.channelView.activeChannel.name)
                chatInfoButton.subTitle: {
                    switch (chatsModel.channelView.activeChannel.chatType) {
                    case Constants.chatTypeOneToOne:
                        return (profileModel.contacts.isAdded(topBar.chatId) ?
                                    //% "Contact"
                                    qsTrId("chat-is-a-contact") :
                                    //% "Not a contact"
                                    qsTrId("chat-is-not-a-contact"))
                    case Constants.chatTypePublic:
                        //% "Public chat"
                        return qsTrId("public-chat")
                    case Constants.chatTypePrivateGroupChat:
                        let cnt = chatsModel.channelView.activeChannel.members.rowCount();
                        //% "%1 members"
                        if(cnt > 1) return qsTrId("-1-members").arg(cnt);
                        //% "1 member"
                        return qsTrId("1-member");
                    case Constants.chatTypeCommunity:
                        return chatsModel.channelView.activeChannel.description
                    default:
                        return ""
                    }
                }
                chatInfoButton.image.source: profileImage || chatsModel.channelView.activeChannel.identicon
                chatInfoButton.image.isIdenticon: !!!profileImage && chatsModel.channelView.activeChannel.identicon
                chatInfoButton.icon.color: chatsModel.channelView.activeChannel.color
                chatInfoButton.type: chatsModel.channelView.activeChannel.chatType
                chatInfoButton.pinnedMessagesCount: chatsModel.messageView.pinnedMessagesList.count
                chatInfoButton.muted: chatsModel.channelView.activeChannel.muted

                chatInfoButton.onPinnedMessagesCountClicked: openPopup(pinnedMessagesPopupComponent)
                chatInfoButton.onUnmute: chatsModel.channelView.unmuteChatItem(chatsModel.channelView.activeChannel.id)

                chatInfoButton.sensor.enabled: chatsModel.channelView.activeChannel.chatType !== Constants.chatTypePublic &&
                                               chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeCommunity
                chatInfoButton.onClicked: {
                    switch (chatsModel.channelView.activeChannel.chatType) {
                    case Constants.chatTypePrivateGroupChat:
                        openPopup(groupInfoPopupComponent, {
                            channelType: GroupInfoPopup.ChannelType.ActiveChannel,
                            channel: chatsModel.channelView.activeChannel
                        })
                        break;
                    case Constants.chatTypeOneToOne:
                        openProfilePopup(chatsModel.userNameOrAlias(chatsModel.channelView.activeChannel.id),
                                         chatsModel.channelView.activeChannel.id, profileImage || chatsModel.channelView.activeChannel.identicon,
                                         "", chatsModel.channelView.activeChannel.nickname)
                        break;
                    }
                }

                membersButton.visible: appSettings.showOnlineUsers && chatsModel.channelView.activeChannel.chatType !== Constants.chatTypeOneToOne
                membersButton.highlighted: showUsers
                notificationButton.visible: appSettings.isActivityCenterEnabled
                notificationButton.tooltip.offset: showUsers ? 0 : 14
                notificationCount: chatsModel.activityNotificationList.unreadCount

                onSearchButtonClicked: searchPopup.open()

                onMembersButtonClicked: showUsers = !showUsers
                onNotificationButtonClicked: activityCenter.open()

                popupMenu: ChatContextMenu {
                    openHandler: {
                        chatItem = chatsModel.channelView.activeChannel
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
                    target: chatsModel
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
                    isConnected = chatsModel.isOnline
                    if(!isConnected){
                        connectedStatusRect.visible = true
                    }
                }
            }

            Rectangle {
                id: blockedBanner
                Layout.fillWidth: true
                height: 40
                Layout.alignment: Qt.AlignHCenter
                visible: isBlocked
                color: Style.current.red
                opacity: 0.1
            }

            Text {
                id: blockedText
                anchors.centerIn: blockedBanner
                visible: isBlocked
                color: Style.current.red
                text: qsTr("Blocked")
            }

            StackLayout {
                id: stackLayoutChatMessages
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                currentIndex: chatsModel.messageView.getMessageListIndex(chatsModel.channelView.activeChannelIndex)
                Repeater {
                    model: chatsModel.messageView
                    Loader {
                        active: stackLayoutChatMessages.currentIndex === index
                        sourceComponent: ChatMessages {
                            id: chatMessages
                            messageList: messages
                            messageContextMenuInst: MessageContextMenu {
                                reactionModel: EmojiReactions { }
                            }
                            Component.onCompleted: {
                                chatColumnLayout.userList = chatMessages.messageList.userList;
                            }
                        }
                    }
                }
            }

            Connections {
                target: chatsModel.channelView
                onActiveChannelChanged: {
                    isBlocked = profileModel.contacts.isContactBlocked(activeChatId);
                    chatInput.suggestions.hide();
                    chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
                    populateSuggestions();
                }
            }

            Connections {
                target: chatsModel.messageView
                onMessagePushed: {
                    addSuggestionFromMessageList(messageIndex);
                }
            }

            Connections {
                target: profileModel
                onContactsChanged: {
                    populateSuggestions();
                }
            }

            ChatRequestMessage {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                Layout.bottomMargin: Style.current.bigPadding
            }

            Item {
                id: inputArea
                Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
                Layout.fillWidth: true
                Layout.preferredWidth: parent.width
                height: chatInput.height
                Layout.preferredHeight: height

                Connections {
                    target: chatsModel.messageView
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
                    active: chatsModel.messageView.loadingMessages
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
                        if (chatsModel.channelView.activeChannel.chatType === Constants.chatTypePrivateGroupChat) {
                            return chatsModel.channelView.activeChannel.isMember
                        }
                        if (chatsModel.channelView.activeChannel.chatType === Constants.chatTypeOneToOne) {
                            return isContact
                        }
                        const community = chatsModel.communities.activeCommunity
                        return !community.active ||
                                community.access === Constants.communityChatPublicAccess ||
                                community.admin ||
                                chatsModel.channelView.activeChannel.canPost
                    }
                    isContactBlocked: isBlocked
                    chatInputPlaceholder: isBlocked ?
                                              //% "This user has been blocked."
                                              qsTrId("this-user-has-been-blocked-") :
                                              //% "Type a message."
                                              qsTrId("type-a-message-")
                    anchors.bottom: parent.bottom
                    recentStickers: chatsModel.stickers.recent
                    stickerPackList: chatsModel.stickers.stickerPacks
                    chatType: chatsModel.channelView.activeChannel.chatType
                    onSendTransactionCommandButtonClicked: {
                        if (chatsModel.channelView.activeChannel.ensVerified) {
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
                        chatsModel.stickers.send(hashId, chatInput.isReply ? SelectedMessage.messageId : "", packId)
                    }
                    onSendMessage: {
                        if (chatInput.fileUrls.length > 0){
                            chatsModel.sendImages(JSON.stringify(fileUrls));
                        }
                        let msg = chatsModel.plainText(Emoji.deparse(chatInput.textInput.text))
                        if (msg.length > 0){
                            msg = chatInput.interpretMessage(msg)
                            chatsModel.messageView.sendMessage(msg, chatInput.isReply ? SelectedMessage.messageId : "", Utils.isOnlyEmoji(msg) ? Constants.emojiType : Constants.messageType, false, JSON.stringify(suggestionsObj));
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
        }

        EmptyChat { }

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
                onClosed: {
                    txModalLoader.closed()
                }
                sendChatCommand: chatColumnLayout.requestAddressForTransaction
                isRequested: false
                //% "Send"
                commandTitle: qsTrId("command-button-send")
                title: commandTitle
                //% "Request Address"
                finalButtonLabel: qsTrId("request-address")
                selectRecipient.selectedRecipient: {
                    return {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        alias: chatsModel.channelView.activeChannel.alias,
                        identicon: chatsModel.channelView.activeChannel.identicon,
                        name: chatsModel.channelView.activeChannel.name,
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
                onClosed: {
                    txModalLoader.closed()
                }
                sendChatCommand: chatColumnLayout.requestTransaction
                isRequested: true
                //% "Request"
                commandTitle: qsTrId("wallet-request")
                title: commandTitle
                //% "Request"
                finalButtonLabel: qsTrId("wallet-request")
                selectRecipient.selectedRecipient: {
                    return {
                        address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                        alias: chatsModel.channelView.activeChannel.alias,
                        identicon: chatsModel.channelView.activeChannel.identicon,
                        name: chatsModel.channelView.activeChannel.name,
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
                    walletModel.gasView.getGasPricePredictions()
                }
                onClosed: {
                    txModalLoader.closed()
                }
                selectRecipient.readOnly: true
                selectRecipient.selectedRecipient: {
                    return {
                        address: "",
                        alias: chatsModel.channelView.activeChannel.alias,
                        identicon: chatsModel.channelView.activeChannel.identicon,
                        name: chatsModel.channelView.activeChannel.name,
                        type: RecipientSelector.Type.Contact,
                        ensVerified: true
                    }
                }
                selectRecipient.selectedType: RecipientSelector.Type.Contact
            }
        }

        ActivityCenter {
            id: activityCenter
            height: chatColumnLayout.height - (topBar.height * 2) // TODO get screen size
            y: topBar.height
        }

        Connections {
            target: profileModel.contacts
            onContactListChanged: {
                isBlocked = profileModel.contacts.isContactBlocked(activeChatId);
            }
            onContactBlocked: {
                chatsModel.messageView.removeMessagesByUserId(publicKey)
            }
        }

        Connections {
            target: chatsModel.channelView
            onActiveChannelChanged: {
                chatsModel.messageView.hideLoadingIndicator()
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
                onClosed: destroy()
            }
        }

        Connections {
            target: chatsModel.messageView

            onSearchedMessageLoaded: {
                positionAtMessage(messageId)
            }

            onMessageNotificationPushed: function(chatId, msg, contentType, chatType, timestamp, identicon, username, hasMention, isAddedContact, channelName) {
                if (appSettings.notificationSetting == Constants.notifyAllMessages ||
                        (appSettings.notificationSetting == Constants.notifyJustMentions && hasMention)) {
                    if (chatId === chatsModel.channelView.activeChannel.id && applicationWindow.active === true) {
                        // Do not show the notif if we are in the channel already and the window is active and focused
                        return
                    }

                    chatColumnLayout.currentNotificationChatId = chatId
                    chatColumnLayout.currentNotificationCommunityId = null

                    let name;
                    if (appSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous) {
                        name = "Status"
                    } else if (chatType === Constants.chatTypePublic) {
                        name = chatId
                    } else {
                        name = chatType === Constants.chatTypePrivateGroupChat ? Utils.filterXSS(channelName) : Utils.removeStatusEns(username)
                    }

                    let message;
                    if (appSettings.notificationMessagePreviewSetting > Constants.notificationPreviewNameOnly) {
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
                    if (appSettings.useOSNotifications && systemTray.supportsMessages) {
                        systemTray.showMessage(name,
                                               message,
                                               SystemTrayIcon.NoIcon,
                                               Constants.notificationPopupTTL)
                    } else {
                        notificationWindow.notifyUser(chatId, name, message, chatType, identicon, chatColumnLayout.clickOnNotification)
                    }
                }
            }
        }

        Component.onCompleted: {
            chatInput.textInput.forceActiveFocus(Qt.MouseFocusReason)
        }

        Connections {
            target: chatsModel.stickers
            onTransactionWasSent: {
                //% "Transaction pending"
                toastMessage.title = qsTrId("transaction-pending")
                toastMessage.source = "../../../img/loading.svg"
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
                    toastMessage.source = "../../../img/check-circle.svg"
                    toastMessage.iconColor = Style.current.success
                } else {
                    toastMessage.source = "../../../img/block-icon.svg"
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
