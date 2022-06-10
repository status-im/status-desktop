import QtQuick 2.14

import StatusQ.Popups 0.1

StatusMenuItem {
    property bool muted: false

    text: !muted ? qsTr("Mute chat") : qsTr("Unmute chat")
    icon.name: "notification"
}
