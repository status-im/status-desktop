import QtQuick 2.14
import Qt.labs.platform 1.1
import QtQuick.Controls 2.14
import QtQuick.Layouts 1.14
import QtGraphicalEffects 1.0
import QtQml 2.14
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

    // Important: we have parent module in this context only cause qml components
    // don't follow struct we have on the backend.
    property var parentModule

    property var rootStore
    property var contactsStore
    property var emojiPopup
    property var stickersPopup

    property bool isSectionActive: mainModule.activeSection.id === parentModule.getMySectionId()
    property string activeChatId: parentModule && parentModule.activeItem.id
    property int chatsCount: parentModule && parentModule.model ? parentModule.model.count : 0
    property int activeChatType: parentModule && parentModule.activeItem.type
    property bool stickersLoaded: false
    property var contactDetails: activeChatType === Constants.chatType.oneToOne && Utils.getContactDetailsAsJson(root.activeChatId, false)
    property bool isUserAdded: root.contactDetails && root.contactDetails.isAdded

    signal openAppSearch()
    signal openStickerPackPopup(string stickerPackId)

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
            if (root.contactDetails.ensVerified) {
                Global.openPopup(cmpSendTransactionWithEns);
            } else {
                Global.openPopup(cmpSendTransactionNoEns);
            }
        }
        else if (root.rootStore.createChatStartSendTransactionProcess) {
            Global.openPopup(cmpReceiveTransaction);
        }
        else if (root.rootStore.createChatStickerHashId !== "" &&
                 root.rootStore.createChatStickerPackId !== "" &&
                 root.rootStore.createChatStickerUrl !== "") {
            root.rootStore.sendSticker(chatId,
                                       root.rootStore.createChatStickerHashId,
                                       "",
                                       root.rootStore.createChatStickerPackId,
                                       root.rootStore.createChatStickerUrl);
        }
        else if (root.rootStore.createChatInitMessage !== "" ||
                 root.rootStore.createChatFileUrls.length > 0) {

            root.rootStore.sendMessage(chatId,
                                       Qt.Key_Enter,
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

        delegate: Loader {
            id: chatLoader

            // Channels/chats are not loaded by default and only load when first put active
            active: false
            width: parent.width
            height: parent.height
            visible: model.active

            // Removing the binding in order not to unload the content:
            // It is done for keeping:
            //   - the last channel/chat scroll position
            //   - the last typed but not sent text
            Binding on active {
                when: !chatLoader.active
                restoreMode: Binding.RestoreNone
                value: model.itemId && root.isSectionActive && (model.itemId === root.activeChatId || model.itemId === root.activeSubItemId)
            }

            sourceComponent: ChatContentView {
                visible: !root.rootStore.openCreateChat && isActiveChannel
                rootStore: root.rootStore
                contactsStore: root.contactsStore
                emojiPopup: root.emojiPopup
                stickersPopup: root.stickersPopup
                sendTransactionNoEnsModal: cmpSendTransactionNoEns
                receiveTransactionModal: cmpReceiveTransaction
                sendTransactionWithEnsModal: cmpSendTransactionWithEns
                stickersLoaded: root.stickersLoaded
                isBlocked: model.blocked
                isActiveChannel: chatLoader.visible
                onOpenStickerPackPopup: {
                    root.openStickerPackPopup(stickerPackId)
                }
                onOpenAppSearch: {
                    root.openAppSearch();
                }
                Component.onCompleted: {
                    parentModule.prepareChatContentModuleForChatId(model.itemId)
                    chatContentModule = parentModule.getChatContentModule()
                    chatSectionModule = root.parentModule
                    root.checkForCreateChatOptions(model.itemId)
                }
            }
        }
    }

    ChatRequestMessagePanel {
        anchors.fill: parent
        anchors.bottomMargin: Style.current.bigPadding
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
            onClosed: {
                destroy()
            }
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
