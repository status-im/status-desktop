import QtQuick 2.13

import utils 1.0

QtObject {
    id: root

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

