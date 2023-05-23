import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQml 2.14

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
    property var createChatPropertiesStore
    property var contactsStore
    property var emojiPopup
    property var stickersPopup

    property string activeChatId: parentModule && parentModule.activeItem.id
    property int chatsCount: parentModule && parentModule.model ? parentModule.model.count : 0
    property int activeChatType: parentModule && parentModule.activeItem.type
    property bool stickersLoaded: false

    readonly property var contactDetails: rootStore ? rootStore.oneToOneChatContact : null
    readonly property bool isUserAdded: root.contactDetails && root.contactDetails.isAdded

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
        if(root.createChatPropertiesStore.createChatStartSendTransactionProcess) {
            if (root.contactDetails.ensVerified) {
                Global.openPopup(cmpSendTransactionWithEns);
            } else {
                Global.openPopup(cmpSendTransactionNoEns);
            }
        }
        else if (root.createChatPropertiesStore.createChatStartSendTransactionProcess) {
            Global.openPopup(cmpReceiveTransaction);
        }
        else if (root.createChatPropertiesStore.createChatStickerHashId !== "" &&
                 root.createChatPropertiesStore.createChatStickerPackId !== "" &&
                 root.createChatPropertiesStore.createChatStickerUrl !== "") {
            root.rootStore.sendSticker(chatId,
                                       root.createChatPropertiesStore.createChatStickerHashId,
                                       "",
                                       root.createChatPropertiesStore.createChatStickerPackId,
                                       root.createChatPropertiesStore.createChatStickerUrl);
        }
        else if (root.createChatPropertiesStore.createChatInitMessage !== "" ||
                 root.createChatPropertiesStore.createChatFileUrls.length > 0) {

            root.rootStore.sendMessage(chatId,
                                       Qt.Key_Enter,
                                       root.createChatPropertiesStore.createChatInitMessage,
                                       "",
                                       root.createChatPropertiesStore.createChatFileUrls
                                       );
        }

        root.createChatPropertiesStore.resetProperties()
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

        ChatContentView {
            width: parent.width
            height: parent.height
            visible: !root.rootStore.openCreateChat && isActiveChannel
            chatId: model.itemId
            chatType: model.type
            chatMessagesLoader.active: model.loaderActive
            rootStore: root.rootStore
            contactsStore: root.contactsStore
            emojiPopup: root.emojiPopup
            stickersPopup: root.stickersPopup
            sendTransactionNoEnsModal: cmpSendTransactionNoEns
            receiveTransactionModal: cmpReceiveTransaction
            sendTransactionWithEnsModal: cmpSendTransactionWithEns
            stickersLoaded: root.stickersLoaded
            isBlocked: model.blocked
            isActiveChannel: model.active
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
            headerSettings.title: commandTitle
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
            headerSettings.title: commandTitle
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
}
