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
                {"title":"anna.eth wants to verify your identity", "subTitle":"Provide the code in the letter I sent to you on February 1st.", "icon":"contact", "loading":false, "type":0,"url":""},
                {"title":"Verification Request Sent", "subTitle":"", "icon":"checkmark-circle", "loading":false, "type":1,"url":""},
                {"title":"Collectible is being minted...", "subTitle":"View on Etherscan", "icon":"", "loading":true, "type":0,"url":"http://google.com"},
                {"title":"Contact request sent", "subTitle":"", "icon":"checkmark-circle", "loading":false, "type":1,"url":""}
            ]
            delegate: StatusToastMessage {
                primaryText: modelData.title
                secondaryText: modelData.subTitle
                icon.name: modelData.icon
                loading: modelData.loading
                type: modelData.type
                linkUrl: modelData.url
                onLinkActivated: {
                    Qt.openUrlExternally(link);
                }
                //simulate open
                Component.onCompleted: {
                    open = true;
                }
            }
        }
    }
}
