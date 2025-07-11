import QtQuick
import QtQuick.Layouts

import StatusQ.Core
import StatusQ.Core.Theme
import StatusQ.Controls
import StatusQ.Components
import StatusQ.Popups


import utils

Column {
    id: root

    property string headerTitle: ""
    property string headerSubtitle: ""
    property string headerImageSource: ""
    property var community

    signal leaveButtonClicked()
    signal copyToClipboard(string link)

    Item {
        height: Math.max(46, communityDescription.height + 16)
        width: parent.width
        StatusBaseText {
            id: communityDescription
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            text: root.community.description
            font.pixelSize: Theme.primaryTextFontSize
            color: Theme.palette.directColor1
            wrapMode: Text.Wrap
            textFormat: Text.PlainText
        }
    }

    StatusModalDivider {
        bottomPadding: 8
    }

    StatusDescriptionListItem {
        title: qsTr("Share community")
        subTitle: Utils.getCommunityShareLink(root.community.id)
        tooltip.text: qsTr("Copied!")
        asset.name: "copy"
        iconButton.onClicked: {
            let link = Utils.getCommunityShareLink(root.community.id)
            root.copyToClipboard(link);
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }

    StatusModalDivider {
        topPadding: 8
        bottomPadding: 8
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.community.memberRole !== Constants.memberRole.owner
        title: root.community.spectated ? qsTr("Close Community") : qsTr("Leave Community")
        asset.name: root.community.spectated ? "close-circle" : "arrow-left"
        type: StatusListItem.Type.Danger
        onClicked: root.leaveButtonClicked()
    }
}
