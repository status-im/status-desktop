import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1


import utils 1.0

StatusModal {
    id: root

    property var store
    property QtObject community: root.store.communitiesModuleInst.observedCommunity
    property string communityId: community.id
    property string name: community.name
    property string description: community.description
    property int access: community.access
    property string source: community.image
    property int nbMembers: community.members.count
    property bool ensOnly: community.ensOnly
    property bool canJoin: community.canJoin
    property bool canRequestAccess: community.canRequestAccess
    property bool isMember: community.isMember
    property string communityColor: community.color || Style.current.blue

    header.title: name
    header.subTitle: {
        let subTitle = ""
        switch(access) {
            case Constants.communityChatPublicAccess:
                //% "Public community"
                subTitle = qsTrId("public-community");
                break;
            case Constants.communityChatInvitationOnlyAccess:
                //% "Invitation only community"
                subTitle = qsTrId("invitation-only-community");
                break;
            case Constants.communityChatOnRequestAccess:
                //% "On request community"
                subTitle = qsTrId("on-request-community");
                break;
            default:
                subTitle = qsTr("Unknown community");
                break;
        }
        if (ensOnly) {
            //% " - ENS only"
            subTitle += qsTrId("---ens-only")
        }
        return subTitle
    }

    contentItem: Column {
        width: root.width

        Item {
            height: childrenRect.height + Style.dp(8)
            width: parent.width - Style.dp(32)
            anchors.horizontalCenter: parent.horizontalCenter

            StatusBaseText {
                id: description
                anchors.top: parent.top
                anchors.topMargin: Style.current.padding
                text: root.description
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
                width: parent.width
                textFormat: Text.PlainText
            }

            StatusIcon {
                id: statusIcon
                anchors.top: description.bottom
                anchors.topMargin: Style.current.padding
                anchors.left: parent.left
                icon: "tiny/contact"
                width: Style.dp(16)
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                //% "%1 members"
                text: qsTrId("-1-members").arg(nbMembers)
                font.pixelSize: Style.current.primaryTextFontSize
                font.weight: Font.Medium
                color: Theme.palette.directColor1
                anchors.left: statusIcon.right
                anchors.leftMargin: Style.dp(2)
                anchors.verticalCenter: statusIcon.verticalCenter
            }
        }

        StatusModalDivider {
            topPadding: Style.current.halfPadding
            bottomPadding: Style.current.halfPadding
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - Style.dp(32)
            height: Style.dp(34)
            StatusBaseText {
                //% "Channels"
                text: qsTrId("channels")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: Style.dp(4)
                font.pixelSize: Style.current.primaryTextFontSize
                color: Theme.palette.baseColor1
            }
        }

        ScrollView {
            width: root.width
            height: Style.dp(300)
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            clip: true
            ListView {
                id: chatList
                anchors.fill: parent
                clip: true
                model: community.chats
                boundsBehavior: Flickable.StopAtBounds
                delegate: StatusListItem {
                    anchors.horizontalCenter: parent.horizontalCenter
                    title: "#" + model.name
                    subTitle: model.description
                    icon.isLetterIdenticon: true
                    icon.background.color: root.communityColor
                }
            }
        }
    }


    leftButtons: [
        StatusRoundButton {
            id: backButton
            icon.name: "arrow-right"
            icon.height: Style.dp(16)
            icon.width: Style.dp(20)
            rotation: 180
            onClicked: {
                Global.openPopup(communitiesPopupComponent)
                root.close()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            property bool isPendingRequest: {
                if (access !== Constants.communityChatOnRequestAccess) {
                    return false
                }
                return false
                // Not Refactored Yet
//                return root.store.chatsModelInst.communities.isCommunityRequestPending(root.communityId)
            }
            text: {
                // Not Refactored Yet
//                if (root.ensOnly && !root.store.profileModelInst.profile.ensVerified) {
//                    //% "Membership requires an ENS username"
//                    return qsTrId("membership-requires-an-ens-username")
//                }
                if (root.canJoin) {
                    //% "Join ‘%1’"
                    return qsTrId("join---1-").arg(root.name);
                }
                if (isPendingRequest) {
                     //% "Pending"
                     return qsTrId("invite-chat-pending")
                }
                switch(root.access) {
                    //% "Join ‘%1’"
                    case Constants.communityChatPublicAccess: return qsTrId("join---1-").arg(root.name);
                    //% "You need to be invited"
                    case Constants.communityChatInvitationOnlyAccess: return qsTrId("you-need-to-be-invited");
                    //% "Request to join ‘%1’"
                    case Constants.communityChatOnRequestAccess: return qsTrId("request-to-join---1-").arg(root.name);
                    //% "Unknown community"
                    default: return qsTrId("unknown-community");
                }
            }
            enabled: {
                // Not Refactored Yet
//                if (root.ensOnly && !root.store.profileModelInst.profile.ensVerified) {
//                    return false
//                }
                if (root.access === Constants.communityChatInvitationOnlyAccess || isPendingRequest) {
                    return false
                }
                if (canJoin) {
                    return true
                }
                return true
            }
            onClicked: {
                // Not Refactored Yet
               let error
               if (access === Constants.communityChatOnRequestAccess &&
                    !root.community.amISectionAdmin
                    && !root.isMember) {
                   // TODO refactor
                   return
                //    error = root.store.chatsModelInst.communities.requestToJoinCommunity(root.communityId, userProfile.name)
                //    if (!error) {
                //        enabled = false
                //        //% "Pending"
                //        text = qsTrId("invite-chat-pending")
                //    }
               } else {
                   error = root.store.communitiesModuleInst.joinCommunity(root.communityId)
               }

               if (error) {
                   joiningError.text = error
                   return joiningError.open()
               }

               root.close()
            }
        }
    ]

    MessageDialog {
        id: joiningError
        //% "Error joining the community"
        title: qsTrId("error-joining-the-community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

