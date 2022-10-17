import QtQuick 2.14

import StatusQ.Popups 0.1

StatusMenuItem {
    property bool muted: false

    text: muted ? qsTr("Unmute Chat") : qsTr("Mute Chat")
    icon.name: "notification"
}
