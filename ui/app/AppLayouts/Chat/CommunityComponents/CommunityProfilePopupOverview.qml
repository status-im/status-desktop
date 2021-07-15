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
    property string description: ""

    signal membersListButtonClicked()
    signal notificationsButtonClicked(bool checked)
    signal editButtonClicked()
    signal transferOwnershipButtonClicked()
    signal leaveButtonClicked()

    StatusModalDivider {
        bottomPadding: 8
    }

    Item {
        height: 46
        width: parent.width
        StatusBaseText {
            id: communityDescription
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: 16
            anchors.rightMargin: 16
            text: root.description
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
        subTitle: `${Constants.communityLinkPrefix}${communityId.substring(0, 4)}...${communityId.substring(communityId.length -2)}`
        tooltip.text: qsTr("Copy to clipboard")
        icon.name: "copy"
        iconButton.onClicked: {
            let link = `${Constants.communityLinkPrefix}${communityId}`
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

        property int nbRequests: chatsModel.communities.activeCommunity.communityMembershipRequests.nbRequests

        title: qsTr("Members")
        icon.name: "group-chat"
        label: nbMembers.toString()
        sensor.onClicked: root.membersListButtonClicked()

        components: [
            StatusBadge {
                visible: !!membersListItem.nbRequests
                value: membersListItem.nbRequests
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
        title: qsTr("Notifications")
        icon.name: "notification"
        components: [
            StatusSwitch {
                checked: !chatsModel.communities.activeCommunity.muted
                onClicked: root.notificationsButtonClicked(checked)
            }
        ]
    }

    StatusModalDivider {
        topPadding: 8
        bottomPadding: 8
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: isAdmin
        title: qsTr("Edit community")
        icon.name: "edit"
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.editButtonClicked()
    }

    StatusListItem {
        anchors.horizontalCenter: parent.horizontalCenter
        visible: isAdmin
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
        type: StatusListItem.Type.Secondary
        sensor.onClicked: root.leaveButtonClicked()
    }

    /*     // TODO add this back when roles exist */
/* //        Loader { */
/* //            active: isAdmin */
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
