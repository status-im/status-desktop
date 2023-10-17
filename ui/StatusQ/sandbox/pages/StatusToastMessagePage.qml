import QtQuick 2.14

import StatusQ.Components 0.1

Item {
    id: root
    anchors.fill: parent

    Column {
        id: toastArea
        anchors.centerIn: parent
        spacing: 8
        Repeater {
            id: toastRepeater
            width: parent.width
            height: childrenRect.height
            model: [
                {"title":"anna.eth wants to verify your identity", "subTitle":"Provide the code in the letter I sent to you on February 1st.", "icon":"contact", "loading":false, "type":0,"url":"", "duration":0},
                {"title":"Verification Request Sent", "subTitle":"", "icon":"checkmark-circle", "loading":false, "type":1,"url":"", "duration":4000},
                {"title":"Collectible is being minted...", "subTitle":"View on Etherscan", "icon":"", "loading":true, "type":0,"url":"http://google.com", "duration":0},
                {"title":"Contact request sent", "subTitle":"", "icon":"checkmark-circle", "loading":false, "type":1,"url":"", "duration":4000},
                {"title":"Test User", "subTitle":"Hello message...", "icon":"", "loading":false, "type":0,"url":"", "duration":4000},
                {"title":"This device is no longer the control node for the Socks Community", "subTitle":"", "icon":"info", "loading":false, "type":0,"url":"", "duration":0},
                {"title":`This is, but not now, probably later on the road even it doesn't make sense, a very long title with <a style="text-decoration:none" href="www.qt.io">hyperlink</a>.`, "subTitle":"", "icon":"info", "loading":false, "type":2,"url":"", "duration":0},
            ]
            delegate: StatusToastMessage {
                primaryText: modelData.title
                secondaryText: modelData.subTitle
                icon.name: modelData.icon
                loading: modelData.loading
                type: modelData.type
                linkUrl: modelData.url
                duration: modelData.duration
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
                onClose: {
                    console.warn("toast closed: ", modelData.title)
                }
                onClicked: {
                    console.warn("toast clicked")
                }
            }
        }
    }
}
