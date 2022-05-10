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
    property var emojiPopup

    // Not Refactored Yet
    //property int chatGroupsListViewCount: 0
    property bool isReply: false
    property bool isImage: false
    property bool isExtendedInput: isReply || isImage
    property bool isConnected: false
    property string contactToRemove: ""
    property bool isSectionActive: mainModule.activeSection.id === parentModule.getMySectionId()
    property string activeChatId: parentModule && parentModule.activeItem.id
    property string activeSubItemId: parentModule && parentModule.activeItem.activeSubItem.id
    property int chatsCount: parentModule && parentModule.model ? parentModule.model.count : 0
    property string activeChatType: parentModule && parentModule.activeItem.type
    property string currentNotificationChatId
    property string currentNotificationCommunityId
    property var currentTime: 0
    property var idMap: ({})
    property bool stickersLoaded: false
    property Timer timer: Timer { }
    property var userList
    property var contactDetails: Utils.getContactDetailsAsJson(root.activeChatId)
    property bool isUserAdded: root.contactDetails.isAdded
    property bool contactRequestReceived: root.contactDetails.requestReceived
    property Component pinnedMessagesListPopupComponent

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
    }
    function requestTransaction(address, amount, tokenAddress, tokenDecimals = 18) {
        amount = globalUtils.eth2Wei(amount.toString(), tokenDecimals)


        parentModule.prepareChatContentModuleForChatId(activeChatId)
        let chatContentModule = parentModule.getChatContentModule()
        chatContentModule.inputAreaModule.request(address,
                                                    amount,
                                                    tokenAddress)
    }

    // This function is called once `1:1` or `group` chat is created.
    function checkForCreateChatOptions(chatId) {
        if(root.rootStore.createChatStartSendTransactionProcess) {
            if (Utils.getContactDetailsAsJson(chatId).ensVerified) {
                Global.openPopup(cmpSendTransactionWithEns);
            } else {
                Global.openPopup(cmpSendTransactionNoEns);
            }
        }
        else if (root.rootStore.createChatStartSendTransactionProcess) {
            Global.openPopup(cmpReceiveTransaction);
        }
        else if (root.rootStore.createChatStickerHashId !== "" &&
                 root.rootStore.createChatStickerPackId !== "") {
            root.rootStore.sendSticker(chatId,
                                       root.rootStore.createChatStickerHashId,
                                       "",
                                       root.rootStore.createChatStickerPackId);
        }
        else if (root.rootStore.createChatInitMessage !== "" ||
                 root.rootStore.createChatFileUrls.length > 0) {

            root.rootStore.sendMessage(Qt.Key_Enter,
                                       root.rootStore.createChatInitMessage,
                                       "",
                                       root.rootStore.createChatFileUrls
                                       );
        }

        // Clear.
        root.rootStore.createChatInitMessage = "";
        root.rootStore.createChatFileUrls = [];
        root.rootStore.createChatStartSendTransactionProcess = false;
        root.rootStore.createChatStartReceiveTransactionProcess = false;
        root.rootStore.createChatStickerHashId = "";
        root.rootStore.createChatStickerPackId = "";
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
        visible: root.activeChatId === "" || root.chatsCount == 0
        rootStore: root.rootStore
        onShareChatKeyClicked: Global.openProfilePopup(userProfile.pubKey);
    }

    // This is kind of a solution for applying backend refactored changes with the minimal qml changes.
    // The best would be if we made qml to follow the struct we have on the backend side.
    Repeater {
        id: chatRepeater
        model: parentModule && parentModule.model
        delegate: delegateChooser

        function isChatActive(myChatId) {
            if(!myChatId || !root.isSectionActive)
                return false

            if(myChatId === root.activeChatId || myChatId === root.activeSubItemId)
                return true

            return false
        }

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
                    delegate: Loader {
                        property bool isActiveChannel: chatRepeater.isChatActive(model.itemId)

                        id: categoryChatLoader
                        // Channels are not loaded by default and only load when first put active
                        active: false
                        width: parent.width
                        height: isActiveChannel ? parent.height : 0

                        Connections {
                            id: loaderConnections
                            target: categoryChatLoader
                            // First time this channel turns active, activate the Loader
                            onIsActiveChannelChanged: {
                                if (categoryChatLoader.isActiveChannel) {
                                    categoryChatLoader.active = true
                                    loaderConnections.enabled = false
                                }
                            }
                        }

                        sourceComponent: ChatContentView {
                            visible: !root.rootStore.openCreateChat
                            width: parent.width
                            height: parent.height
                            clip: true
                            rootStore: root.rootStore
                            contactsStore: root.contactsStore
                            emojiPopup: root.emojiPopup
                            isConnected: root.isConnected
                            sendTransactionNoEnsModal: cmpSendTransactionNoEns
                            receiveTransactionModal: cmpReceiveTransaction
                            sendTransactionWithEnsModal: cmpSendTransactionWithEns
                            stickersLoaded: root.stickersLoaded
                            isBlocked: model.blocked
                            isActiveChannel: categoryChatLoader.isActiveChannel
                            activityCenterVisible: activityCenter.visible
                            activityCenterNotificationsCount: activityCenter.unreadNotificationsCount
                            pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
                            onOpenStickerPackPopup: {
                                root.openStickerPackPopup(stickerPackId)
                            }
                            onNotificationButtonClicked: {
                                activityCenter.open();
                            }
                            onOpenAppSearch: {
                                root.openAppSearch();
                            }
                            Component.onCompleted: {
                                parentModule.prepareChatContentModuleForChatId(model.itemId)
                                chatContentModule = parentModule.getChatContentModule()
                                chatSectionModule = root.chatSectionModule;
                            }
                        }
                    }
                }
            }
            DelegateChoice { // In all other cases
                delegate: Loader {
                    property bool isActiveChannel: chatRepeater.isChatActive(model.itemId)

                    id: chatLoader
                    // Channels are not loaded by default and only load when first put active
                    active: false
                    width: parent.width
                    height: isActiveChannel ? parent.height : 0
                    Connections {
                        id: loaderConnections
                        target: chatLoader
                        // First time this channel turns active, activate the Loader
                        onIsActiveChannelChanged: {
                            if (chatLoader.isActiveChannel) {
                                chatLoader.active = true
                                loaderConnections.enabled = false
                            }
                        }
                    }

                    sourceComponent: ChatContentView {
                        visible: !root.rootStore.openCreateChat
                        width: parent.width
                        height: parent.height
                        clip: true
                        rootStore: root.rootStore
                        contactsStore: root.contactsStore
                        isConnected: root.isConnected
                        emojiPopup: root.emojiPopup
                        sendTransactionNoEnsModal: cmpSendTransactionNoEns
                        receiveTransactionModal: cmpReceiveTransaction
                        sendTransactionWithEnsModal: cmpSendTransactionWithEns
                        stickersLoaded: root.stickersLoaded
                        isBlocked: model.blocked
                        isActiveChannel: chatLoader.isActiveChannel
                        activityCenterVisible: activityCenter.visible
                        activityCenterNotificationsCount: activityCenter.unreadNotificationsCount
                        pinnedMessagesPopupComponent: root.pinnedMessagesListPopupComponent
                        onOpenStickerPackPopup: {
                            root.openStickerPackPopup(stickerPackId)
                        }
                        onNotificationButtonClicked: {
                            activityCenter.open();
                        }
                        onOpenAppSearch: {
                            root.openAppSearch();
                        }
                        Component.onCompleted: {
                            parentModule.prepareChatContentModuleForChatId(model.itemId)
                            chatContentModule = parentModule.getChatContentModule()
                            chatSectionModule = root.chatSectionModule;
                            root.checkForCreateChatOptions(model.itemId)
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
        isUserAdded: root.isUserAdded
        visible: root.activeChatType === Constants.chatType.oneToOne && !root.isUserAdded
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
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestAddressForTransaction
            isRequested: false
            commandTitle: qsTr("Send")
            header.title: commandTitle
            finalButtonLabel: qsTr("Request Address")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    pubKey: chatContentModule.chatDetails.id,
                    icon: chatContentModule.chatDetails.icon,
                    name: chatContentModule.chatDetails.name,
                    type: RecipientSelector.Type.Contact,
                    ensVerified: true
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
            onClosed: {
                destroy()
            }
            sendChatCommand: root.requestTransaction
            isRequested: true
            commandTitle: qsTr("Request")
            header.title: commandTitle
            finalButtonLabel: qsTr("Request")
            selectRecipient.selectedRecipient: {
                parentModule.prepareChatContentModuleForChatId(activeChatId)
                let chatContentModule = parentModule.getChatContentModule()
                return {
                    address: Constants.zeroAddress, // Setting as zero address since we don't have the address yet
                    alias: chatContentModule.chatDetails.name, // Do we need the alias for real or name works?
                    pubKey: chatContentModule.chatDetails.id,
                    icon: chatContentModule.chatDetails.icon,
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
            anchors.centerIn: parent
            store: root.rootStore
            contactsStore: root.contactsStore
            onClosed: {
                destroy()
            }
            launchedFromChat: true
            preSelectedRecipient: {
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
        }
    }

    ActivityCenterPopup {
        id: activityCenter
        height: root.height - 56 * 2 // TODO get screen size // Taken from old code top bar height was fixed there to 56
        y: 56
        store: root.rootStore
        chatSectionModule: root.parentModule
        messageContextMenu: contextmenu
    }

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
//                                     qsTr("Could not buy Stickerpack")
//                                     :
//                                     qsTr("Stickerpack bought successfully");
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
