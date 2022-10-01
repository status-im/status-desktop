import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

    property var activityCenterModuleInst: activityCenterModule
    property var activityCenterList: activityCenterModuleInst.activityNotificationsModel
    property int unreadNotificationsCount: activityCenterList.unreadCount

    property var nodeModelInst: nodeModel
//    property var profileModelInst: profileModel

    function getMailserverName(activeMailServer) {
        // Not Refactored Yet
        return ""
//        return profileModelInst.mailservers.list.getMailserverName(activeMailServer)
    }

    function onSend(text) {
        nodeModelInst.onSend(text)
    }
}

