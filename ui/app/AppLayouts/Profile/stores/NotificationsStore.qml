import QtQuick 2.13
import utils 1.0

QtObject {
    id: root

    property var notificationsModule

    property var exemptionsModel: notificationsModule.exemptionsModel

    function sendTestNotification(title, message) {
        root.notificationsModule.sendTestNotification(title, message)
    }

    function saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages) {
        root.notificationsModule.saveExemptions(itemId, muteAllMessages, personalMentions, globalMentions, allMessages)
    }

    property bool notifSettingAllowNotifications: appSettings.notifSettingAllowNotifications
    function setNotifSettingAllowNotifications(value) {
        appSettings.setNotifSettingAllowNotifications(value)
    }
    property string notifSettingOneToOneChats: appSettings.notifSettingOneToOneChats
    function setNotifSettingOneToOneChats(value) {
        appSettings.setNotifSettingOneToOneChats(value)
    }
    property string notifSettingGroupChats: appSettings.notifSettingGroupChats
    function setNotifSettingGroupChats(value) {
        appSettings.setNotifSettingGroupChats(value)
    }
    property string notifSettingPersonalMentions: appSettings.notifSettingPersonalMentions
    function setNotifSettingPersonalMentions(value) {
        appSettings.setNotifSettingPersonalMentions(value)
    }
    property string notifSettingGlobalMentions: appSettings.notifSettingGlobalMentions
    function setNotifSettingGlobalMentions(value) {
        appSettings.setNotifSettingGlobalMentions(value)
    }
    property string notifSettingAllMessages: appSettings.notifSettingAllMessages
    function setNotifSettingAllMessages(value) {
        appSettings.setNotifSettingAllMessages(value)
    }
    property string notifSettingContactRequests: appSettings.notifSettingContactRequests
    function setNotifSettingContactRequests(value) {
        appSettings.setNotifSettingContactRequests(value)
    }
    property string notifSettingIdentityVerificationRequests: appSettings.notifSettingIdentityVerificationRequests
    function setNotifSettingIdentityVerificationRequests(value) {
        appSettings.setNotifSettingIdentityVerificationRequests(value)
    }
    property int notificationMessagePreview: appSettings.notificationMessagePreview
    function setNotificationMessagePreview(value) {
        appSettings.setNotificationMessagePreview(value)
    }
    property bool notificationSoundsEnabled: appSettings.notificationSoundsEnabled
    function setNotificationSoundsEnabled(value) {
        appSettings.setNotificationSoundsEnabled(value)
    }
    property int volume: appSettings.volume
    function setVolume(value) {
        appSettings.setNotificationVolume(value)
    }

}
