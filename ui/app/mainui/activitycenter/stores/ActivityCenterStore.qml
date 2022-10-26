import QtQuick 2.14

QtObject {
    id: root

    property bool hideReadNotifications: false

    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.activityNotificationsModel
    property int unreadNotificationsCount: activityCenterList.unreadCount

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