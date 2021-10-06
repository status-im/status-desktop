import QtQuick 2.13
import QtQuick.Dialogs 1.3

import utils 1.0

QtObject {
    id: root

    property var chatsModelInst: chatsModel
    property var profileModelInst: profileModel

    function setActiveChannelToTimeline() {
        chatsModelInst.setActiveChannelToTimeline()
    }

    function getPlainTextFromRichText(text) {
        return chatsModelInst.plainText(text)
    }

    function sendMessage(message, contentType) {
        chatsModelInst.messageView.sendMessage(message, "", contentType, true)
    }

    function sendImage(url) {
        chatsModelInst.sendImage(url, true)
    }

}
