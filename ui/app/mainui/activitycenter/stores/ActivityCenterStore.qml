import QtQuick 2.14

QtObject {
    id: root

    property bool hideReadNotifications: false

    readonly property var activityCenterModuleInst: activityCenterModule
    readonly property var activityCenterList: activityCenterModuleInst.activityNotificationsModel
    readonly property int unreadNotificationsCount: activityCenterModuleInst.unreadActivityCenterNotificationsCount

    function markAllActivityCenterNotificationsRead() {
        root.activityCenterModuleInst.markAllActivityCenterNotificationsRead()
    }

    function markActivityCenterNotificationRead(notification) {
        root.activityCenterModuleInst.markActivityCenterNotificationRead(
            notification.id, notification.message.communityId,
            notification.message.chatId, notification.notificationType)
    }

    function markActivityCenterNotificationUnread(notification) {
        root.activityCenterModuleInst.markActivityCenterNotificationUnread(
            notification.id, notification.message.communityId,
            notification.message.chatId, notification.notificationType)
    }

    function switchTo(notification) {
        root.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
    }
}