import QtQuick 2.15
import QtQml 2.15

import SortFilterProxyModel 0.2

import StatusQ 0.1
import StatusQ.Core.Utils 0.1 as StatusQUtils
import StatusQ.Core.Theme 0.1

import AppLayouts.Profile.stores 1.0
import AppLayouts.Wallet.stores 1.0 as WalletStore
import shared.stores 1.0

import utils 1.0

// TO REVIEW NAMING: It was the `Chat` before
QtObject {
    id: root

    readonly property MessageStore messageStore: MessageStore {}

    property bool openCreateChat: false

    // Important:
    // Each `ChatLayout` has its own chatCommunitySectionModule
    // (on the backend chat and community sections share the same module since they are actually the same)
    property var chatCommunitySectionModule

    readonly property var sectionDetails: d.sectionDetailsInstantiator.count ? d.sectionDetailsInstantiator.objectAt(0) : null

    readonly property string overviewChartData: chatCommunitySectionModule.overviewChartData

    readonly property bool isUserAllowedToSendMessage: d.isUserAllowedToSendMessage

    readonly property string chatInputPlaceHolderText: d.chatInputPlaceHolderText

    readonly property var oneToOneChatContact: d.oneToOneChatContact

    // TO REVIEW: This seems something from messageStore (indeed there's a similar property there)
    property bool loadingHistoryMessagesInProgress: chatCommunitySectionModule.loadingHistoryMessagesInProgress

    property var emojiReactionsModel

    property ListModel addToGroupContacts: ListModel {}

    property string name: d.userProfileInst.name

    readonly property QtObject _d: StatusQUtils.QObject {
        id: d

        readonly property var userProfileInst: userProfile
        readonly property string activeChatId: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.id : ""
        readonly property int activeChatType: chatCommunitySectionModule && chatCommunitySectionModule.activeItem ? chatCommunitySectionModule.activeItem.type : -1
        readonly property bool amIMember: chatCommunitySectionModule ? chatCommunitySectionModule.amIMember : false

        property var oneToOneChatContact: undefined
        readonly property string oneToOneChatContactName: !!d.oneToOneChatContact ? ProfileUtils.displayName(d.oneToOneChatContact.localNickname,
                                                                                                    d.oneToOneChatContact.name,
                                                                                                    d.oneToOneChatContact.displayName,
                                                                                                    d.oneToOneChatContact.alias) : ""

        StatusQUtils.ModelEntryChangeTracker {
            model: root.contactsStore.contactsModel //** TO REVIEW
            role: "pubKey"
            key: d.activeChatId

            onItemChanged: d.oneToOneChatContact = Utils.getContactDetailsAsJson(d.activeChatId, false)
        }

        readonly property bool isUserAllowedToSendMessage: {
            if (d.activeChatType === Constants.chatType.oneToOne && d.oneToOneChatContact) {
                return d.oneToOneChatContact.contactRequestState === Constants.ContactRequestState.Mutual
            } else if (d.activeChatType === Constants.chatType.privateGroupChat) {
                return d.amIMember
            } else if (d.activeChatType === Constants.chatType.communityChat) {
                return currentChatContentModule().chatDetails.canPost
            }

            return true
        }

        readonly property string chatInputPlaceHolderText: {
            if(!d.isUserAllowedToSendMessage && d.activeChatType === Constants.chatType.privateGroupChat) {
                return qsTr("You need to be a member of this group to send messages")
            } else if(!d.isUserAllowedToSendMessage && d.activeChatType === Constants.chatType.oneToOne) {
                return qsTr("Add %1 as a contact to send a message").arg(d.oneToOneChatContactName)
            }

            return qsTr("Message")
        }

        // Update oneToOneChatContact when activeChat id changes
        Binding on oneToOneChatContact {
            when: d.activeChatId && d.activeChatType === Constants.chatType.oneToOne
            value: Utils.getContactDetailsAsJson(d.activeChatId, false)
            restoreMode: Binding.RestoreBindingOrValue
        }
    }

    // Since qml component doesn't follow encaptulation from the backend side, we're introducing
    // a method which will return appropriate chat content module for selected chat/channel
    function currentChatContentModule() {
        // When we decide to have the same struct as it's on the backend we will remove this function.
        // So far this is a way to deal with refactored backend from the current qml structure.
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatCommunitySectionModule.activeItem.id)
        return chatCommunitySectionModule.getChatContentModule()
    }

    function activateStatusDeepLink(link) {
        mainModuleInst.activateStatusDeepLink(link)
    }

    function getMySectionId() {
        return chatCommunitySectionModule.getMySectionId()
    }

    function amIChatAdmin() {
        return currentChatContentModule().amIChatAdmin()
    }

    function interpretMessage(msg) {
        if (msg.startsWith("/shrug")) {
            return  msg.replace("/shrug", "") + " ¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg.startsWith("/tableflip")) {
            return msg.replace("/tableflip", "") + " (╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function cleanMessageText(formattedMessage) {
        const text = StatusQUtils.StringUtils.plainText(StatusQUtils.Emoji.deparse(formattedMessage))
        return interpretMessage(text)
    }

    function sendMessage(chatId, event, text, replyMessageId, fileUrlsAndSources) {
        chatCommunitySectionModule.prepareChatContentModuleForChatId(chatId)
        const chatContentModule = chatCommunitySectionModule.getChatContentModule()
        var result = false

        const textMsg = cleanMessageText(text)
        if (textMsg.trim() !== "") {
            if (event)
                event.accepted = true
        }

        if (fileUrlsAndSources.length > 0) {
            const convertedImagePaths = UrlUtils.convertUrlsToLocalPaths(fileUrlsAndSources)
            chatContentModule.inputAreaModule.sendImages(JSON.stringify(convertedImagePaths), textMsg.trim(), replyMessageId)
            result = true
        } else {
            if (textMsg.trim() !== "") {
                chatContentModule.inputAreaModule.sendMessage(
                            textMsg,
                            replyMessageId,
                            Utils.isOnlyEmoji(textMsg) ? Constants.messageContentType.emojiType : Constants.messageContentType.messageType,
                            false)

                result = true
            }
        }

        return result
    }

    function openCloseCreateChatView() {
        if (root.openCreateChat) {
            Global.closeCreateChatView()
        } else {
            Global.openCreateChatView()
        }
    }

    function isCurrentUser(pubkey) {
        return d.userProfileInst.pubKey === pubkey
    }

    function displayName(name, pubkey) {
        return isCurrentUser(pubkey) ? qsTr("You") : name
    }

    function myPublicKey() {
        return d.userProfileInst.pubKey
    }

    function getChatDetails(id) {
        const jsonObj = activityCenterModule.getChatDetailsAsJson(id)
        try {
            return JSON.parse(jsonObj)
        }
        catch (e) {
            console.warn("error parsing chat by id: ", id, " error: ", e.message)
            return {}
        }
    }

    function getPubkey() {
        return userProfile.getPubKey()
    }

    function removeMemberFromGroupChat(publicKey) {
        const chatId = chatCommunitySectionModule.activeItem.id
        chatCommunitySectionModule.removeMemberFromGroupChat("", chatId, publicKey)
    }
}
