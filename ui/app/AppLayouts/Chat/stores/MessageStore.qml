import QtQuick 2.13
import utils 1.0

import StatusQ.Core.Utils 0.1 as StatusQUtils

QtObject {
    id: root

    property var messageModule
    property var messagesModel
    property var chatSectionModule

    property var loadingHistoryMessagesInProgress: root.chatSectionModule? root.chatSectionModule.loadingHistoryMessagesInProgress : false

    onMessageModuleChanged: {
        if(!messageModule)
            return
        root.messagesModel = messageModule.model
    }

    function loadMoreMessages () {
        if(!messageModule)
            return

        if(!messageModule.initialMessagesLoaded ||
            root.loadingHistoryMessagesInProgress? root.loadingHistoryMessagesInProgress : false)
            return

        messageModule.loadMoreMessages()
    }

    function getMessageByIdAsJson (id) {
        if(!messageModule)
            return false

        let jsonObj = messageModule.getMessageByIdAsJson(id)
        if(jsonObj === "")
            return

        let obj = JSON.parse(jsonObj)
        if (obj.error) {
            // This log is available only in debug mode, if it's annoying we can remove it
            console.debug("error parsing message for index: ", id, " error: ", obj.error)
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

    function lastTwoItems(nodes) {
        return nodes.join(qsTr(" and "));
    }

    function showReactionAuthors(jsonArrayOfUsersReactedWithThisEmoji, emojiId) {
        let listOfUsers = JSON.parse(jsonArrayOfUsersReactedWithThisEmoji)
        if (listOfUsers.error) {
            console.error("error parsing users who reacted to a message, error: ", obj.error)
            return
        }

        let tooltip
        if (listOfUsers.length === 1) {
            tooltip = listOfUsers[0]
        } else if (listOfUsers.length === 2) {
            tooltip = lastTwoItems(listOfUsers);
        } else {
            var leftNode = [];
            var rightNode = [];
            const maxReactions = 12
            let maximum = Math.min(maxReactions, listOfUsers.length)

            if (listOfUsers.length > maxReactions) {
                leftNode = listOfUsers.slice(0, maxReactions);
                rightNode = listOfUsers.slice(maxReactions, listOfUsers.length);
                return (rightNode.length === 1) ?
                            lastTwoItems([leftNode.join(", "), rightNode[0]]) :
                            lastTwoItems([leftNode.join(", "), qsTr("%1 more").arg(rightNode.length)]);
            }

            leftNode = listOfUsers.slice(0, maximum - 1);
            rightNode = listOfUsers.slice(maximum - 1, listOfUsers.length);
            tooltip = lastTwoItems([leftNode.join(", "), rightNode[0]])
        }

        tooltip += qsTr(" reacted with ");
        let emojiHtml = StatusQUtils.Emoji.getEmojiFromId(emojiId);
        if (emojiHtml) {
            tooltip += emojiHtml;
        }
        return tooltip
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

    function setEditModeOff(messageId) {
        if(!messageModule)
            return
        messageModule.setEditModeOff(messageId)
    }

    function editMessage(messageId, updatedMsg) {
        if(!messageModule)
            return
        messageModule.editMessage(messageId, updatedMsg)
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

    function getLinkPreviewData(url, uuid) {
        if(!messageModule)
            return
        return messageModule.getLinkPreviewData(url, uuid)
    }

    function requestMoreMessages() {
        if(!messageModule)
            return
        return messageModule.requestMoreMessages();
    }

    function fillGaps(messageId) {
         if(!messageModule)
            return
        return messageModule.fillGaps(messageId);
    }

    function leaveChat() {
         if(!messageModule)
            return
        messageModule.leaveChat();
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
}
