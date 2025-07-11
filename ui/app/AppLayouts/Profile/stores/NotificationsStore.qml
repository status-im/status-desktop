import QtQuick
import utils

QtObject {
    id: root

    property var notificationsModule
    property var notificationsSettings: appSettings

    property var exemptionsModel: notificationsModule.exemptionsModel

    function loadExemptions() {
        root.notificationsModule.loadExemptions()
    }

    function sendTestNotification(title, message) {
        root.notificationsModule.sendTestNotification(title, message)
    }

    function saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages) {
        root.notificationsModule.saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages)
    }
}
