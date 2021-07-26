import QtQuick 2.12
import QtQuick.Controls 2.3
import QtQuick.Dialogs 1.3

import StatusQ.Core 0.1
import StatusQ.Core.Theme 0.1
import StatusQ.Components 0.1
import StatusQ.Controls 0.1
import StatusQ.Popups 0.1

import "../../../../imports"
import "../../../../shared"

StatusModal {
    property QtObject community: chatsModel.communities.observedCommunity
    property string communityId: community.id
    property string name: community.name
    property string description: community.description
    property int access: community.access
    property string source: community.thumbnailImage
    property int nbMembers: community.nbMembers
    property bool ensOnly: community.ensOnly
    property bool canJoin: community.canJoin
    property bool canRequestAccess: community.canRequestAccess
    property bool isMember: community.isMember
    property string communityColor: community.communityColor || Style.current.blue

    id: popup

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
                subTitle = qsTrId("Unknown community");
                break;
        }
        if (ensOnly) {
            //% " - ENS only"
            subTitle += qsTrId("---ens-only")
        }
        return subTitle
    }

    content: Column {
        width: popup.width

        Item {
            height: childrenRect.height + 8
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter

            StatusBaseText {
                id: description
                anchors.top: parent.top
                anchors.topMargin: 16
                text: popup.description
                font.pixelSize: 15
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
                width: parent.width
            }

            StatusIcon {
                id: statusIcon
                anchors.top: description.bottom
                anchors.topMargin: 16
                anchors.left: parent.left
                icon: "tiny/contact"
                width: 16
                color: Theme.palette.directColor1
            }

            StatusBaseText {
                //% "%1 members"
                text: qsTrId("-1-members").arg(nbMembers)
                font.pixelSize: 15
                font.weight: Font.Medium
                color: Theme.palette.directColor1
                anchors.left: statusIcon.right
                anchors.leftMargin: 2
                anchors.verticalCenter: statusIcon.verticalCenter
            }
        }

        StatusModalDivider {
            topPadding: 8
            bottomPadding: 8
        }

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width - 32
            height: 34
            StatusBaseText {
                //% "Channels"
                text: qsTrId("channels")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        ScrollView {
            width: popup.width
            height: 300
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
                    icon.background.color: popup.communityColor
                }
            }
        }
    }


    leftButtons: [
        StatusRoundButton {
            id: backButton
            icon.name: "arrow-right"
            icon.height: 16
            icon.width: 20
            rotation: 180
            onClicked: {
                openPopup(communitiesPopupComponent)
                popup.close()
            }
        }
    ]

    rightButtons: [
        StatusButton {
            property bool isPendingRequest: {
                if (access !== Constants.communityChatOnRequestAccess) {
                    return false
                }
                return chatsModel.communities.isCommunityRequestPending(popup.communityId)
            }
            text: {
                if (popup.ensOnly && !profileModel.profile.ensVerified) {
                    //% "Membership requires an ENS username"
                    return qsTrId("membership-requires-an-ens-username")
                }
                if (popup.canJoin) {
                    //% "Join ‘%1’"
                    return qsTrId("join---1-").arg(popup.name);
                }
                if (isPendingRequest) {
                     //% "Pending"
                     return qsTrId("invite-chat-pending")
                }
                switch(popup.access) {
                    //% "Join ‘%1’"
                    case Constants.communityChatPublicAccess: return qsTrId("join---1-").arg(popup.name);
                    //% "You need to be invited"
                    case Constants.communityChatInvitationOnlyAccess: return qsTrId("you-need-to-be-invited");
                    //% "Request to join ‘%1’"
                    case Constants.communityChatOnRequestAccess: return qsTrId("request-to-join---1-").arg(popup.name);
                    //% "Unknown community"
                    default: return qsTrId("unknown-community");
                }
            }
            enabled: {
                if (popup.ensOnly && !profileModel.profile.ensVerified) {
                    return false
                }
                if (popup.access === Constants.communityChatInvitationOnlyAccess || isPendingRequest) {
                    return false
                }
                if (canJoin) {
                    return true
                }
                return true
            }
            onClicked: {
                let error
                if (access === Constants.communityChatOnRequestAccess && !popup.isMember) {
                    error = chatsModel.communities.requestToJoinCommunity(popup.communityId,
                                                              profileModel.profile.ensVerified ? profileModel.profile.username : "")
                    if (!error) {
                        enabled = false
                        //% "Pending"
                        text = qsTrId("invite-chat-pending")
                    }
                } else {
                    error = chatsModel.communities.joinCommunity(popup.communityId, true)
                }

                if (error) {
                    joiningError.text = error
                    return joiningError.open()
                }

                popup.close()
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

