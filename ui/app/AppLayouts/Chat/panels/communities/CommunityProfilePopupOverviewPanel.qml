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
        subTitle: `${Constants.communityLinkPrefix}${root.community.id.substring(0, 4)}...${root.community.id.substring(root.community.id.length -2)}`
        tooltip.text: qsTr("Copied!")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${root.community.id}`
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
        visible: root.community.amISectionAdmin
        title: qsTr("Transfer ownership")
        icon.name: "exchange"
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.transferOwnershipButtonClicked()
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        title: qsTr("Leave community")
        icon.name: "arrow-right"
        icon.height: 16
        icon.width: 20
        icon.rotation: 180
        type: StatusListItem.Type.Danger
        sensor.onClicked: root.leaveButtonClicked()
    }

    /*     // TODO add this back when roles exist */
/* //        Loader { */
/* //            active: root.community.isAdmin */
/* //            width: parent.width */
/* //            sourceComponent: CommunityPopupButton { */
/* //                label: qsTr("Roles") */
/* //                iconName: "roles" */
/* //                width: parent.width */
/* //                onClicked: console.log("TODO:") */
/* //                txtColor: Style.current.textColor */
/* //                SVGImage { */
/* //                    anchors.verticalCenter: parent.verticalCenter */
/* //                    anchors.right: parent.right */
/* //                    anchors.rightMargin: Style.current.padding */
/* //                    source: Style.svg("caret") */
/* //                    width: 13 */
/* //                    height: 7 */
/* //                    rotation: -90 */
/* //                    ColorOverlay { */
/* //                        anchors.fill: parent */
/* //                        source: parent */
/* //                        color: Style.current.secondaryText */
/* //                    } */
/* //                } */
/* //            } */
/* //        } */
}
