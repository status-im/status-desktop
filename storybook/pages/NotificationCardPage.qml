import QtQuick

import AppLayouts.ActivityCenter.controls

import Models

Item {
    anchors.fill: parent

    NotificationCard {
        id: n1
        anchors.centerIn: parent
        username: "anna.eth"
        userId: "zQ3s…5Ri9"
        verified: true
        avatarSource: "https://i.pravatar.cc/128?img=5"
        actionIconName: "action-mention"
        actionText: "New contact request"
        community: "CryptoKitties"
        channel: "#design"
        content: 'hey, <a href="status:robertf.ox.eth">@robertf.ox.eth</a>, Do we still plan to ship this with v2.1 or postpone to the next release cycle?'
        timestampText: "Just now"
        unread: true
        onClicked: console.log("Card clicked")
        onActionClicked: console.log("Action clicked")
        onAvatarClicked: console.log("Avatar clicked")
        onLinkActivated: (u)=> console.log("Link:", u)
    }
}

// category: Activity Center
// status: good
// https://www.figma.com/design/SGyfSjxs5EbzimHDXTlj8B/Qt-Responsive---v?node-id=1135-37804&m=dev
