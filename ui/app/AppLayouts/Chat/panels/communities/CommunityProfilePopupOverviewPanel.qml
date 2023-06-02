import QtQuick 2.12
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1


import utils 1.0

Column {
    id: root

    property string headerTitle: ""
    property string headerSubtitle: ""
    property string headerImageSource: ""
    property var community

    signal transferOwnershipButtonClicked()
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
            font.pixelSize: 15
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
        visible: root.community.memberRole === Constants.memberRole.owner
        title: qsTr("Transfer ownership")
        asset.name: "exchange"
        type: StatusListItem.Type.Secondary
        onClicked: root.transferOwnershipButtonClicked()
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        title: qsTr("Leave community")
        asset.name: "arrow-left"
        type: StatusListItem.Type.Danger
        onClicked: root.leaveButtonClicked()
    }
}
