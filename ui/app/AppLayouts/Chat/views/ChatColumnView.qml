import QtQuick 2.13
import Qt.labs.platform 1.1
import QtQuick.Controls 2.13
import QtQuick.Layouts 1.13
import QtGraphicalEffects 1.0
import Qt.labs.qmlmodels 1.0

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

Item {
    id: root
    anchors.fill: parent

    // Important: we have parent module in this context only cause qml components
    // don't follow struct we have on the backend.
    property var parentModule

    property var rootStore
    property alias pinnedMessagesPopupComponent: pinnedMessagesPopupComponent
    // Not Refactored Yet
    //property int chatGroupsListViewCount: 0
    property bool isReply: false
    property bool isImage: false
    property bool isExtendedInput: isReply || isImage
    property bool isConnected: false
    property string contactToRemove: ""
    property string activeChatId: root.rootStore.chatsModelInst.channelView.activeChannel.id
    property bool isBlocked: root.rootStore.contactsModuleInst.model.isContactBlocked(activeChatId)
    property bool isContact: root.rootStore.isContactAdded(activeChatId)
//    property bool contactRequestReceived: root.rootStore.contactsModuleInst.model.contactRequestReceived(activeChatId)
    property string currentNotificationChatId
    property string currentNotificationCommunityId
    property var currentTime: 0
    property var idMap: ({})
    property Timer timer: Timer { }
    property var userList

    signal openAppSearch()

    // Not Refactored Yet
//    function hideChatInputExtendedArea () {
//        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
//            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.hideExtendedArea()
//    }

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

        // Not Refactored Yet
//        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
//            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.showReplyArea(userName, message, identicon, contentType, image, sticker)
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
        // Not Refactored Yet
//        stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].message.scrollToMessage(messageId, isSearch);
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

    StackLayout {
        anchors.fill: parent
        currentIndex: {
            if(chatCommunitySectionModule.activeItem.id !== "")
            {
                for(let i = 1; i < this.children.length; i++)
                {
                    var obj = this.children[i];
                    if(obj && obj.chatContentModule)
                    {
                        let myChatId = obj.chatContentModule.getMyChatId()
                        if(myChatId == parentModule.activeItem.id || myChatId == parentModule.activeItem.activeSubItem.id)
                            return i
                    }
                }

                // Should never be here, correct index must be returned from the `for` loop above
                console.error("Wrong chat/channel index, active item id: ", parentModule.activeItem.id,
                              " active subitem id: ", parentModule.activeItem.activeSubItem.id)
            }

            return 0
        }

        EmptyChatPanel {
            onShareChatKeyClicked: openProfilePopup(userProfile.name, userProfile.pubKey, userProfile.icon);
        }

        // This is kind of a solution for applying backend refactored changes with the minimal qml changes.
        // The best would be if we made qml to follow the struct we have on the backend side.
        Repeater {
            model: parentModule.model
            delegate: delegateChooser

            DelegateChooser {
                id: delegateChooser
                role: "type"
                DelegateChoice { // In case of category
                    roleValue: Constants.chatType.unknown
                    delegate: Repeater {
                        model: subItems
                        delegate: ChatContentView {
                            Component.onCompleted: {
                                parentModule.prepareChatContentModuleForChatId(model.itemId)
                                chatContentModule = parentModule.getChatContentModule()
                            }
                        }
                    }
                }
                DelegateChoice { // In all other cases
                    delegate: ChatContentView {
                        Component.onCompleted: {
                            parentModule.prepareChatContentModuleForChatId(itemId)
                            chatContentModule = parentModule.getChatContentModule()
                        }
                    }
                }
            }
        }
    }

    ChatRequestMessagePanel {
        Layout.alignment: Qt.AlignHCenter | Qt.AlignBottom
        Layout.fillWidth: true
        Layout.bottomMargin: Style.current.bigPadding
        isContact: root.isContact
        visible: root.rootStore.chatsModelInst.channelView.activeChannel.chatType === Constants.chatType.oneToOne
            && (!root.isContact /*|| !contactRequestReceived*/)
        onAddContactClicked: {
            root.rootStore.addContact(activeChatId);
        }
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
            height: root.height - 56 * 2 // TODO get screen size // Taken from old code top bar height was fixed there to 56
            y: 56
            store: root.rootStore
        }

        Connections {
            target: root.rootStore.contactsModuleInst.model
            onContactListChanged: {
                root.isBlocked = root.rootStore.contactsModuleInst.model.isContactBlocked(activeChatId);
                root.isContact = root.rootStore.contactsModuleInst.model.isAdded(activeChatId);
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
                    } else if (chatType === Constants.chatType.publicChat) {
                        name = chatId
                    } else {
                        name = chatType === Constants.chatType.privateGroupChat ? Utils.filterXSS(channelName) : Utils.removeStatusEns(username)
                    }

                    let message;
                    if (localAccountSensitiveSettings.notificationMessagePreviewSetting > Constants.notificationPreviewNameOnly) {
                        switch(contentType){
                            //% "Image"
                        case Constants.messageContentType.imageType: message = qsTrId("image"); break
                            //% "Sticker"
                        case Constants.messageContentType.stickerType: message = qsTrId("sticker"); break
                        default: message = msg // don't parse emojis here as it emits HTML
                        }
                    } else {
                        //% "You have a new message"
                        message = qsTrId("you-have-a-new-message")
                    }

                    currentlyHasANotification = true

                    if (Qt.platform.os === "linux") {
                        // Linux Notifications are not implemented in Nim/C++ yet
                        return systemTray.showMessage(name, message, systemTray.icon.source, 4000)
                    }

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
