import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var messageModule
    property var messagesModel

    onMessageModuleChanged: {
        if(!messageModule)
            return
        root.messagesModel = messageModule.model
    }

    function loadMoreMessages () {
        if(!messageModule)
            return
        if(!messageModule.initialMessagesLoaded || messageModule.loadingHistoryMessagesInProgress)
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
        //% " and "
        return nodes.join(qsTrId("-and-"));
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
                            //% "%1 more"
                            lastTwoItems([leftNode.join(", "), qsTrId("-1-more").arg(rightNode.length)]);
            }

            leftNode = listOfUsers.slice(0, maximum - 1);
            rightNode = listOfUsers.slice(maximum - 1, listOfUsers.length);
            tooltip = lastTwoItems([leftNode.join(", "), rightNode[0]])
        }

        //% " reacted with "
        tooltip += qsTrId("-reacted-with-");
        let emojiHtml = Emoji.getEmojiFromId(emojiId);
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
}
