import QtQuick 2.12
import QtQuick.Layouts 1.13

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Controls 0.1
import StatusQ.Components 0.1
import StatusQ.Popups 0.1

import "../../../../imports"

Column {
    id: root

    property string headerTitle: ""
    property string headerSubtitle: ""
    property string headerImageSource: ""
    property var community

    signal membersListButtonClicked()
    signal notificationsButtonClicked(bool checked)
    signal editButtonClicked()
    signal transferOwnershipButtonClicked()
    signal leaveButtonClicked()

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
        }
    }

    StatusModalDivider {
        topPadding: 8
        bottomPadding: 8
    }

    StatusDescriptionListItem {
        title: qsTr("Share community")
        subTitle: `${Constants.communityLinkPrefix}${root.community.id.substring(0, 4)}...${root.community.id.substring(root.community.id.length -2)}`
        tooltip.text: qsTr("Copy to clipboard")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${root.community.id}`
            chatsModel.copyToClipboard(link)
            tooltip.visible = !tooltip.visible
        }
        width: parent.width
    }

    StatusModalDivider {
        topPadding: 8
        bottomPadding: 8
    }

    StatusListItem {
        id: membersListItem
        anchors.horizontalCenter: parent.horizontalCenter

        property int nbRequests: root.community.communityMembershipRequests.nbRequests

        //% "Members"
        title: qsTrId("members-label")
        icon.name: "group-chat"
        label: root.community.nbMembers.toString()
        sensor.onClicked: root.membersListButtonClicked()

        components: [
            StatusBadge {
                visible: !!membersListItem.nbRequests
                value: membersListItem.nbRequests
                anchors.top: parent.top
                anchors.topMargin: 2
            },
            StatusIcon {
                icon: "chevron-down"
                rotation: 270
                color: Theme.palette.baseColor1
            }
        ]
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Notifications"
        title: qsTrId("notifications")
        icon.name: "notification"
        components: [
            StatusSwitch {
                checked: !root.community.muted
                onClicked: root.notificationsButtonClicked(!checked)
            }
        ]
    }

    StatusModalDivider {
        topPadding: 8
        bottomPadding: 8
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.community.isAdmin || root.community.admin
        title: qsTr("Edit community")
        icon.name: "edit"
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.editButtonClicked()
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: root.community.isAdmin || root.community.admin
        title: qsTr("Transfer ownership")
        icon.name: "exchange"
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.transferOwnershipButtonClicked()
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        //% "Leave community"
        title: qsTrId("leave-community")
        icon.name: "arrow-right"
        icon.height: 16
        icon.width: 20
        icon.rotation: 180
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.leaveButtonClicked()
    }

    //% "Roles"
    /*     // TODO add this back when roles exist */
/* //        Loader { */
/* //            active: root.community.isAdmin */
/* //            width: parent.width */
/* //            sourceComponent: CommunityPopupButton { */
/* //                label: qsTrId("community-roles") */
/* //                iconName: "roles" */
/* //                width: parent.width */
/* //                onClicked: console.log("TODO:") */
/* //                txtColor: Style.current.textColor */
/* //                SVGImage { */
/* //                    anchors.verticalCenter: parent.verticalCenter */
/* //                    anchors.right: parent.right */
/* //                    anchors.rightMargin: Style.current.padding */
/* //                    source: "../../../img/caret.svg" */
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
