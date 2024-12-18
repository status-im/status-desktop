import QtQuick 2.15

import StatusQ.Controls 0.1

Item {
    id: root

    Rectangle {
        width: tabbar.childrenRect.width
        height: tabbar.childrenRect.height
        anchors.centerIn: parent
        color: "transparent"
        border.width: 1
        border.color: "pink"

        StatusTabBar {
            id: tabbar
            anchors.centerIn: parent

            StatusTabButton {
                width: implicitWidth
                text: "Contacts"
            }
            StatusTabButton {
                width: implicitWidth
                text: "Pending contacts"
                badge.value: 2
            }
            StatusTabButton {
                width: implicitWidth
                enabled: false
                text: "Blocked & disabled"
            }
            StatusTabButton {
                width: implicitWidth
                text: "Misc"
            }
        }
    }
}

// category: Controls
// status: good
