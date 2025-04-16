import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var notificationsModule
    property var notificationsSettings: appSettings /*TODO: Add appSettings.notifSettingStatusNews notifiable property in the backend*/

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
