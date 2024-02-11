import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var notificationsModule

    property var exemptionsModel: !!root.notificationsModule? root.notificationsModule.exemptionsModel : null

    function sendTestNotification(title, message) {
        root.notificationsModule.sendTestNotification(title, message)
    }

    function saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages) {
        root.notificationsModule.saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages)
    }
}
