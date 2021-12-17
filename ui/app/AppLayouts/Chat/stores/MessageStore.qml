import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var messageModule

    function getMessageByIdAsJson (id) {
        if(!messageModule)
            return false

        let jsonObj = messageModule.getMessageByIdAsJson(id)
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
}
