import QtQuick 2.15

import shared 1.0

QtObject {
    id: root

    readonly property var activityCenterModuleInst: activityCenterModule
    readonly property var activityCenterNotifications: activityCenterModuleInst.activityNotificationsModel
    readonly property int unreadNotificationsCount: activityCenterModuleInst.unreadActivityCenterNotificationsCount
    readonly property bool hasUnseenNotifications: activityCenterModuleInst.hasUnseenActivityCenterNotifications
    readonly property int activeNotificationGroup: activityCenterModuleInst.activeNotificationGroup
    readonly property int activityCenterReadType: activityCenterModuleInst.activityCenterReadType

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

    function setActiveNotificationGroup(group) {
        root.activityCenterModuleInst.setActiveNotificationGroup(group)
    }

    function setActivityCenterReadType(readType) {
        root.activityCenterModuleInst.setActivityCenterReadType(readType)
    }
}