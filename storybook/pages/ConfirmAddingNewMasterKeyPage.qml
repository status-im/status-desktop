import QtQuick
import QtQuick.Controls

import shared.popups.addaccount.states

Item {
    id: root

    ConfirmAddingNewMasterKey {
        id: confirmAddingNewMasterKey
        anchors.fill: parent
    }

    Label {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 10

        text: "All accepted: " + confirmAddingNewMasterKey.allAccepted
    }
}

// category: Controls
// status: good
