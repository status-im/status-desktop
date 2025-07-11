import QtQuick
import QtQuick.Controls

import shared.popups.walletconnect

Item {
    id: root

    ConnectionStatusTag {
        id: connectionTag
        anchors.centerIn: parent
        success: checkbox.checked
    }

    CheckBox {
        id: checkbox
        anchors.bottom: connectionTag.top
        anchors.horizontalCenter: connectionTag.horizontalCenter
        text: "success"
        checked: false
    }
}

// category: Components
// https://www.figma.com/design/HrmZp1y4S77QJezRFRl6ku/dApp-Interactions---Milestone-1?node-id=481-165960&t=oshb3aHNPCiUcQdH-0