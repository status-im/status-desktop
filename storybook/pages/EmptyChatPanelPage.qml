import QtQuick

import AppLayouts.Chat.panels

Item {
    EmptyChatPanel {
        anchors.fill: parent
        onShareChatKeyClicked: console.log("share chat key clicked!")
    }
}

// category: Panels
// status: good
