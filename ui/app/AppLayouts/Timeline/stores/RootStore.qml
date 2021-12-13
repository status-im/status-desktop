import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

QtObject {
    id: root

    // Not Refactored Yet
//    property var chatsModelInst: chatsModel
    // Not Refactored Yet
//    property var profileModelInst: profileModel

    function setActiveChannelToTimeline() {
        // Not Refactored Yet
//        chatsModelInst.setActiveChannelToTimeline()
    }

    function getPlainTextFromRichText(text) {
        // Not Refactored Yet
//        return chatsModelInst.plainText(text)
    }

    function sendMessage(message, contentType) {
        // Not Refactored Yet
//        chatsModelInst.messageView.sendMessage(message, "", contentType, true)
    }

    function sendImage(url) {
        // Not Refactored Yet
//        chatsModelInst.sendImage(url, true)
    }

}
