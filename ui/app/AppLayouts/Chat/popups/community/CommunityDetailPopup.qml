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
                subTitle = qsTr("Public community");
                break;
            case Constants.communityChatInvitationOnlyAccess:
                subTitle = qsTr("Invitation only community");
                break;
            case Constants.communityChatOnRequestAccess:
                subTitle = qsTr("On request community");
                break;
            default:
                subTitle = qsTr("Unknown community");
                break;
        }
        if (ensOnly) {
            subTitle += qsTr(" - ENS only")
        }
        return subTitle
    }

    contentItem: Column {
        width: root.width

        Item {
            height: childrenRect.height + 8
            width: parent.width - 32
            anchors.horizontalCenter: parent.horizontalCenter

            StatusBaseText {
                id: description
                anchors.top: parent.top
                anchors.topMargin: 16
                text: root.description
                font.pixelSize: 15
                color: Theme.palette.directColor1
                wrapMode: Text.WordWrap
                width: parent.width
                textFormat: Text.PlainText
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
                text: qsTr("%1 members").arg(nbMembers)
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
                text: qsTr("Channels")
                anchors.bottom: parent.bottom
                anchors.bottomMargin: 4
                font.pixelSize: 15
                color: Theme.palette.baseColor1
            }
        }

        ScrollView {
            width: root.width
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
                    icon.background.color: root.communityColor
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
//                    return qsTr("Membership requires an ENS username")
//                }
                if (root.canJoin) {
                    return qsTr("Join ‘%1’").arg(root.name);
                }
                if (isPendingRequest) {
                     return qsTr("Pending")
                }
                switch(root.access) {
                    case Constants.communityChatPublicAccess: return qsTr("Join ‘%1’").arg(root.name);
                    case Constants.communityChatInvitationOnlyAccess: return qsTr("You need to be invited");
                    case Constants.communityChatOnRequestAccess: return qsTr("Request to join ‘%1’").arg(root.name);
                    default: return qsTr("Unknown community");
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
                //        text = qsTr("Pending")
                //    }
               } else {
                   error = root.store.communitiesModuleInst.joinCommunity(root.communityId, root.store.userProfileInst.ensName)
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
        title: qsTr("Error joining the community")
        icon: StandardIcon.Critical
        standardButtons: StandardButton.Ok
    }
}

