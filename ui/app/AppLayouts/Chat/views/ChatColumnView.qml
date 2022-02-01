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
    property var contactsStore
    property var chatSectionModule

    property Component pinnedMessagesPopupComponent
    // Not Refactored Yet
    //property int chatGroupsListViewCount: 0
    property bool isReply: false
    property bool isImage: false
    property bool isExtendedInput: isReply || isImage
    property bool isConnected: false
    property string contactToRemove: ""
    property string activeChatId: parentModule && parentModule.activeItem.id
    property string activeSubItemId: parentModule && parentModule.activeItem.activeSubItem.id
    property string activeChatType: parentModule && parentModule.activeItem.type
    property string currentNotificationChatId
    property string currentNotificationCommunityId
    property var currentTime: 0
    property var idMap: ({})
    property bool stickersLoaded: false
    property Timer timer: Timer { }
    property var userList

    property var contactDetails: Utils.getContactDetailsAsJson(root.activeChatId)
    property bool isBlocked: root.contactDetails.isBlocked
    property bool isContact: root.contactDetails.isContact
    property bool contactRequestReceived: root.contactDetails.requestReceived

    signal openAppSearch()
    signal openStickerPackPopup(string stickerPackId)

    // Not Refactored Yet
//    function hideChatInputExtendedArea () {
//        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
//            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.hideExtendedArea()
//    }

    function showReplyArea() {
        isReply = true;
        isImage = false;
        // Not Refactored Yet
//        let replyMessageIndex = root.rootStore.chatsModelInst.messageView.messageList.getMessageIndex(SelectedMessage.messageId);
//        if (replyMessageIndex === -1) return;
//        let userName = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "userName")
//        let message = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "message")
//        let identicon = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "identicon")
//        let image = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "image")
//        let sticker = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "sticker")
//        let contentType = root.rootStore.chatsModelInst.messageView.messageList.getMessageData(replyMessageIndex, "contentType")

        // Not Refactored Yet
//        if(stackLayoutChatMessages.currentIndex >= 0 && stackLayoutChatMessages.currentIndex < stackLayoutChatMessages.children.length)
//            stackLayoutChatMessages.children[stackLayoutChatMessages.currentIndex].chatInput.showReplyArea(userName, message, identicon, contentType, image, sticker)
    }

    function requestAddressForTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount =  globalUtils.eth2Wei(amount.toString(), tokenDecimals)

        parentModule.prepareChatContentModuleForChatId(activeChatId)
        let chatContentModule = parentModule.getChatContentModule()
        chatContentModule.inputAreaModule.requestAddress(address,
                                                    amount,
                                                    tokenAddress)
        txModalLoader.close()
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount = globalUtils.eth2Wei(amount.toString(), tokenDecimals)


        parentModule.prepareChatContentModuleForChatId(activeChatId)
        let chatContentModule = parentModule.getChatContentModule()
        chatContentModule.inputAreaModule.request(address,
                                                    amount,
                                                    tokenAddress)
    }

    function clickOnNotification() {
        // So far we're just showing this app as the top most window. Once we decide about the way
        // how to notify the app what channle should be displayed within the app when user clicks
        // notificaiton bubble this part should be updated accordingly.
        //
        // I removed part of this function which caused app crash.
        Global.applicationWindow.show()
        Global.applicationWindow.raise()
        Global.applicationWindow.requestActivate()
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
    
    EmptyChatPanel {
        anchors.fill: parent
        visible: root.activeChatId === ""
        rootStore: root.rootStore
        onShareChatKeyClicked: Global.openProfilePopup(userProfile.pubKey);
    }

    // This is kind of a solution for applying backend refactored changes with the minimal qml changes.
    // The best would be if we made qml to follow the struct we have on the backend side.
    Repeater {
        model: parentModule && parentModule.model
        delegate: delegateChooser

        DelegateChooser {
            id: delegateChooser
            role: "type"
            DelegateChoice { // In case of category
                roleValue: Constants.chatType.unknown
                delegate: Repeater {
                    model: {
                        if (!subItems) {
                            console.error("We got a category with no subitems. It is possible that the channel had a type unknown")
                        }
                        return subItems
                    }
                    delegate: ChatContentView {
                        width: parent.width
                        clip: true
                        height: {
                            // dynamically calculate the height of the view, if the active one is the current one
                            // then set the height to parent otherwise set it to 0
                            if(!chatContentModule)
                                return 0

                            let myChatId = chatContentModule.getMyChatId()
                            if(myChatId === root.activeChatId || myChatId === root.activeSubItemId)
                                return parent.height

                            return 0
                        }
                        rootStore: root.rootStore
                        contactsStore: root.contactsStore
                        sendTransactionNoEnsModal: cmpSendTransactionNoEns
                        receiveTransactionModal: cmpReceiveTransaction
                        sendTransactionWithEnsModal: cmpSendTransactionWithEns
                        stickersLoaded: root.stickersLoaded
                        Component.onCompleted: {
                            parentModule.prepareChatContentModuleForChatId(model.itemId)
                            chatContentModule = parentModule.getChatContentModule()
                        }
                    }
                }
            }
            DelegateChoice { // In all other cases
                delegate: ChatContentView {
                    width: parent.width
                    clip: true
                    height: {
                        // dynamically calculate the height of the view, if the active one is the current one
                        // then set the height to parent otherwise set it to 0
                        if(!chatContentModule)
                            return 0

                        let myChatId = chatContentModule.getMyChatId()
                        if(myChatId === root.activeChatId || myChatId === root.activeSubItemId)
                            return parent.height

                        return 0
                    }    
                    rootStore: root.rootStore
                    contactsStore: root.contactsStore
                    sendTransactionNoEnsModal: cmpSendTransactionNoEns
                    receiveTransactionModal: cmpReceiveTransaction
                    sendTransactionWithEnsModal: cmpSendTransactionWithEns
                    stickersLoaded: root.stickersLoaded
                    Component.onCompleted: {
                        parentModule.prepareChatContentModuleForChatId(itemId)
                        chatContentModule = parentModule.getChatContentModule()
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
        visible: root.activeChatType === Constants.chatType.oneToOne && (!root.isContact /*|| !contactRequestReceived*/)
        onAddContactClicked: {
            root.rootStore.addContact(root.activeChatId);
        }
    }

    Component {
        id: cmpSendTransactionNoEns
        ChatCommandModal {
            id: sendTransactionNoEns
            store: root.rootStore
            contactsStore: root.contactsStore
            isContact: root.isContact
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestAddressForTransaction
            isRequested: false
            //% "Send"
            commandTitle: qsTrId("command-button-send")
            header.title: commandTitle
            //% "Request Address"
            finalButtonLabel: qsTrId("request-address")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    identicon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
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
            contactsStore: root.contactsStore
            isContact: root.isContact
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestTransaction
            isRequested: true
            //% "Request"
            commandTitle: qsTrId("wallet-request")
            header.title: commandTitle
            //% "Request"
            finalButtonLabel: qsTrId("wallet-request")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    identicon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
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
            store: root.rootStore
            contactsStore: root.contactsStore
            onOpened: {
                // Not Refactored Yet
//                    root.rootStore.walletModelInst.gasView.getGasPrice()
            }
            onClosed: {
                destroy()
            }
            isContact: root.isContact
            selectRecipient.readOnly: true
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()

                return {
                    address: "",
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    identicon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
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
        chatSectionModule: root.chatSectionModule
        messageContextMenu: contextmenu
    }

    Connections {
        target: systemTray
        onMessageClicked: function () {
            clickOnNotification()
        }
    }

        // Not Refactored Yet
//        Connections {
//            target: root.rootStore.chatsModelInst.messageView

//            onMessageNotificationPushed: function(messageId, communityId, chatId, msg, contentType, chatType, timestamp, identicon, username, hasMention, isAddedContact, channelName) {
//                if (localAccountSensitiveSettings.notificationSetting == Constants.notifyAllMessages ||
//                        (localAccountSensitiveSettings.notificationSetting == Constants.notifyJustMentions && hasMention)) {
//                    if (chatId === root.rootStore.chatsModelInst.channelView.activeChannel.id && applicationWindow.active === true) {
//                        // Do not show the notif if we are in the channel already and the window is active and focused
//                        return
//                    }

//                    root.currentNotificationChatId = chatId
//                    root.currentNotificationCommunityId = null

//                    let name;
//                    if (localAccountSensitiveSettings.notificationMessagePreviewSetting === Constants.notificationPreviewAnonymous) {
//                        name = "Status"
//                    } else if (chatType === Constants.chatType.publicChat) {
//                        name = chatId
//                    } else {
//                        name = chatType === Constants.chatType.privateGroupChat ? Utils.filterXSS(channelName) : Utils.removeStatusEns(username)
//                    }

//                    let message;
//                    if (localAccountSensitiveSettings.notificationMessagePreviewSetting > Constants.notificationPreviewNameOnly) {
//                        switch(contentType){
//                            //% "Image"
//                        case Constants.messageContentType.imageType: message = qsTrId("image"); break
//                            //% "Sticker"
//                        case Constants.messageContentType.stickerType: message = qsTrId("sticker"); break
//                        default: message = msg // don't parse emojis here as it emits HTML
//                        }
//                    } else {
//                        //% "You have a new message"
//                        message = qsTrId("you-have-a-new-message")
//                    }

//                    currentlyHasANotification = true

//                    if (Qt.platform.os === "linux") {
//                        // Linux Notifications are not implemented in Nim/C++ yet
//                        return systemTray.showMessage(name, message, systemTray.icon.source, 4000)
//                    }

//                    // Note:
//                    // Show notification should be moved to the nim side.
//                    // Left here only cause we don't have a way to deal with translations on the nim side.
//                    root.rootStore.chatsModelInst.showOSNotification(name,
//                                                  message,
//                                                  Constants.osNotificationType.newMessage,
//                                                  communityId,
//                                                  chatId,
//                                                  messageId,
//                                                  localAccountSensitiveSettings.useOSNotifications)
//                }
//            }
//        }

        // Not Refactored Yet
//        Connections {
//            target: root.rootStore.chatsModelInst.stickers
//            onTransactionWasSent: {
//                //% "Transaction pending..."
//                toastMessage.title = qsTr("Transaction pending...")
//                toastMessage.source = Style.svg("loading")
//                toastMessage.iconColor = Style.current.primary
//                toastMessage.iconRotates = true
//                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txResult}`
//                toastMessage.open()
//            }
//            onTransactionCompleted: {
//                toastMessage.title = !success ?
//                                     //% "Could not buy Stickerpack"
//                                     qsTrId("could-not-buy-stickerpack")
//                                     :
//                                     //% "Stickerpack bought successfully"
//                                     qsTrId("stickerpack-bought-successfully");
//                if (success) {
//                    toastMessage.source = Style.svg("check-circle")
//                    toastMessage.iconColor = Style.current.success
//                } else {
//                    toastMessage.source = Style.svg("block-icon")
//                    toastMessage.iconColor = Style.current.danger
//                }

//                toastMessage.link = `${walletModel.utilsView.etherscanLink}/${txHash}`
//                toastMessage.open()
//            }
//        }
}
