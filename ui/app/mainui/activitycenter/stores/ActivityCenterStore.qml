import QtQuick 2.14

QtObject {
    id: root

    property bool hideReadNotifications: false

    readonly property var activityCenterModuleInst: activityCenterModule
    readonly property var activityCenterNotifications: activityCenterModuleInst.activityNotificationsModel
    readonly property int unreadNotificationsCount: activityCenterModuleInst.unreadActivityCenterNotificationsCount
    readonly property bool hasUnseenNotifications: activityCenterModuleInst.hasUnseenActivityCenterNotifications

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

    function markAsSeenActivityCenterNotifications() {
        root.activityCenterModuleInst.markAsSeenActivityCenterNotifications()
    }

    function switchTo(notification) {
        root.activityCenterModuleInst.switchTo(notification.sectionId, notification.chatId, notification.id)
    }
}