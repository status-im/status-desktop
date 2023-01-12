import QtQuick 2.14
import utils 1.0

QtObject {
    id: root

    property var messageModule
    property var messagesModel
    property var chatSectionModule

    readonly property bool loadingHistoryMessagesInProgress: root.chatSectionModule? root.chatSectionModule.loadingHistoryMessagesInProgress : false
    readonly property int newMessagesCount: messagesModel ? messagesModel.newMessagesCount : 0
    readonly property bool messageSearchOngoing: messageModule ? messageModule.messageSearchOngoing : false

    onMessageModuleChanged: {
        if(!messageModule)
            return
        root.messagesModel = messageModule.model
    }

    function loadMoreMessages () {
        if(!messageModule)
            return

        if(!messageModule.initialMessagesLoaded)
            return

        messageModule.loadMoreMessages()
    }

    function getMessageByIdAsJson (id) {
        if (!messageModule) {
            console.warn("getMessageByIdAsJson: Failed to parse message, because messageModule is not set")
            return false
        }

        const jsonObj = messageModule.getMessageByIdAsJson(id)
        if (jsonObj === "") {
            console.warn("getMessageByIdAsJson: Failed to get message, returned json is empty")
            return undefined
        }

        const obj = JSON.parse(jsonObj)
        if (obj.error) {
            // This log is available only in debug mode, if it's annoying we can remove it
            console.debug("getMessageByIdAsJson: Failed to parse message for index: ", id, " error: ", obj.error)
            return false
        }

        return obj
    }

    function getMessageByIndexAsJson (index) {
        if(!messageModule)
            return false

        let jsonObj = messageModule.getMessageByIndexAsJson(index)
        if(jsonObj === "")
            return

        let obj = JSON.parse(jsonObj)
        if (obj.error) {
            // This log is available only in debug mode, if it's annoying we can remove it
            console.debug("error parsing message for index: ", index, " error: ", obj.error)
            return false
        }

        return obj
    }

    function getSectionId () {
        if(!messageModule)
            return ""

        return messageModule.getSectionId()
    }

    function getChatId () {
        if(!messageModule)
            return ""

        return messageModule.getChatId()
    }

    function getChatType () {
        if(!messageModule)
            return Constants.chatType.unknown

        return messageModule.getChatType()
    }

    function getChatColor () {
        if(!messageModule)
            return Style.current.blue

        return messageModule.getChatColor()
    }

    function getChatIcon () {
        if(!messageModule)
            return ""

        return messageModule.getChatIcon()
    }

    function amIChatAdmin () {
        if(!messageModule)
            return false

        return messageModule.amIChatAdmin()
    }

    function pinMessageAllowedForMembers() {
        if(!messageModule)
            return false

        return messageModule.pinMessageAllowedForMembers()
    }

    function getNumberOfPinnedMessages () {
        if(!messageModule)
            return 0

        return messageModule.getNumberOfPinnedMessages()
    }

    function pinMessage (messageId) {
        if(!messageModule)
            return

        return messageModule.pinMessage(messageId)
    }

    function unpinMessage (messageId) {
        if(!messageModule)
            return

        return messageModule.unpinMessage(messageId)
    }

    function toggleReaction(messageId, emojiId) {
        if(!messageModule)
            return

        return messageModule.toggleReaction(messageId, emojiId)
    }

    function deleteMessage(messageId) {
        if(!messageModule)
            return
        messageModule.deleteMessage(messageId)
    }

    function setEditModeOn(messageId) {
        if(!messageModule)
            return
        messageModule.setEditModeOn(messageId)
    }

    function setEditModeOnLastMessage(pubkey) {
        if(!messageModule)
            return
        messageModule.setEditModeOnAndScrollToLastMessage(pubkey)
    }

    function setEditModeOff(messageId) {
        if(!messageModule)
            return
        messageModule.setEditModeOff(messageId)
    }

    function editMessage(messageId, contentType, updatedMsg) {
        if(!messageModule)
            return
        messageModule.editMessage(messageId, contentType, updatedMsg)
    }

    function interpretMessage(msg) {
        if (msg.startsWith("/shrug")) {
            return msg.replace("/shrug", "") + " ¯\\\\\\_(ツ)\\_/¯"
        }
        if (msg.startsWith("/tableflip")) {
            return msg.replace("/tableflip", "") + " (╯°□°）╯︵ ┻━┻"
        }

        return msg
    }

    function getLinkPreviewData(url, uuid) {
        if(!messageModule)
            return
        return messageModule.getLinkPreviewData(url, uuid)
    }

    function requestMoreMessages() {
        if(!messageModule)
            return
        return messageModule.requestMoreMessages()
    }

    function fillGaps(messageId) {
        if(!messageModule)
            return
        return messageModule.fillGaps(messageId)
    }

    function leaveChat() {
        if(!messageModule)
            return
        messageModule.leaveChat()
    }

    function addNewMessagesMarker() {
         if(!messageModule)
            return
        messageModule.addNewMessagesMarker()
    }

    property bool playAnimation: {
        if(!Global.applicationWindow.active)
            return false

        if(root.getSectionId() !== mainModule.activeSection.id)
            return false

        if(!root.chatSectionModule)
            return false

        if(root.chatSectionModule.activeItem.isSubItemActive &&
                root.getChatId() !== root.chatSectionModule.activeItem.activeSubItem.id ||
                !root.chatSectionModule.activeItem.isSubItemActive &&
                root.getChatId() !== root.chatSectionModule.activeItem.id)
            return false

        return true
    }

    function resendMessage(messageId) {
        if(!messageModule)
            return
        messageModule.resendMessage(messageId)
    }
}
