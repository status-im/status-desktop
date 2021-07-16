import QtQuick 2.12
import QtQuick.Controls 2.3
import QtGraphicalEffects 1.13
import QtQuick.Dialogs 1.3
import "../../../../imports"
import "../../../../shared"
import "../../../../shared/status"

ModalPopup {
    property int checkedMembership: Constants.communityChatPublicAccess

    id: popup
    height: 600

    //% "Membership requirement"
    title: qsTrId("membership-title")

    ScrollView {
        property ScrollBar vScrollBar: ScrollBar.vertical

        id: scrollView
        anchors.fill: parent
        rightPadding: Style.current.bigPadding
        anchors.rightMargin: - Style.current.bigPadding
        leftPadding: Style.current.bigPadding
        anchors.leftMargin: - Style.current.bigPadding
        contentHeight: content.height
        ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
        clip: true

        ButtonGroup {
            id: membershipRequirementGroup
        }

        Column {
            id: content
            width: parent.width
            spacing: Style.current.padding

            MembershipRadioButton {
                //% "Require approval"
                text: qsTrId("membership-approval")
                //% "Your community is free to join, but new members are required to be approved by the community creator first"
                description: qsTrId("membership-approval-description")
                buttonGroup: membershipRequirementGroup
                checked: popup.checkedMembership === Constants.communityChatOnRequestAccess
                onRadioCheckedChanged: {
                    if (checked) {
                        popup.checkedMembership = Constants.communityChatOnRequestAccess
                    }
                }
            }

            MembershipRadioButton {
                //% "Require invite from another member"
                text: qsTrId("membership-invite")
                //% "Your community can only be joined by an invitation from existing community members"
                description: qsTrId("membership-invite-description")
                buttonGroup: membershipRequirementGroup
                checked: popup.checkedMembership === Constants.communityChatInvitationOnlyAccess
                onRadioCheckedChanged: {
                    if (checked) {
                        popup.checkedMembership = Constants.communityChatInvitationOnlyAccess
                    }
                }
            }

            //% "Require ENS username"
            //% "Your community requires an ENS username to be able to join"
            // This should be a check box
//            MembershipRadioButton {
//                text: qsTrId("membership-ens")
//                description: qsTrId("membership-ens-description")
//                buttonGroup: membershipRequirementGroup
//            }

            MembershipRadioButton {
                //% "No requirement"
                text: qsTrId("membership-free")
                //% "Your community is free for anyone to join"
                description: qsTrId("membership-free-description")
                buttonGroup: membershipRequirementGroup
                hideSeparator: true
                checked: popup.checkedMembership === Constants.communityChatPublicAccess
                onRadioCheckedChanged: {
                    if (checked) {
                        popup.checkedMembership = Constants.communityChatPublicAccess
                    }
                }
            }
        }
    }

    footer: StatusIconButton {
        id: backButton
        icon.name: "leave_chat"
        width: 44
        height: 44
        iconColor: Style.current.primary
        highlighted: true
        icon.color: Style.current.primary
        icon.width: 28
        icon.height: 28
        radius: width / 2
        onClicked: {
            popup.close()
        }
    }
}

