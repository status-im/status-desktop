import QtQuick 2.12
import QtQuick.Controls 2.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"

StatusModal {
    property int checkedMembership: Constants.communityChatPublicAccess

    id: popup

    //% "Membership requirement"
    header.title: qsTrId("membership-title")

    ButtonGroup {
        id: membershipRequirementGroup
    }

    contentItem: Column {
        width: popup.width
        spacing: 8

        Item { 
            width: parent.width
            height: parent.spacing
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Require approval"
            title: qsTrId("membership-approval")
            sensor.onClicked: requestAccessRadio.checked = true
            components: [
                StatusRadioButton {
                    id: requestAccessRadio
                    checked: popup.checkedMembership === Constants.communityChatOnRequestAccess
                    ButtonGroup.group: membershipRequirementGroup
                    onCheckedChanged: {
                        if (checked) {
                            popup.checkedMembership = Constants.communityChatOnRequestAccess
                        }
                    }
                }
            ]
        }

        StatusBaseText {
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            width: parent.width * 0.78
            //% "Your community is free to join, but new members are required to be approved by the community creator first"
            text: qsTrId("membership-approval-description")
            anchors.left: parent.left
            anchors.leftMargin: 32
        }

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Require invite from another member"
            title: qsTrId("membership-invite")
            sensor.onClicked: inviteOnlyRadio.checked = true
            components: [
                StatusRadioButton {
                    id: inviteOnlyRadio
                    checked: popup.checkedMembership === Constants.communityChatInvitationOnlyAccess
                    ButtonGroup.group: membershipRequirementGroup
                    onCheckedChanged: {
                        if (checked) {
                            popup.checkedMembership = Constants.communityChatInvitationOnlyAccess
                        }
                    }
                }
            ]
        }

        StatusBaseText {
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            width: parent.width * 0.78
            //% "Your community can only be joined by an invitation from existing community members"
            text: qsTrId("membership-invite-description")
            anchors.left: parent.left
            anchors.leftMargin: 32
        }

        /* TODO: add functionality to configure this setting */
        /* StatusListItem { */
        /*     anchors.horizontalCenter: parent.horizontalCenter */
        //% "Require ENS username"
        /*     title: qsTrId("membership-ens") */
        /*     components: [ */
        /*         StatusRadioButton { */
        /*             checked: //... */
        /*             ButtonGroup.group: membershipRequirementGroup */
        /*             onCheckedChanged: { */
        /*                // ... */
        /*             } */
        /*         } */
        /*     ] */
        /* } */
        /* StatusBaseText { */
        /*     wrapMode: Text.WordWrap */
        /*     font.pixelSize: 13 */
        /*     color: Theme.palette.baseColor1 */
        /*     width: parent.width * 0.78 */
        //% "Your community requires an ENS username to be able to join"
        /*     text: qsTrId("membership-ens-description") */
        /*     anchors.left: parent.left */
        /*     anchors.leftMargin: 32 */
        /* } */

        StatusListItem {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "No requirement"
            title: qsTrId("membership-free")
            sensor.onClicked: publicRadio.checked = true
            components: [
                StatusRadioButton {
                    id: publicRadio
                    checked: popup.checkedMembership === Constants.communityChatPublicAccess
                    ButtonGroup.group: membershipRequirementGroup
                    onCheckedChanged: {
                        if (checked) {
                            popup.checkedMembership = Constants.communityChatPublicAccess
                        }
                    }
                }
            ]
        }

        StatusBaseText {
            wrapMode: Text.WordWrap
            font.pixelSize: 13
            color: Theme.palette.baseColor1
            width: parent.width * 0.78
            //% "Your community is free for anyone to join"
            text: qsTrId("membership-free-description")
            anchors.left: parent.left
            anchors.leftMargin: 32
        }

        Item { 
            width: parent.width
            height: parent.spacing
        }
    }

    leftButtons: [
        StatusRoundButton {
            icon.name: "arrow-right"
            icon.width: 20
            icon.height: 16
            rotation: 180
            onClicked: popup.close()
        }
    ]
}
